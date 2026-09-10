import { Request, Response, NextFunction } from 'express';
import { Actress, ActressImage } from '../models';
import path from 'path';
import sharp from 'sharp';
import { Op } from 'sequelize';
import { randomUUID } from 'crypto';
import {
  cleanupUploadedTempFiles,
  deleteFileIfExists,
  deleteUploadFileIfExists,
  ensureUploadDir,
  finalizeHashedUpload,
  toUploadRelativePath,
} from '../utilities/uploadStorage';

const thumbnailRelativePath = (filename: string) => (
  toUploadRelativePath('actresses', 'thumbnails', path.basename(filename))
);

const deleteThumbnailIfUnused = async (filename: string | null | undefined) => {
  if (!filename) return;

  const cleanFilename = path.basename(filename);
  const levelThumbnailPath = thumbnailRelativePath(cleanFilename);
  const actressReferences = await Actress.count({ where: { thumbnail_image: cleanFilename } });
  const levelReferences = await ActressImage.count({
    where: {
      [Op.or]: [
        { image_url: levelThumbnailPath },
        { thumbnail_url: levelThumbnailPath },
      ],
    },
  });

  if (actressReferences + levelReferences === 0) {
    await deleteUploadFileIfExists(levelThumbnailPath);
  }
};

export const getAllActresses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const actresses = await Actress.findAll({
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: actresses });
  } catch (error) {
    next(error);
  }
};

export const createActress = async (req: Request, res: Response, next: NextFunction) => {
  let tempThumbnailPath: string | null = null;

  try {
    const { name, biography, country, date_of_birth, is_active, is_featured } = req.body;
    
    if (!name) {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');

    let thumbnailFilename = null;

    if (req.file) {
      const uploadDir = await ensureUploadDir('actresses', 'thumbnails');
      tempThumbnailPath = path.join(uploadDir, `.tmp-${randomUUID()}.webp`);

      await sharp(req.file.path, { sequentialRead: true })
        .resize(300, 300, { fit: 'cover' })
        .webp({ quality: 80 })
        .toFile(tempThumbnailPath);

      const thumbnailFile = await finalizeHashedUpload({
        tempFilePath: tempThumbnailPath,
        targetDir: uploadDir,
        filenamePrefix: 'actress-thumbnail',
      });
      tempThumbnailPath = null;
      thumbnailFilename = thumbnailFile.filename;
    }

    const actress = await Actress.create({
      slug,
      name,
      biography: biography || null,
      country: country || null,
      date_of_birth: date_of_birth || null,
      thumbnail_image: thumbnailFilename,
      is_active: is_active === undefined ? true : (is_active === 'true' || is_active === true),
      is_featured: is_featured === undefined ? false : (is_featured === 'true' || is_featured === true),
    });

    res.status(201).json({ success: true, message: 'Actress created', data: actress });
  } catch (error) {
    await deleteFileIfExists(tempThumbnailPath);
    next(error);
  } finally {
    await cleanupUploadedTempFiles(req);
  }
};

export const updateActress = async (req: Request, res: Response, next: NextFunction) => {
  let tempThumbnailPath: string | null = null;

  try {
    const { id } = req.params;
    const { name, biography, country, date_of_birth, is_active, is_featured } = req.body;

    const actress = await Actress.findByPk(id);
    if (!actress) {
      return res.status(404).json({ success: false, message: 'Actress not found' });
    }

    if (name) {
      actress.name = name;
      actress.slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');
    }
    if (biography !== undefined) actress.biography = biography;
    if (country !== undefined) actress.country = country;
    if (date_of_birth !== undefined) actress.date_of_birth = date_of_birth;
    if (is_active !== undefined) actress.is_active = (is_active === 'true' || is_active === true);
    if (is_featured !== undefined) actress.is_featured = (is_featured === 'true' || is_featured === true);

    if (req.file) {
      const oldThumbnail = actress.thumbnail_image;

      const uploadDir = await ensureUploadDir('actresses', 'thumbnails');
      tempThumbnailPath = path.join(uploadDir, `.tmp-${randomUUID()}.webp`);
      await sharp(req.file.path, { sequentialRead: true })
        .resize(300, 300, { fit: 'cover' })
        .webp({ quality: 80 })
        .toFile(tempThumbnailPath);

      const thumbnailFile = await finalizeHashedUpload({
        tempFilePath: tempThumbnailPath,
        targetDir: uploadDir,
        filenamePrefix: 'actress-thumbnail',
      });
      tempThumbnailPath = null;
      
      actress.thumbnail_image = thumbnailFile.filename;
      await actress.save();
      await deleteThumbnailIfUnused(oldThumbnail);
    } else {
      await actress.save();
    }

    res.json({ success: true, message: 'Actress updated', data: actress });
  } catch (error) {
    await deleteFileIfExists(tempThumbnailPath);
    next(error);
  } finally {
    await cleanupUploadedTempFiles(req);
  }
};

export const deleteActress = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const actress = await Actress.findByPk(id);
    if (!actress) {
      return res.status(404).json({ success: false, message: 'Actress not found' });
    }

    const oldThumbnail = actress.thumbnail_image;

    // Since we're keeping actress_images tied to this actress, we probably want to destroy them too
    // In Sequelize, paranoid mode just sets deletedAt, but for files we might need to delete files manually
    // if we wanted to free up space. For now, just destroy the record.
    await actress.destroy();
    await deleteThumbnailIfUnused(oldThumbnail);

    res.json({ success: true, message: 'Actress deleted' });
  } catch (error) {
    next(error);
  }
};
