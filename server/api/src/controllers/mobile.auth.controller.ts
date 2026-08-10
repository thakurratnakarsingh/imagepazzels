import { Request, Response, NextFunction } from 'express';
import { randomUUID } from 'crypto';
import { User } from '../models';
import { generateAccessToken, generateRefreshToken } from '../utilities/jwt';

export const mobileGuestLogin = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const deviceId = typeof req.body?.deviceId === 'string'
      ? req.body.deviceId.trim().slice(0, 255)
      : '';

    // Reuse a guest profile on the same installation so game progress survives relaunches.
    let user = deviceId
      ? await User.findOne({ where: { device_id: deviceId, login_type: 'guest' } })
      : null;

    if (!user) {
      user = await User.create({
        uuid: randomUUID(),
        login_type: 'guest',
        device_id: deviceId || null,
        status: 'active'
      });
    }

    if (user.status !== 'active') {
      return res.status(403).json({ success: false, message: 'This account is not active' });
    }

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
