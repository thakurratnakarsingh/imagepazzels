import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class SupportTicketMessage extends Model {}

SupportTicketMessage.init({
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  ticket_id: { type: DataTypes.STRING },
  sender_type: { type: DataTypes.STRING },
  sender_id: { type: DataTypes.STRING },
  message: { type: DataTypes.STRING },
  attachment_url: { type: DataTypes.STRING }
}, {
  sequelize,
  tableName: 'support_ticket_messages',
  timestamps: true,
  underscored: true
});

