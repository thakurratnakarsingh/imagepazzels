import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { Admin } from '../models';
import { generateAccessToken, generateRefreshToken } from '../utilities/jwt';

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
    const accessToken = generateAccessToken(payload);
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
