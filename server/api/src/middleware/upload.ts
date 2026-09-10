import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { randomUUID } from 'crypto';
import { getUploadTempDir } from '../utilities/uploadStorage';

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    const tempDir = getUploadTempDir();
    fs.mkdir(tempDir, { recursive: true }, (error) => cb(error, tempDir));
  },
  filename: (_req, file, cb) => {
    const extension = path.extname(file.originalname).toLowerCase();
    cb(null, `upload-${Date.now()}-${randomUUID()}${extension}`);
  },
});

export const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB default
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPG, PNG and WEBP are allowed.'));
    }
  }
});
