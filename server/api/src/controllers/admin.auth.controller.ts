import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { Admin } from '../models';
import { generateAdminAccessToken, generateRefreshToken, verifyRefreshToken } from '../utilities/jwt';

export const adminLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;
    
    const admin = await Admin.findOne({ where: { email } });
    if (!admin) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (!admin.is_active) {
      return res.status(403).json({ success: false, message: 'Account is inactive' });
    }

    const adminPassword = admin.getDataValue('password') || admin.password;
    if (!adminPassword) {
      return res.status(500).json({ success: false, message: 'Server error: Password hash not retrieved from database.' });
    }

    const isMatch = await bcrypt.compare(password, adminPassword);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    const payload = { id: admin.id, uuid: admin.uuid, role: admin.role, type: 'admin' as const };
    const accessToken = generateAdminAccessToken(payload);
    const refreshToken = generateRefreshToken(payload);

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        admin: {
          id: admin.id,
          name: admin.name,
          email: admin.email,
          role: admin.role
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

export const refreshAdminToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({ success: false, message: 'Refresh token required' });
    }

    const decoded = verifyRefreshToken(refreshToken);
    if (decoded.type !== 'admin') {
      return res.status(403).json({ success: false, message: 'Admin refresh token required' });
    }

    const admin = await Admin.findByPk(decoded.id);
    if (!admin || !admin.is_active) {
      return res.status(403).json({ success: false, message: 'Admin account is inactive' });
    }

    const payload = { id: admin.id, uuid: admin.uuid, role: admin.role, type: 'admin' as const };
    const accessToken = generateAdminAccessToken(payload);

    res.json({
      success: true,
      message: 'Token refreshed',
      data: { accessToken },
    });
  } catch (error) {
    return res.status(403).json({ success: false, message: 'Invalid or expired refresh token' });
  }
};
