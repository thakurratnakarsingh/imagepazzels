import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class AdminRefreshToken extends Model {}

AdminRefreshToken.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  admin_id: { type: DataTypes.STRING },
  token: { type: DataTypes.STRING },
  expires_at: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'admin_refresh_tokens',
  timestamps: true,
  underscored: true
});

