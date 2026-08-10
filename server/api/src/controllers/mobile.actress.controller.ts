import { Request, Response, NextFunction } from 'express';
import { Actress, ActressImage } from '../models';

export const getActresses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const actresses = await Actress.findAll({
      where: { is_active: true },
      include: [{
        model: ActressImage,
        as: 'images',
        where: { is_active: true },
        required: false
      }]
    });

    res.json({
      success: true,
      data: actresses
    });
  } catch (error) {
    next(error);
  }
};
