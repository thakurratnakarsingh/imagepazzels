import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class Level extends Model {
  public id!: number;
  public level_number!: number;
  public title!: string;
  public difficulty!: 'beginner' | 'easy' | 'medium' | 'hard' | 'expert';
  public rows!: number;
  public columns!: number;
  public shuffle_count!: number;
  public time_limit_seconds!: number | null;
  public min_stars_required!: number;
  public max_moves_3_stars!: number;
  public max_moves_2_stars!: number;
  public reward_points!: number;
  public is_locked_default!: boolean;
  public is_active!: boolean;
  public fixed_image_id!: number | null;
}

Level.init({
  id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
  level_number: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  title: { type: DataTypes.STRING, allowNull: false },
  difficulty: { type: DataTypes.ENUM('beginner', 'easy', 'medium', 'hard', 'expert'), allowNull: false },
  rows: { type: DataTypes.INTEGER, allowNull: false },
  columns: { type: DataTypes.INTEGER, allowNull: false },
  shuffle_count: { type: DataTypes.INTEGER, allowNull: false },
  time_limit_seconds: { type: DataTypes.INTEGER, allowNull: true },
  min_stars_required: { type: DataTypes.INTEGER, defaultValue: 1 },
  max_moves_3_stars: { type: DataTypes.INTEGER, allowNull: false },
  max_moves_2_stars: { type: DataTypes.INTEGER, allowNull: false },
  reward_points: { type: DataTypes.INTEGER, defaultValue: 10 },
  is_locked_default: { type: DataTypes.BOOLEAN, defaultValue: true },
  is_active: { type: DataTypes.BOOLEAN, defaultValue: true },
  fixed_image_id: { type: DataTypes.INTEGER, allowNull: true }
}, {
  sequelize,
  tableName: 'levels',
  timestamps: true,
  paranoid: true,
  underscored: true
});

