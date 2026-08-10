import { Request, Response, NextFunction } from 'express';
import { AppConfiguration } from '../models';

export const getMobileConfig = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const configs = await AppConfiguration.findAll();
    
    // Convert array of key-value to a single object
    const configMap: Record<string, any> = {};
    configs.forEach(conf => {
      let value: any = conf.config_value;
      if (value === 'true') value = true;
      if (value === 'false') value = false;
      // try to parse numbers where appropriate, but string is okay for some
      configMap[conf.config_key] = value;
    });

    res.json({
      success: true,
      data: configMap
    });
  } catch (error) {
    next(error);
  }
};
