import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class SplashScreen extends Model {
  public id!: number;
  public name!: string;
  public subtitle!: string;
  public cta_text!: string;
  public image_url!: string;
  public time!: number;
  public is_active!: boolean;
  public start_date!: Date;
  public end_date!: Date;
  public priority!: number;
}

SplashScreen.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  // Keep the API/admin vocabulary while using the existing production columns.
  name: { type: DataTypes.STRING, allowNull: false, field: 'title' },
  subtitle: { type: DataTypes.STRING, allowNull: true },
  cta_text: { type: DataTypes.STRING, allowNull: true },
  image_url: { type: DataTypes.STRING, allowNull: false },
  time: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 3000,
    field: 'display_duration',
    get() {
      const milliseconds = this.getDataValue('time');
      return Math.max(1, Math.round(milliseconds / 1000));
    },
    set(seconds: number) {
      this.setDataValue('time', Number(seconds) * 1000);
    },
  },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  start_date: { type: DataTypes.DATE, allowNull: true },
  end_date: { type: DataTypes.DATE, allowNull: true },
  priority: { type: DataTypes.INTEGER, defaultValue: 0 },
}, {
  sequelize,
  tableName: 'splash_screens',
  timestamps: true,
  underscored: true
});
