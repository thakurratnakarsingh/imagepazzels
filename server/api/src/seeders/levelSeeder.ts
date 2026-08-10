import { sequelize } from '../config/database';
import { Level, ActressImage } from '../models'; // Importing ActressImage to ensure it gets sync'd

const seedLevels = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Sync schema changes (like adding level_number to ActressImage)
    await sequelize.sync({ alter: true });
    console.log('Schema synced.');

    // Count existing levels
    const existingCount = await Level.count();
    if (existingCount >= 1000) {
      console.log('1000 levels already exist. Seeding skipped.');
      process.exit(0);
    }

    console.log('Seeding 1000 levels...');
    
    // Create levels in bulk for performance
    const levelsToInsert = [];
    for (let i = 1; i <= 1000; i++) {
      let difficulty = 'beginner';
      let rows = 3;
      let columns = 3;
      let reward = 10;

      if (i <= 250) {
        difficulty = 'easy';
        rows = 3;
        columns = 3;
        reward = 10;
      } else if (i <= 500) {
        difficulty = 'medium';
        rows = 4;
        columns = 4;
        reward = 20;
      } else if (i <= 750) {
        difficulty = 'hard';
        rows = 5;
        columns = 5;
        reward = 50;
      } else {
        difficulty = 'expert';
        rows = 6;
        columns = 6;
        reward = 100;
      }

      levelsToInsert.push({
        level_number: i,
        title: `Level ${i}`,
        difficulty: difficulty,
        rows: rows,
        columns: columns,
        shuffle_count: rows * columns, // simple metric
        min_stars_required: 1,
        max_moves_3_stars: rows * columns * 2,
        max_moves_2_stars: rows * columns * 4,
        reward_points: reward,
        is_locked_default: i !== 1, // Only Level 1 is unlocked initially
        is_active: true
      });
    }

    await Level.bulkCreate(levelsToInsert, { ignoreDuplicates: true });
    console.log('Seeding complete.');
    process.exit(0);
  } catch (error) {
    console.error('Error during seeding:', error);
    process.exit(1);
  }
};

seedLevels();
