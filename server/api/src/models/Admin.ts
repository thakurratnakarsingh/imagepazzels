import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class Admin extends Model {
  public id!: number;
  public uuid!: string;
  public name!: string;
  public email!: string;
  public password!: string;
  public role!: string;
  public is_active!: boolean;
}

Admin.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  uuid: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4 },
  name: { type: DataTypes.STRING, allowNull: false },
  email: { type: DataTypes.STRING, allowNull: false, unique: true },
  password: { type: DataTypes.STRING, allowNull: false },
  role: { type: DataTypes.ENUM('super_admin', 'admin'), defaultValue: 'admin' },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
}, {
  sequelize,
  tableName: 'admins',
  timestamps: true,
  paranoid: true, // handles deleted_at
  underscored: true
});

