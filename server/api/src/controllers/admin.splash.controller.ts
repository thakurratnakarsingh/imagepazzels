import { Request, Response, NextFunction } from 'express';
import { SplashScreen } from '../models';
import { sequelize } from '../config/database';
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

const splashFilename = (value: string) => (
  cleanRelativeUploadPath(value).split('/').filter(Boolean).pop() || value
);

const deleteSplashFileIfUnused = async (filename: string | null | undefined) => {
  if (!filename) return;

  const cleanFilename = splashFilename(filename);
  const references = await SplashScreen.count({ where: { image_url: cleanFilename } });
  if (references === 0) {
    await deleteUploadFileIfExists(toUploadRelativePath('splash', cleanFilename));
  }
};

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
  let tempSplashPath: string | null = null;

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

    // Process image with Sharp
    const uploadDir = await ensureUploadDir('splash');
    tempSplashPath = path.join(uploadDir, `.tmp-${randomUUID()}.webp`);

    await sharp(req.file.path, { sequentialRead: true })
      .webp({ quality: 80 })
      .toFile(tempSplashPath);

    const splashFile = await finalizeHashedUpload({
      tempFilePath: tempSplashPath,
      targetDir: uploadDir,
      filenamePrefix: 'splash',
    });
    tempSplashPath = null;

    const splash = await SplashScreen.create({
      name: name,
      subtitle: subtitle || '',
      image_url: splashFile.filename,
      time: displayTime,
      is_active: false // Defaults to false as per requirements
    });

    res.status(201).json({ success: true, message: 'Splash created', data: splash });
  } catch (error) {
    await deleteFileIfExists(tempSplashPath);
    next(error);
  } finally {
    await cleanupUploadedTempFiles(req);
  }
};

export const updateSplash = async (req: Request, res: Response, next: NextFunction) => {
  let tempSplashPath: string | null = null;

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

    let oldFilename: string | null = null;
    if (req.file) {
      oldFilename = splash.image_url;

      // Process new image with Sharp
      const uploadDir = await ensureUploadDir('splash');
      tempSplashPath = path.join(uploadDir, `.tmp-${randomUUID()}.webp`);

      await sharp(req.file.path, { sequentialRead: true })
        .webp({ quality: 80 })
        .toFile(tempSplashPath);

      const splashFile = await finalizeHashedUpload({
        tempFilePath: tempSplashPath,
        targetDir: uploadDir,
        filenamePrefix: 'splash',
      });
      tempSplashPath = null;

      splash.image_url = splashFile.filename;
    }

    await splash.save();

    if (oldFilename && oldFilename !== splash.image_url) {
      await deleteSplashFileIfUnused(oldFilename);
    }

    res.json({ success: true, message: 'Splash updated', data: splash });
  } catch (error) {
    await deleteFileIfExists(tempSplashPath);
    next(error);
  } finally {
    await cleanupUploadedTempFiles(req);
  }
};

export const deleteSplash = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const splash = await SplashScreen.findByPk(id);
    if (!splash) {
      return res.status(404).json({ success: false, message: 'Splash not found' });
    }

    const oldFilename = splash.image_url;

    await splash.destroy();
    await deleteSplashFileIfUnused(oldFilename);

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
