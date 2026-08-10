import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class PuzzleSession extends Model {
  public id!: string;
  public user_id!: number;
  public level_id!: number;
  public started_at!: Date;
  public last_activity_at!: Date;
  public is_completed!: boolean;
}

PuzzleSession.init({
  id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  level_id: { type: DataTypes.INTEGER, allowNull: false },
  started_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  last_activity_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
  is_completed: { type: DataTypes.BOOLEAN, defaultValue: false }
}, {
  sequelize,
  tableName: 'puzzle_sessions',
  timestamps: false
});

