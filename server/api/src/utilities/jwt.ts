import jwt, { JwtPayload } from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

const getEnvVar = (name: string) => {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable ${name}`);
  }
  return value;
};

export interface TokenPayload extends JwtPayload {
  id: number;
  uuid: string;
  type: 'user' | 'admin';
  role?: string;
}

export const generateAccessToken = (payload: TokenPayload) => {
  return jwt.sign(payload, getEnvVar('JWT_ACCESS_SECRET'), {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m'
  });
};

export const generateRefreshToken = (payload: TokenPayload) => {
  return jwt.sign(payload, getEnvVar('JWT_REFRESH_SECRET'), {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d'
  });
};

export const verifyAccessToken = (token: string) => {
  return jwt.verify(token, getEnvVar('JWT_ACCESS_SECRET')) as TokenPayload;
};
