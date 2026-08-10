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

    res.json({
      id: splash.id,
      name: splash.name,
      image: `${process.env.API_BASE_URL}/uploads/splash/${splash.image_url}`,
      time: splash.time
    });
  } catch (error) {
    next(error);
  }
};
