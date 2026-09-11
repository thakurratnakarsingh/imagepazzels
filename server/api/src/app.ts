import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';
import { configureImageProcessing } from './config/imageProcessing';
import { getUploadRoot } from './utilities/uploadStorage';

dotenv.config();

const sharedBaseUrlPath = path.resolve(__dirname, '..', 'base-url.properties');
if (fs.existsSync(sharedBaseUrlPath)) {
  dotenv.config({ path: sharedBaseUrlPath, override: true });
}
configureImageProcessing();

const app = express();
const corsOrigins = [
  'http://localhost:5173',
  'https://admin.actressgamingserver.online',
  process.env.ADMIN_BASE_URL,
  ...(process.env.CORS_ORIGINS || '').split(','),
]
  .filter((origin): origin is string => Boolean(origin))
  .map((origin) => origin.trim())
  .filter(Boolean);

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: false, // allow images to be loaded cross-origin
}));
app.use(cors({
  origin: corsOrigins,
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
const uploadDir = getUploadRoot();
fs.mkdirSync(uploadDir, { recursive: true });
app.use('/uploads', express.static(uploadDir));

import apiRoutes from './routes';

// Base route
app.get('/', (req: Request, res: Response) => {
  res.json({ message: 'Welcome to Actress Puzzle Game API' });
});

// Define routes here eventually
app.use('/api/v1', apiRoutes);

// Global Error Handler
app.use((err: any, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    errors: err.errors || []
  });
});

export default app;
