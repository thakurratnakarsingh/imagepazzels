import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { SupportTicket, SupportTicketMessage } from '../models/SupportTicket';

export const createTicket = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { subject, category, message } = req.body;
    const userId = req.user.id;

    const ticket = await SupportTicket.create({
      user_id: userId,
      subject,
      category,
      status: 'open'
    });

    await SupportTicketMessage.create({
      ticket_id: ticket.id,
      sender_type: 'user',
      sender_id: userId,
      message
    });

    res.json({
      success: true,
      message: 'Support ticket created successfully',
      data: { ticketId: ticket.id }
    });
  } catch (error) {
    next(error);
  }
};

export const getTickets = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const userId = req.user.id;
    const tickets = await SupportTicket.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']]
    });

    res.json({
      success: true,
      data: tickets
    });
  } catch (error) {
    next(error);
  }
};

export const getTicketMessages = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const ticket = await SupportTicket.findOne({ where: { id, user_id: userId } });
    if (!ticket) return res.status(404).json({ success: false, message: 'Ticket not found' });

    const messages = await SupportTicketMessage.findAll({
      where: { ticket_id: id },
      order: [['created_at', 'ASC']]
    });

    res.json({
      success: true,
      data: messages
    });
  } catch (error) {
    next(error);
  }
};
