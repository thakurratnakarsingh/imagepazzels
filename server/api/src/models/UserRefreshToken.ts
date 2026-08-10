import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class UserRefreshToken extends Model {}

UserRefreshToken.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  user_id: { type: DataTypes.STRING },
  token: { type: DataTypes.STRING },
  expires_at: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'user_refresh_tokens',
  timestamps: true,
  underscored: true
});

