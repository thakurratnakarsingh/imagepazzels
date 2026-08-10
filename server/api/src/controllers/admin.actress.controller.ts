import { Request, Response, NextFunction } from 'express';
import { Actress, ActressImage } from '../models';
import path from 'path';
import fs from 'fs/promises';
import sharp from 'sharp';

// Helper to generate readable timestamps like 20260802-143045
const getReadableTimestamp = () => {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${pad(d.getMonth()+1)}${pad(d.getDate())}-${pad(d.getHours())}${pad(d.getMinutes())}${pad(d.getSeconds())}`;
};

const UPLOAD_DIR = path.join(__dirname, '..', '..', 'uploads', 'actresses', 'thumbnails');

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
  try {
    const { name, biography, country, date_of_birth, is_active, is_featured } = req.body;
    
    if (!name) {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }

    const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, '');

    let thumbnailFilename = null;

    if (req.file) {
      await fs.mkdir(UPLOAD_DIR, { recursive: true });
      thumbnailFilename = `actress-${slug}-${getReadableTimestamp()}.webp`;
      const filepath = path.join(UPLOAD_DIR, thumbnailFilename);

      await sharp(req.file.buffer)
        .resize(300, 300, { fit: 'cover' })
        .webp({ quality: 80 })
        .toFile(filepath);
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
    next(error);
  }
};

export const updateActress = async (req: Request, res: Response, next: NextFunction) => {
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
      // Delete old thumbnail
      if (actress.thumbnail_image) {
        try {
          await fs.unlink(path.join(UPLOAD_DIR, actress.thumbnail_image));
        } catch(e) {}
      }

      await fs.mkdir(UPLOAD_DIR, { recursive: true });
      const thumbnailFilename = `actress-${actress.slug}-${getReadableTimestamp()}.webp`;
      await sharp(req.file.buffer)
        .resize(300, 300, { fit: 'cover' })
        .webp({ quality: 80 })
        .toFile(path.join(UPLOAD_DIR, thumbnailFilename));
      
      actress.thumbnail_image = thumbnailFilename;
    }

    await actress.save();

    res.json({ success: true, message: 'Actress updated', data: actress });
  } catch (error) {
    next(error);
  }
};

export const deleteActress = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const actress = await Actress.findByPk(id);
    if (!actress) {
      return res.status(404).json({ success: false, message: 'Actress not found' });
    }

    if (actress.thumbnail_image) {
      try {
        await fs.unlink(path.join(UPLOAD_DIR, actress.thumbnail_image));
      } catch (e) {}
    }

    // Since we're keeping actress_images tied to this actress, we probably want to destroy them too
    // In Sequelize, paranoid mode just sets deletedAt, but for files we might need to delete files manually
    // if we wanted to free up space. For now, just destroy the record.
    await actress.destroy();

    res.json({ success: true, message: 'Actress deleted' });
  } catch (error) {
    next(error);
  }
};
