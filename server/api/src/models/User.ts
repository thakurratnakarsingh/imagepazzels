import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class User extends Model {
  public id!: number;
  public uuid!: string;
  public name!: string;
  public email!: string;
  public password!: string;
  public profile_image!: string;
  public login_type!: string;
  public device_id!: string;
  public current_level!: number;
  public total_points!: number;
  public status!: string;
}

User.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  uuid: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4 },
  name: { type: DataTypes.STRING, allowNull: true },
  email: { type: DataTypes.STRING, allowNull: true, unique: true },
  password: { type: DataTypes.STRING, allowNull: true },
  profile_image: { type: DataTypes.STRING, allowNull: true },
  login_type: { type: DataTypes.ENUM('email', 'guest'), defaultValue: 'guest' },
  device_id: { type: DataTypes.STRING, allowNull: true },
  current_level: { type: DataTypes.INTEGER, defaultValue: 1 },
  total_points: { type: DataTypes.INTEGER, defaultValue: 0 },
  status: { type: DataTypes.ENUM('active', 'banned', 'inactive'), defaultValue: 'active' },
}, {
  sequelize,
  tableName: 'users',
  timestamps: true,
  paranoid: true,
  underscored: true
});

