import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class MediaFile extends Model {}

MediaFile.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  file_name: { type: DataTypes.STRING },
  original_name: { type: DataTypes.STRING },
  mime_type: { type: DataTypes.STRING },
  size_bytes: { type: DataTypes.STRING },
  path: { type: DataTypes.STRING },
  uploaded_by: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'media_files',
  timestamps: true,
  underscored: true
});

