import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { Level, UserLevelAssignment, ActressImage, UserActressSelection, PuzzleSession, UserGameProgress, UserLevelCompletion, User } from '../models';
import { randomUUID } from 'crypto';
import { Op } from 'sequelize';
import { sequelize } from '../config/database';

const assetUrl = (relativePath: string) => {
  const base = (process.env.API_BASE_URL || 'http://localhost:5000').replace(/\/$/, '');
  return `${base}/uploads/${relativePath.replace(/^\//, '')}`;
};

const httpError = (status: number, message: string) =>
  Object.assign(new Error(message), { status });

export const getLevels = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const levels = await Level.findAll({
      where: { is_active: true },
      order: [['level_number', 'ASC']]
    });

    const completions = await UserLevelCompletion.findAll({
      where: { user_id: req.user!.id }
    });

    const completionMap = completions.reduce((acc: any, c) => {
      acc[c.level_id] = c;
      return acc;
    }, {});

    const completedLevelNumbers = new Set(
      levels.filter(level => completionMap[level.id]).map(level => level.level_number)
    );
    const enrichedLevels = levels.map(level => {
      const comp = completionMap[level.id];
      return {
        id: level.id,
        levelNumber: level.level_number,
        title: level.title,
        difficulty: level.difficulty,
        isCompleted: !!comp,
        stars: comp ? comp.stars : 0,
        isLocked: level.level_number > 1 && !completedLevelNumbers.has(level.level_number - 1)
      };
    });

    res.json({ success: true, data: enrichedLevels });
  } catch (error) {
    next(error);
  }
};

export const getLevelAssignment = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { levelNumber } = req.params;
    const userId = req.user!.id;

    const level = await Level.findOne({ where: { level_number: levelNumber, is_active: true } });
    if (!level) return res.status(404).json({ success: false, message: 'Level not found' });

    let assignment = await UserLevelAssignment.findOne({
      where: { user_id: userId, level_id: level.id },
      include: [{ model: ActressImage, as: 'image' }]
    });

    if (!assignment) {
      // Logic to assign an image dynamically
      let imageIdToAssign = level.fixed_image_id;

      if (!imageIdToAssign) {
        const selections = await UserActressSelection.findAll({ where: { user_id: userId } });
        if (selections.length === 0) {
          return res.status(400).json({ success: false, message: 'No actresses selected. Please select an actress first.' });
        }
        
        const actressIds = selections.map(s => s.actress_id);
        
        // Find an image belonging to selected actresses
        const image = await ActressImage.findOne({
          where: { actress_id: { [Op.in]: actressIds }, is_active: true },
          order: [['priority', 'DESC']] // In real app, avoid recently used images
        });
        
        if (!image) {
          return res.status(400).json({ success: false, message: 'No images available for the selected actresses.' });
        }
        
        imageIdToAssign = image.id;
      }

      assignment = await UserLevelAssignment.create({
        user_id: userId,
        level_id: level.id,
        actress_image_id: imageIdToAssign
      });
      
      assignment = await UserLevelAssignment.findByPk(assignment.id, { include: [{ model: ActressImage, as: 'image' }] });
    }

    // Check for saved progress
    const session = await PuzzleSession.findOne({ 
      where: { user_id: userId, level_id: level.id, is_completed: false },
      order: [['started_at', 'DESC']]
    });

    let savedProgress = null;
    if (session) {
      savedProgress = await UserGameProgress.findOne({ where: { session_id: session.id } });
    }

    res.json({
      success: true,
      data: {
        level: {
          id: level.id,
          levelNumber: level.level_number,
          title: level.title,
          difficulty: level.difficulty,
          rows: level.rows,
          columns: level.columns,
          shuffleMoves: level.shuffle_count,
          rewardPoints: level.reward_points
        },
        image: {
          id: (assignment as any).image.id,
          imageUrl: assetUrl((assignment as any).image.image_url),
          width: (assignment as any).image.width,
          height: (assignment as any).image.height
        },
        savedProgress,
        sessionId: session ? session.id : null
      }
    });
  } catch (error) {
    next(error);
  }
};

export const startSession = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { levelId } = req.body;
    const userId = req.user!.id;

    if (!Number.isInteger(levelId)) {
      return res.status(400).json({ success: false, message: 'A valid levelId is required' });
    }
    const level = await Level.findOne({ where: { id: levelId, is_active: true } });
    if (!level) return res.status(404).json({ success: false, message: 'Level not found' });

    const [session] = await PuzzleSession.findOrCreate({
      where: { user_id: userId, level_id: levelId, is_completed: false },
      defaults: { id: randomUUID(), user_id: userId, level_id: levelId }
    });

    res.json({ success: true, data: { sessionId: session.id } });
  } catch (error) {
    next(error);
  }
};

export const saveProgress = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { levelId, sessionId, tileArrangement, emptyTileIndex, moveCount, elapsedTimeSeconds } = req.body;
    const userId = req.user!.id;

    if (!Number.isInteger(levelId) || typeof sessionId !== 'string') {
      return res.status(400).json({ success: false, message: 'Valid levelId and sessionId are required' });
    }

    const [level, session] = await Promise.all([
      Level.findByPk(levelId),
      PuzzleSession.findOne({
        where: { id: sessionId, user_id: userId, level_id: levelId, is_completed: false }
      })
    ]);
    if (!level) return res.status(404).json({ success: false, message: 'Level not found' });
    if (!session) return res.status(403).json({ success: false, message: 'Invalid puzzle session' });

    const tileCount = level.rows * level.columns;
    const validArrangement = Array.isArray(tileArrangement)
      && tileArrangement.length === tileCount
      && tileArrangement.every(Number.isInteger)
      && new Set(tileArrangement).size === tileCount
      && Math.min(...tileArrangement) === 0
      && Math.max(...tileArrangement) === tileCount - 1;
    if (!validArrangement || tileArrangement[emptyTileIndex] !== tileCount - 1) {
      return res.status(400).json({ success: false, message: 'Invalid tile arrangement' });
    }
    if (!Number.isInteger(moveCount) || moveCount < 0 ||
        !Number.isInteger(elapsedTimeSeconds) || elapsedTimeSeconds < 0) {
      return res.status(400).json({ success: false, message: 'Invalid progress counters' });
    }

    let progress = await UserGameProgress.findOne({ where: { user_id: userId, level_id: levelId } });

    if (progress) {
      progress.tile_arrangement = tileArrangement;
      progress.session_id = sessionId;
      progress.empty_tile_index = emptyTileIndex;
      progress.move_count = moveCount;
      progress.elapsed_time_seconds = elapsedTimeSeconds;
      await progress.save();
    } else {
      progress = await UserGameProgress.create({
        user_id: userId,
        level_id: levelId,
        session_id: sessionId,
        tile_arrangement: tileArrangement,
        empty_tile_index: emptyTileIndex,
        move_count: moveCount,
        elapsed_time_seconds: elapsedTimeSeconds
      });
    }
    
    // Update last activity
    await PuzzleSession.update(
      { last_activity_at: new Date() }, 
      { where: { id: sessionId } }
    );

    res.json({ success: true, message: 'Progress saved' });
  } catch (error) {
    next(error);
  }
};

export const completeLevel = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { levelId, imageId, moves, timeTakenSeconds, puzzleSessionId } = req.body;
    const userId = req.user!.id;

    if (![levelId, imageId, moves, timeTakenSeconds].every(Number.isInteger)
        || moves < 0 || timeTakenSeconds < 0 || typeof puzzleSessionId !== 'string') {
      return res.status(400).json({ success: false, message: 'Invalid completion data' });
    }

    const result = await sequelize.transaction(async transaction => {
      const [session, level] = await Promise.all([
        PuzzleSession.findOne({
          where: { id: puzzleSessionId, user_id: userId, level_id: levelId },
          transaction,
          lock: transaction.LOCK.UPDATE
        }),
        Level.findByPk(levelId, { transaction })
      ]);
      if (!session) throw httpError(403, 'Invalid puzzle session');
      if (!level) throw httpError(404, 'Level not found');

      const image = await ActressImage.findOne({
        where: { id: imageId, level_number: level.level_number, is_active: true },
        transaction
      });
      if (!image) throw httpError(400, 'Image does not belong to this level');

      const existingCompletion = await UserLevelCompletion.findOne({
        where: { user_id: userId, level_id: levelId },
        transaction,
        lock: transaction.LOCK.UPDATE
      });
      if (existingCompletion) {
        if (!session.is_completed) {
          session.is_completed = true;
          await session.save({ transaction });
        }
        return {
          message: 'Level was already completed',
          rewardPointsEarned: 0,
          stars: existingCompletion.stars
        };
      }

      if (session.is_completed) throw httpError(400, 'Session is already completed');

      const stars = moves <= level.max_moves_3_stars
        ? 3
        : moves <= level.max_moves_2_stars ? 2 : 1;
      const pointsToAward = level.reward_points;
      const user = await User.findByPk(userId, {
        transaction,
        lock: transaction.LOCK.UPDATE
      });
      if (!user) throw httpError(404, 'User not found');

      await UserLevelCompletion.create({
        user_id: userId,
        level_id: levelId,
        session_id: puzzleSessionId,
        actress_image_id: imageId,
        moves,
        time_taken_seconds: timeTakenSeconds,
        stars,
        reward_points_earned: pointsToAward
      }, { transaction });

      user.total_points += pointsToAward;
      user.current_level = Math.max(user.current_level, level.level_number + 1);
      await user.save({ transaction });

      session.is_completed = true;
      await session.save({ transaction });

      return { message: 'Level completed', rewardPointsEarned: pointsToAward, stars };
    });

    res.json({
      success: true,
      message: result.message,
      data: { rewardPointsEarned: result.rewardPointsEarned, stars: result.stars }
    });
  } catch (error) {
    next(error);
  }
};

export const getGameLevelImage = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { level, actress_ids } = req.body;

    if (!level || typeof level !== 'number' || level < 1 || level > 1000) {
      return res.status(400).json({ success: false, message: 'Valid level number is required' });
    }

    if (!actress_ids || !Array.isArray(actress_ids) || actress_ids.length === 0) {
      return res.status(400).json({ success: false, message: 'actress_ids must be a non-empty array' });
    }

    const uniqueActressIds = [...new Set(actress_ids.filter(Number.isInteger))];
    if (uniqueActressIds.length === 0 || uniqueActressIds.length > 100) {
      return res.status(400).json({ success: false, message: 'actress_ids contains invalid values' });
    }

    const [levelRecord, images] = await Promise.all([
      Level.findOne({ where: { level_number: level, is_active: true } }),
      ActressImage.findAll({
        where: {
          level_number: level,
          actress_id: { [Op.in]: uniqueActressIds },
          is_active: true
        }
      })
    ]);

    if (!levelRecord) {
      return res.status(404).json({ success: false, message: 'Level is not available' });
    }

    const existingAssignment = await UserLevelAssignment.findOne({
      where: { user_id: req.user!.id, level_id: levelRecord.id },
      include: [{ model: ActressImage, as: 'image' }]
    });
    const assignedCandidate = (existingAssignment as any)?.image as ActressImage | undefined;
    const assignedImage = assignedCandidate?.is_active && assignedCandidate.level_number === level
      ? assignedCandidate
      : undefined;

    if (images.length === 0 && !assignedImage) {
      return res.status(404).json({ success: false, message: 'No image found for the selected actresses at this level' });
    }

    // Keep the same image when a saved puzzle is reopened.
    const selectedImage = assignedImage || images[Math.floor(Math.random() * images.length)];
    if (!existingAssignment) {
      await UserLevelAssignment.create({
        user_id: req.user!.id,
        level_id: levelRecord.id,
        actress_image_id: selectedImage.id
      });
    } else if (!assignedImage) {
      existingAssignment.actress_image_id = selectedImage.id;
      await existingAssignment.save();
    }

    let session = await PuzzleSession.findOne({
      where: { user_id: req.user!.id, level_id: levelRecord.id, is_completed: false },
      order: [['last_activity_at', 'DESC']]
    });
    if (!session) {
      session = await PuzzleSession.create({
        id: randomUUID(),
        user_id: req.user!.id,
        level_id: levelRecord.id
      });
    }
    const savedProgress = await UserGameProgress.findOne({
      where: { user_id: req.user!.id, level_id: levelRecord.id, session_id: session.id }
    });

    res.json({
      level: selectedImage.level_number,
      level_id: levelRecord.id,
      rows: levelRecord.rows,
      columns: levelRecord.columns,
      shuffle_moves: levelRecord.shuffle_count,
      max_moves_3_stars: levelRecord.max_moves_3_stars,
      max_moves_2_stars: levelRecord.max_moves_2_stars,
      reward_points: levelRecord.reward_points,
      session_id: session.id,
      saved_progress: savedProgress ? {
        tile_arrangement: savedProgress.tile_arrangement,
        empty_tile_index: savedProgress.empty_tile_index,
        move_count: savedProgress.move_count,
        elapsed_time_seconds: savedProgress.elapsed_time_seconds
      } : null,
      image: {
        id: selectedImage.id,
        actress_id: selectedImage.actress_id,
        image_url: assetUrl(selectedImage.image_url),
        width: selectedImage.width,
        height: selectedImage.height
      }
    });
  } catch (error) {
    next(error);
  }
};
