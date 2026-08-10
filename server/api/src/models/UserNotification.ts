import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserNotification extends Model {}

UserNotification.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  user_id: { type: DataTypes.STRING },
  notification_id: { type: DataTypes.STRING },
  is_read: { type: DataTypes.STRING },
  read_at: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'user_notifications',
  timestamps: true,
  underscored: true
});

