import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class PasswordResetToken extends Model {}

PasswordResetToken.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  email: { type: DataTypes.STRING },
  token: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'password_reset_tokens',
  timestamps: true,
  underscored: true
});

