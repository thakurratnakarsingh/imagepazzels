import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserGameProgress extends Model {
  public id!: number;
  public user_id!: number;
  public level_id!: number;
  public session_id!: string;
  public tile_arrangement!: any;
  public empty_tile_index!: number;
  public move_count!: number;
  public elapsed_time_seconds!: number;
}

UserGameProgress.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  level_id: { type: DataTypes.INTEGER, allowNull: false },
  session_id: { type: DataTypes.UUID, allowNull: false },
  tile_arrangement: { type: DataTypes.JSON, allowNull: false },
  empty_tile_index: { type: DataTypes.INTEGER, allowNull: false },
  move_count: { type: DataTypes.INTEGER, defaultValue: 0 },
  elapsed_time_seconds: { type: DataTypes.INTEGER, defaultValue: 0 }
}, {
  sequelize,
  tableName: 'user_game_progress',
  timestamps: true,
  createdAt: false, // only updated_at in schema
  updatedAt: 'updated_at',
  underscored: true
});

