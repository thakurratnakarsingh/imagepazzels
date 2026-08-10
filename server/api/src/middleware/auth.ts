import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, TokenPayload } from '../utilities/jwt';

export interface AuthRequest extends Request {
  user?: TokenPayload;
}

const getTokenFromHeader = (header?: string) => {
  if (!header) return null;
  const parts = header.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') return null;
  return parts[1];
};

export const authenticateMobileToken = (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = getTokenFromHeader(req.headers['authorization']);
  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  try {
    const decoded = verifyAccessToken(token);
    if (decoded.type !== 'user') {
      return res.status(403).json({ success: false, message: 'Invalid token payload' });
    }
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ success: false, message: 'Invalid or expired token' });
  }
};

export const authenticateAdminToken = (req: AuthRequest, res: Response, next: NextFunction) => {
  const token = getTokenFromHeader(req.headers['authorization']);
  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  try {
    const decoded = verifyAccessToken(token);
    if (decoded.type !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin access required' });
    }
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ success: false, message: 'Invalid or expired token' });
  }
};
