import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class Actress extends Model {
  declare id: number;
  declare slug: string;
  declare name: string;
  declare biography: string;
  declare country: string;
  declare date_of_birth: Date;
  declare thumbnail_image: string;
  declare is_active: boolean;
  declare is_featured: boolean;
}

Actress.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  slug: { type: DataTypes.STRING, allowNull: false, unique: true },
  name: { type: DataTypes.STRING, allowNull: false },
  biography: { type: DataTypes.TEXT, allowNull: true },
  country: { type: DataTypes.STRING(100), allowNull: true },
  date_of_birth: { type: DataTypes.DATEONLY, allowNull: true },
  thumbnail_image: { type: DataTypes.STRING, allowNull: true },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  is_featured: { type: DataTypes.BOOLEAN, defaultValue: false },
}, {
  sequelize,
  tableName: 'actresses',
  timestamps: true,
  paranoid: true,
  underscored: true
});

