import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserLevelCompletion extends Model {
  public id!: number;
  public user_id!: number;
  public level_id!: number;
  public session_id!: string;
  public actress_image_id!: number;
  public moves!: number;
  public time_taken_seconds!: number;
  public stars!: number;
  public reward_points_earned!: number;
  public completed_at!: Date;
}

UserLevelCompletion.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  level_id: { type: DataTypes.INTEGER, allowNull: false },
  session_id: { type: DataTypes.UUID, allowNull: false },
  actress_image_id: { type: DataTypes.INTEGER, allowNull: false },
  moves: { type: DataTypes.INTEGER, allowNull: false },
  time_taken_seconds: { type: DataTypes.INTEGER, allowNull: false },
  stars: { type: DataTypes.INTEGER, allowNull: false },
  reward_points_earned: { type: DataTypes.INTEGER, allowNull: false },
  completed_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  sequelize,
  tableName: 'user_level_completions',
  timestamps: false
});

