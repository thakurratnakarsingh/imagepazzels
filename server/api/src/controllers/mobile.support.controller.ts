import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { SupportTicket, SupportTicketMessage } from '../models/SupportTicket';

export const createTicket = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { subject, category, message } = req.body;
    const userId = req.user!.id;

    if (typeof subject !== 'string' || !subject.trim() || subject.length > 255) {
      return res.status(400).json({ success: false, message: 'A valid subject is required' });
    }
    if (typeof category !== 'string' || !category.trim() || category.length > 100) {
      return res.status(400).json({ success: false, message: 'A valid category is required' });
    }
    if (typeof message !== 'string' || !message.trim() || message.length > 5000) {
      return res.status(400).json({ success: false, message: 'A valid message is required' });
    }

    const ticket = await SupportTicket.create({
      user_id: userId,
      subject: subject.trim(),
      category: category.trim(),
      status: 'open'
    });

    await SupportTicketMessage.create({
      ticket_id: ticket.id,
      sender_type: 'user',
      sender_id: userId,
      message: message.trim()
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
    const userId = req.user!.id;
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
    const userId = req.user!.id;

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
