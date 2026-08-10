import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserSetting extends Model {}

UserSetting.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  user_id: { type: DataTypes.STRING },
  music_enabled: { type: DataTypes.STRING },
  sound_enabled: { type: DataTypes.STRING },
  vibration_enabled: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'user_settings',
  timestamps: true,
  underscored: true
});

