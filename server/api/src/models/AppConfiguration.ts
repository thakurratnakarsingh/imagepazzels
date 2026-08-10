import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class AppConfiguration extends Model {
  public id!: number;
  public config_key!: string;
  public config_value!: string;
}

AppConfiguration.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  config_key: { type: DataTypes.STRING, allowNull: false, unique: true },
  config_value: { type: DataTypes.TEXT, allowNull: false },
}, {
  sequelize,
  tableName: 'app_configurations',
  timestamps: true,
  underscored: true
});

