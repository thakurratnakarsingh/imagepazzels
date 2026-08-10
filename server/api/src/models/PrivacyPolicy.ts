import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class PrivacyPolicy extends Model {
  public id!: number;
  public version!: string;
  public content!: string;
  public is_active!: boolean;
  public published_at!: Date;
}

PrivacyPolicy.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  version: { type: DataTypes.STRING(50), allowNull: false },
  content: { type: DataTypes.TEXT, allowNull: false },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  published_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, {
  sequelize,
  tableName: 'privacy_policies',
  timestamps: false,
  underscored: true
});
