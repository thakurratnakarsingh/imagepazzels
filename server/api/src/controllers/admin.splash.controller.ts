import { Request, Response, NextFunction } from 'express';
import { SplashScreen } from '../models';
import { sequelize } from '../config/database';
import fs from 'fs/promises';
import path from 'path';
import sharp from 'sharp';

// Helper to generate readable timestamps like 20260802-143045
const getReadableTimestamp = () => {
  const d = new Date();
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${pad(d.getMonth()+1)}${pad(d.getDate())}-${pad(d.getHours())}${pad(d.getMinutes())}${pad(d.getSeconds())}`;
};

const UPLOAD_DIR = path.join(__dirname, '..', '..', 'uploads', 'splash');

export const getAllSplashes = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const splashes = await SplashScreen.findAll({
      order: [['created_at', 'DESC']]
    });
    res.json({ success: true, data: splashes });
  } catch (error) {
    next(error);
  }
};

export const createSplash = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { name, subtitle, time } = req.body;
    
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Image file is required' });
    }
    if (!name) {
      return res.status(400).json({ success: false, message: 'Name is required' });
    }

    const displayTime = time === undefined ? 3 : Number.parseInt(time, 10);
    if (!Number.isInteger(displayTime) || displayTime < 1 || displayTime > 30) {
      return res.status(400).json({ success: false, message: 'Display time must be between 1 and 30 seconds' });
    }

    // Ensure directory exists
    await fs.mkdir(UPLOAD_DIR, { recursive: true });

    // Process image with Sharp
    const filename = `splash-${getReadableTimestamp()}-${Math.round(Math.random() * 1E4)}.webp`;
    const filepath = path.join(UPLOAD_DIR, filename);

    await sharp(req.file.buffer)
      .webp({ quality: 80 })
      .toFile(filepath);

    const splash = await SplashScreen.create({
      name: name,
      subtitle: subtitle || '',
      image_url: filename,
      time: displayTime,
      is_active: false // Defaults to false as per requirements
    });

    res.status(201).json({ success: true, message: 'Splash created', data: splash });
  } catch (error) {
    next(error);
  }
};

export const updateSplash = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { name, subtitle, time } = req.body;

    const splash = await SplashScreen.findByPk(id);
    if (!splash) {
      return res.status(404).json({ success: false, message: 'Splash not found' });
    }

    if (name !== undefined) splash.name = name;
    if (subtitle !== undefined) splash.subtitle = subtitle;
    if (time !== undefined) {
      const displayTime = Number.parseInt(time, 10);
      if (!Number.isInteger(displayTime) || displayTime < 1 || displayTime > 30) {
        return res.status(400).json({ success: false, message: 'Display time must be between 1 and 30 seconds' });
      }
      splash.time = displayTime;
    }

    let oldFilepath = null;
    if (req.file) {
      oldFilepath = path.join(UPLOAD_DIR, splash.image_url);

      // Ensure directory exists
      await fs.mkdir(UPLOAD_DIR, { recursive: true });

      // Process new image with Sharp
      const filename = `splash-${getReadableTimestamp()}-${Math.round(Math.random() * 1E4)}.webp`;
      const filepath = path.join(UPLOAD_DIR, filename);

      await sharp(req.file.buffer)
        .webp({ quality: 80 })
        .toFile(filepath);

      splash.image_url = filename;
    }

    await splash.save();

    // Now that the record is successfully saved, we can delete the old image safely
    if (oldFilepath) {
      try {
        await fs.unlink(oldFilepath);
      } catch (e) {
        console.log('Old file could not be deleted', e);
      }
    }

    res.json({ success: true, message: 'Splash updated', data: splash });
  } catch (error) {
    next(error);
  }
};

export const deleteSplash = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const splash = await SplashScreen.findByPk(id);
    if (!splash) {
      return res.status(404).json({ success: false, message: 'Splash not found' });
    }

    // Attempt to delete file
    try {
      const filepath = path.join(UPLOAD_DIR, splash.image_url);
      await fs.unlink(filepath);
    } catch (e) {
      console.log('File already deleted or not found');
    }

    await splash.destroy();

    res.json({ success: true, message: 'Splash deleted' });
  } catch (error) {
    next(error);
  }
};

export const toggleSplashStatus = async (req: Request, res: Response, next: NextFunction) => {
  const transaction = await sequelize.transaction();
  try {
    const { id } = req.params;

    // Check if splash exists
    const splash = await SplashScreen.findByPk(id, { transaction });
    if (!splash) {
      await transaction.rollback();
      return res.status(404).json({ success: false, message: 'Splash not found' });
    }

    const shouldActivate = !splash.is_active;
    if (shouldActivate) {
      await SplashScreen.update({ is_active: false }, { where: {}, transaction });
    }
    splash.is_active = shouldActivate;
    await splash.save({ transaction });

    await transaction.commit();

    res.json({
      success: true,
      message: shouldActivate ? 'Splash activated successfully' : 'Splash deactivated successfully',
      data: splash
    });
  } catch (error) {
    await transaction.rollback();
    next(error);
  }
};
