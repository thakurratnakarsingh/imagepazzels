import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class Notification extends Model {}

Notification.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  title: { type: DataTypes.STRING },
  message: { type: DataTypes.STRING },
  type: { type: DataTypes.STRING },
  is_global: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'notifications',
  timestamps: true,
  underscored: true
});

