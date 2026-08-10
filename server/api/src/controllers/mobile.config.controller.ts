import { Request, Response, NextFunction } from 'express';
import { AppConfiguration, PrivacyPolicy } from '../models';

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

export const getPrivacyPolicy = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const policy = await PrivacyPolicy.findOne({
      where: { is_active: true },
      order: [['published_at', 'DESC']]
    });
    if (!policy) {
      return res.status(404).json({ success: false, message: 'Privacy policy is not available' });
    }
    res.json({
      success: true,
      data: {
        version: policy.version,
        content: policy.content,
        published_at: policy.published_at
      }
    });
  } catch (error) {
    next(error);
  }
};
