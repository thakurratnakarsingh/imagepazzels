import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class ActressImage extends Model {
  declare id: number;
  declare actress_id: number;
  declare title: string;
  declare alt_text: string;
  declare image_url: string;
  declare thumbnail_url: string;
  declare priority: number;
  declare is_active: boolean;
  declare is_portrait: boolean;
  declare width: number;
  declare height: number;
  declare file_size: number;
  declare mime_type: string;
  declare level_number: number;
}

ActressImage.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  actress_id: { type: DataTypes.INTEGER, allowNull: false },
  title: { type: DataTypes.STRING, allowNull: true },
  alt_text: { type: DataTypes.STRING, allowNull: true },
  image_url: { type: DataTypes.STRING, allowNull: false },
  thumbnail_url: { type: DataTypes.STRING, allowNull: false },
  priority: { type: DataTypes.INTEGER, defaultValue: 0 },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  is_portrait: { type: DataTypes.BOOLEAN, defaultValue: true },
  width: { type: DataTypes.INTEGER, allowNull: true },
  height: { type: DataTypes.INTEGER, allowNull: true },
  file_size: { type: DataTypes.INTEGER, allowNull: true },
  mime_type: { type: DataTypes.STRING(50), defaultValue: 'image/jpeg' },
  level_number: { type: DataTypes.INTEGER, allowNull: false },
}, {
  sequelize,
  tableName: 'actress_images',
  timestamps: true,
  paranoid: true,
  underscored: true,
  indexes: [
    {
      unique: true,
      fields: ['actress_id', 'level_number']
    }
  ]
});

