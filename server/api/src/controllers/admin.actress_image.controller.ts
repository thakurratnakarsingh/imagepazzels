import { Request, Response, NextFunction } from 'express';
import { Actress, ActressImage } from '../models';
import path from 'path';
import fs from 'fs/promises';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';

// Helper to generate readable timestamps like 20260802-143045
const getReadableTimestamp = () => {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${pad(d.getMonth()+1)}${pad(d.getDate())}-${pad(d.getHours())}${pad(d.getMinutes())}${pad(d.getSeconds())}`;
};

const UPLOAD_ROOT = path.join(__dirname, '..', '..', 'uploads');
const UPLOAD_DIR = path.join(UPLOAD_ROOT, 'actresses');

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

    const optimizedDir = path.join(UPLOAD_DIR, 'optimized');
    const thumbDir = path.join(UPLOAD_DIR, 'thumbnails');
    
    await fs.mkdir(optimizedDir, { recursive: true });
    await fs.mkdir(thumbDir, { recursive: true });

    // Process new image
    const filenameBase = `${actress.slug}-level-${level}-${getReadableTimestamp()}-${uuidv4().substring(0, 8)}`;
    const optimizedFilename = `${filenameBase}.webp`;
    const thumbFilename = `${filenameBase}-thumb.webp`;

    const info = await sharp(req.file.buffer)
      .resize(1080, 1350, { fit: 'cover' })
      .webp({ quality: 80 })
      .toFile(path.join(optimizedDir, optimizedFilename));

    await sharp(req.file.buffer)
      .resize(300, 375, { fit: 'cover' })
      .webp({ quality: 70 })
      .toFile(path.join(thumbDir, thumbFilename));

    if (existingImage) {
      // Delete old files
      try { await fs.unlink(path.join(UPLOAD_DIR, '..', existingImage.image_url)); } catch (e) {}
      try { await fs.unlink(path.join(UPLOAD_DIR, '..', existingImage.thumbnail_url)); } catch (e) {}

      // Update record
      existingImage.image_url = `actresses/optimized/${optimizedFilename}`;
      existingImage.thumbnail_url = `actresses/thumbnails/${thumbFilename}`;
      existingImage.file_size = info.size;
      await existingImage.save();

      return res.json({ success: true, message: 'Image updated', data: existingImage });
    } else {
      // Create new record
      const newImage = await ActressImage.create({
        actress_id: actress.id,
        level_number: level,
        title: `${actress.name} - Level ${level}`,
        image_url: `actresses/optimized/${optimizedFilename}`,
        thumbnail_url: `actresses/thumbnails/${thumbFilename}`,
        is_portrait: true,
        width: 1080,
        height: 1350,
        file_size: info.size,
        mime_type: 'image/webp'
      });

      return res.status(201).json({ success: true, message: 'Image uploaded', data: newImage });
    }

  } catch (error) {
    next(error);
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

    try { await fs.unlink(path.join(UPLOAD_ROOT, image.image_url)); } catch (e) {}
    try { await fs.unlink(path.join(UPLOAD_ROOT, image.thumbnail_url)); } catch (e) {}

    await image.destroy({ force: true }); // Hard delete

    res.json({ success: true, message: 'Image deleted' });
  } catch (error) {
    next(error);
  }
};
