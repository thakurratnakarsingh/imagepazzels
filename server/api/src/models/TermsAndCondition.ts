import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class TermsAndCondition extends Model {}

TermsAndCondition.init({
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
  tableName: 'terms_and_conditions',
  timestamps: true,
  underscored: true
});

