import { sequelize } from '../config/database';
import { Level, ActressImage } from '../models'; // Importing ActressImage to ensure it gets sync'd
import { gridSizeForLevel } from '../utilities/levelGrid';

const seedLevels = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Sync schema changes (like adding level_number to ActressImage)
    await sequelize.sync({ alter: true });
    console.log('Schema synced.');

    console.log('Seeding and normalizing 1000 levels...');
    
    // Create levels in bulk for performance
    const levelsToInsert = [];
    for (let i = 1; i <= 1000; i++) {
      let difficulty = 'beginner';
      const gridSize = gridSizeForLevel(i);
      let reward = 10;

      if (i <= 25) {
        difficulty = 'beginner';
        reward = 10;
      } else if (i <= 50) {
        difficulty = 'easy';
        reward = 20;
      } else if (i <= 300) {
        difficulty = 'medium';
        reward = 50;
      } else if (i <= 700) {
        difficulty = 'hard';
        reward = 50;
      } else {
        difficulty = 'expert';
        reward = 100;
      }

      levelsToInsert.push({
        level_number: i,
        title: `Level ${i}`,
        difficulty: difficulty,
        rows: gridSize,
        columns: gridSize,
        shuffle_count: gridSize * gridSize,
        min_stars_required: 1,
        max_moves_3_stars: gridSize * gridSize * 2,
        max_moves_2_stars: gridSize * gridSize * 4,
        reward_points: reward,
        is_locked_default: i !== 1, // Only Level 1 is unlocked initially
        is_active: true
      });
    }

    await Level.bulkCreate(levelsToInsert, {
      updateOnDuplicate: ['rows', 'columns']
    });
    console.log('Seeding complete. Existing level grids were normalized.');
    process.exit(0);
  } catch (error) {
    console.error('Error during seeding:', error);
    process.exit(1);
  }
};

seedLevels();
