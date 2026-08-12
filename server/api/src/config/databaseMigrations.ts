import { DataTypes, QueryTypes } from 'sequelize';
import { sequelize } from './database';

const ACTRESS_LEVEL_INDEX = 'actress_images_actress_level_unique';

/**
 * Applies small, backward-compatible schema fixes required by the current API.
 * Each migration is idempotent so it is safe to run whenever the API starts.
 */
export const runDatabaseMigrations = async () => {
  const queryInterface = sequelize.getQueryInterface();
  const columns = await queryInterface.describeTable('actress_images');

  if (!columns.level_number) {
    await queryInterface.addColumn('actress_images', 'level_number', {
      type: DataTypes.INTEGER,
      allowNull: true,
    });

    // Preserve old images by assigning levels 1, 2, ... within each actress.
    await sequelize.query(`
      UPDATE actress_images AS target
      INNER JOIN (
        SELECT
          id,
          ROW_NUMBER() OVER (PARTITION BY actress_id ORDER BY id) AS generated_level
        FROM actress_images
      ) AS ranked ON ranked.id = target.id
      SET target.level_number = ranked.generated_level
      WHERE target.level_number IS NULL
    `, { type: QueryTypes.UPDATE });

    await queryInterface.changeColumn('actress_images', 'level_number', {
      type: DataTypes.INTEGER,
      allowNull: false,
    });
  }

  const indexes = await queryInterface.showIndex('actress_images') as Array<{ name: string }>;
  if (!indexes.some((index) => index.name === ACTRESS_LEVEL_INDEX)) {
    await queryInterface.addIndex('actress_images', ['actress_id', 'level_number'], {
      name: ACTRESS_LEVEL_INDEX,
      unique: true,
    });
  }
};
