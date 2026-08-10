import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { User } from '../models';
import { generateAccessToken, generateRefreshToken } from '../utilities/jwt';

export const mobileGuestLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { deviceId } = req.body; // optionally sent by mobile

    // Create a new guest user
    const user = await User.create({
      uuid: uuidv4(),
      login_type: 'guest',
      device_id: deviceId || null,
      status: 'active'
    });

    const payload = { id: user.id, uuid: user.uuid, type: 'user' as const };
    const accessToken = generateAccessToken(payload);
    const refreshToken = generateRefreshToken(payload);

    res.json({
      success: true,
      message: 'Guest login successful',
      data: {
        user: {
          id: user.id,
          uuid: user.uuid,
          login_type: user.login_type,
          current_level: user.current_level,
          total_points: user.total_points
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};
