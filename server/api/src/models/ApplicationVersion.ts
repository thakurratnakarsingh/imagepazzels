import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class ApplicationVersion extends Model {}

ApplicationVersion.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  platform: { type: DataTypes.STRING },
  version_code: { type: DataTypes.STRING },
  release_date: { type: DataTypes.STRING },
  release_notes: { type: DataTypes.STRING },
  is_mandatory: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'application_versions',
  timestamps: true,
  underscored: true
});

