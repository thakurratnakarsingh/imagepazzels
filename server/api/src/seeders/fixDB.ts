import { sequelize } from '../config/database';
import { ActressImage } from '../models';

const fix = async () => {
  try {
    await sequelize.authenticate();
    await sequelize.query('UPDATE actress_images SET level_number = id');
    console.log('Fixed existing actress images.');
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

fix();
