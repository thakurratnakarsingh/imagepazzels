import { Request, Response, NextFunction } from 'express';
import { SplashScreen } from '../models';

export const getActiveSplash = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const splash = await SplashScreen.findOne({
      where: { is_active: true },
      order: [['priority', 'DESC'], ['created_at', 'DESC']]
    });

    if (!splash) {
      return res.json({
        success: true,
        data: null
      });
    }

    const apiBaseUrl = (process.env.API_BASE_URL || 'http://34.201.82.188:5000').replace(/\/$/, '');
    res.json({
      id: splash.id,
      name: splash.name,
      image: `${apiBaseUrl}/uploads/splash/${splash.image_url}`,
      time: splash.time
    });
  } catch (error) {
    next(error);
  }
};
