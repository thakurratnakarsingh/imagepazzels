import { Request, Response, NextFunction } from 'express';
import { Actress } from '../models';

export const getActresses = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const actresses = await Actress.findAll({
      attributes: ['id', 'name', 'thumbnail_image', 'is_active'],
      where: { is_active: true },
      order: [['name', 'ASC']],
      raw: true,
    });

    res.json({
      success: true,
      data: actresses
    });
  } catch (error) {
    next(error);
  }
};
