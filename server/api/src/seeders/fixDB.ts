import { sequelize } from '../config/database';
import { runDatabaseMigrations } from '../config/databaseMigrations';

const fix = async () => {
  try {
    await sequelize.authenticate();
    await runDatabaseMigrations();
    console.log('Database migrations are up to date.');
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

fix();
