import app from './app';
import { sequelize } from './config/database';
import { runDatabaseMigrations } from './config/databaseMigrations';

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');
    await runDatabaseMigrations();
    console.log('Database migrations are up to date.');
    
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    process.exit(1);
  }
};

startServer();
