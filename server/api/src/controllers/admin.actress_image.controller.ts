import { Request, Response, NextFunction } from 'express';
import { Actress, ActressImage } from '../models';
import { Op } from 'sequelize';
import path from 'path';
import sharp from 'sharp';
import { randomUUID } from 'crypto';
import {
  cleanRelativeUploadPath,
  cleanupUploadedTempFiles,
  deleteFileIfExists,
  deleteUploadFileIfExists,
  ensureUploadDir,
  finalizeHashedUpload,
  toUploadRelativePath,
} from '../utilities/uploadStorage';

const deleteActressUploadFilesIfUnused = async (relativePaths: Array<string | null | undefined>) => {
  const uniquePaths = [...new Set(relativePaths.filter(Boolean).map((relativePath) => (
    cleanRelativeUploadPath(relativePath as string)
  )))];

  for (const relativePath of uniquePaths) {
    const imageReferences = await ActressImage.count({
      where: {
        [Op.or]: [
          { image_url: relativePath },
          { thumbnail_url: relativePath },
        ],
      },
    });
    const actressThumbnailReferences = relativePath.startsWith('actresses/thumbnails/')
      ? await Actress.count({ where: { thumbnail_image: path.basename(relativePath) } })
      : 0;

    if (imageReferences + actressThumbnailReferences === 0) {
      await deleteUploadFileIfExists(relativePath);
    }
  }
};

// Get all levels (1 to 1000) for a specific actress, with their associated images if they exist
export const getActressLevels = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { actressId } = req.params;
    
    const actress = await Actress.findByPk(actressId);
    if (!actress) {
      return res.status(404).json({ success: false, message: 'Actress not found' });
    }

    // Fetch all images for this actress
    const images = await ActressImage.findAll({
      where: { actress_id: actress.id },
      order: [['level_number', 'ASC']]
    });

    const imageMap = new Map();
    images.forEach(img => {
      imageMap.set(img.level_number, img);
    });

    // Build exactly 1000 items
    const levels = [];
    for (let i = 1; i <= 1000; i++) {
      let difficulty = 'beginner';
      if (i <= 250) difficulty = 'easy';
      else if (i <= 500) difficulty = 'medium';
      else if (i <= 750) difficulty = 'hard';
      else difficulty = 'expert';

      const img = imageMap.get(i);

      levels.push({
        level_number: i,
        difficulty: difficulty,
        image: img ? {
          id: img.id,
          image_url: img.image_url,
          thumbnail_url: img.thumbnail_url,
          created_at: img.createdAt
        } : null
      });
    }

    res.json({ success: true, data: levels });
  } catch (error) {
    next(error);
  }
};

// Upload or update the image for a specific level of a specific actress
export const uploadLevelImage = async (req: Request, res: Response, next: NextFunction) => {
  let tempOptimizedPath: string | null = null;
  let tempThumbPath: string | null = null;

  try {
    const { actressId, levelNumber } = req.params;
    
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Image file is required' });
    }

    const actress = await Actress.findByPk(actressId);
    if (!actress) {
      return res.status(404).json({ success: false, message: 'Actress not found' });
    }

    const level = parseInt(levelNumber);
    if (isNaN(level) || level < 1 || level > 1000) {
      return res.status(400).json({ success: false, message: 'Level number must be between 1 and 1000' });
    }

    // Check if an image already exists for this level
    const existingImage = await ActressImage.findOne({
      where: { actress_id: actress.id, level_number: level }
    });

    const optimizedDir = await ensureUploadDir('actresses', 'optimized');
    const thumbDir = await ensureUploadDir('actresses', 'thumbnails');

    // Process new image
    tempOptimizedPath = path.join(optimizedDir, `.tmp-${randomUUID()}.webp`);
    tempThumbPath = path.join(thumbDir, `.tmp-${randomUUID()}.webp`);

    const info = await sharp(req.file.path, { sequentialRead: true })
      .resize(1080, 1350, { fit: 'cover' })
      .webp({ quality: 80 })
      .toFile(tempOptimizedPath);

    await sharp(req.file.path, { sequentialRead: true })
      .resize(300, 375, { fit: 'cover' })
      .webp({ quality: 70 })
      .toFile(tempThumbPath);

    const optimizedFile = await finalizeHashedUpload({
      tempFilePath: tempOptimizedPath,
      targetDir: optimizedDir,
      filenamePrefix: 'actress-level',
    });
    tempOptimizedPath = null;

    const thumbFile = await finalizeHashedUpload({
      tempFilePath: tempThumbPath,
      targetDir: thumbDir,
      filenamePrefix: 'actress-level',
      filenameSuffix: '-thumb',
    });
    tempThumbPath = null;

    const imageUrl = toUploadRelativePath('actresses', 'optimized', optimizedFile.filename);
    const thumbnailUrl = toUploadRelativePath('actresses', 'thumbnails', thumbFile.filename);

    if (existingImage) {
      const oldImageUrl = existingImage.image_url;
      const oldThumbnailUrl = existingImage.thumbnail_url;

      // Update record
      existingImage.image_url = imageUrl;
      existingImage.thumbnail_url = thumbnailUrl;
      existingImage.width = info.width;
      existingImage.height = info.height;
      existingImage.file_size = optimizedFile.size;
      existingImage.mime_type = 'image/webp';
      await existingImage.save();
      await deleteActressUploadFilesIfUnused([oldImageUrl, oldThumbnailUrl]);

      return res.json({ success: true, message: 'Image updated', data: existingImage });
    } else {
      // Create new record
      const newImage = await ActressImage.create({
        actress_id: actress.id,
        level_number: level,
        title: `${actress.name} - Level ${level}`,
        image_url: imageUrl,
        thumbnail_url: thumbnailUrl,
        is_portrait: true,
        width: info.width,
        height: info.height,
        file_size: optimizedFile.size,
        mime_type: 'image/webp'
      });

      return res.status(201).json({ success: true, message: 'Image uploaded', data: newImage });
    }

  } catch (error) {
    await Promise.all([
      deleteFileIfExists(tempOptimizedPath),
      deleteFileIfExists(tempThumbPath),
    ]);
    next(error);
  } finally {
    await cleanupUploadedTempFiles(req);
  }
};

// Delete a level image
export const deleteLevelImage = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { actressId, levelNumber } = req.params;
    
    const image = await ActressImage.findOne({
      where: { actress_id: actressId, level_number: levelNumber }
    });

    if (!image) {
      return res.status(404).json({ success: false, message: 'Image not found for this level' });
    }

    const imageUrl = image.image_url;
    const thumbnailUrl = image.thumbnail_url;

    await image.destroy({ force: true }); // Hard delete
    await deleteActressUploadFilesIfUnused([imageUrl, thumbnailUrl]);

    res.json({ success: true, message: 'Image deleted' });
  } catch (error) {
    next(error);
  }
};
