import { Model, DataTypes } from 'sequelize';
import { sequelize } from '../config/database';

export class SupportTicket extends Model {
  public id!: number;
  public user_id!: number;
  public subject!: string;
  public category!: string;
  public status!: 'open' | 'in_progress' | 'resolved' | 'closed';
}

SupportTicket.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  user_id: { type: DataTypes.BIGINT, allowNull: false },
  subject: { type: DataTypes.STRING, allowNull: false },
  category: { type: DataTypes.STRING, allowNull: false },
  status: { type: DataTypes.ENUM('open', 'in_progress', 'resolved', 'closed'), defaultValue: 'open' }
}, {
  sequelize,
  tableName: 'support_tickets',
  timestamps: true,
  underscored: true
});

export class SupportTicketMessage extends Model {
  public id!: number;
  public ticket_id!: number;
  public sender_type!: 'user' | 'admin';
  public sender_id!: number;
  public message!: string;
  public attachment_url!: string;
}

SupportTicketMessage.init({
  id: { type: DataTypes.BIGINT, autoIncrement: true, primaryKey: true },
  ticket_id: { type: DataTypes.BIGINT, allowNull: false },
  sender_type: { type: DataTypes.ENUM('user', 'admin'), allowNull: false },
  sender_id: { type: DataTypes.BIGINT, allowNull: false },
  message: { type: DataTypes.TEXT, allowNull: false },
  attachment_url: { type: DataTypes.STRING, allowNull: true }
}, {
  sequelize,
  tableName: 'support_ticket_messages',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: false, // only created_at in schema
  underscored: true
});

// Associations
import { User } from './User';
User.hasMany(SupportTicket, { foreignKey: 'user_id' });
SupportTicket.belongsTo(User, { foreignKey: 'user_id' });

SupportTicket.hasMany(SupportTicketMessage, { foreignKey: 'ticket_id', as: 'messages' });
SupportTicketMessage.belongsTo(SupportTicket, { foreignKey: 'ticket_id' });

