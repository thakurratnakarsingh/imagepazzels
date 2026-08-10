import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class PrivacyPolicy extends Model {}

PrivacyPolicy.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  version: { type: DataTypes.STRING },
  content: { type: DataTypes.STRING },
  is_active: { type: DataTypes.STRING },
  published_at: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'privacy_policies',
  timestamps: true,
  underscored: true
});

