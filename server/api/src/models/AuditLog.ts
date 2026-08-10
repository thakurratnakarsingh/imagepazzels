import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class AuditLog extends Model {}

AuditLog.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  admin_id: { type: DataTypes.STRING },
  action: { type: DataTypes.STRING },
  entity_type: { type: DataTypes.STRING },
  entity_id: { type: DataTypes.STRING },
  old_values: { type: DataTypes.STRING },
  new_values: { type: DataTypes.STRING },
  ip_address: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'audit_logs',
  timestamps: true,
  underscored: true
});

