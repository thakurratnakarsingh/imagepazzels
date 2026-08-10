import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserLevelAssignment extends Model {
  public id!: number;
  public user_id!: number;
  public level_id!: number;
  public actress_image_id!: number;
  public assigned_at!: Date;
}

UserLevelAssignment.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  level_id: { type: DataTypes.INTEGER, allowNull: false },
  actress_image_id: { type: DataTypes.INTEGER, allowNull: false },
  assigned_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  sequelize,
  tableName: 'user_level_assignments',
  timestamps: false
});

