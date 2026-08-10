import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

const app = express();

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: false, // allow images to be loaded cross-origin
}));
app.use(cors({
  origin: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',') : '*',
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
const uploadDir = path.join(__dirname, '..', process.env.UPLOAD_ROOT || 'uploads');
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
