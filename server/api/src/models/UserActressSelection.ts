import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserActressSelection extends Model {
  public id!: number;
  public user_id!: number;
  public actress_id!: number;
}

UserActressSelection.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  actress_id: { type: DataTypes.INTEGER, allowNull: false }
}, {
  sequelize,
  tableName: 'user_actress_selections',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false,
  underscored: true
});

