import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { Level, UserLevelAssignment, ActressImage, UserActressSelection, PuzzleSession, UserGameProgress, UserLevelCompletion, User } from '../models';
import { v4 as uuidv4 } from 'uuid';
import { Op } from 'sequelize';

export const getLevels = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const levels = await Level.findAll({
      where: { is_active: true },
      order: [['level_number', 'ASC']]
    });

    const completions = await UserLevelCompletion.findAll({
      where: { user_id: req.user.id }
    });

    const completionMap = completions.reduce((acc: any, c) => {
      acc[c.level_id] = c;
      return acc;
    }, {});

    const enrichedLevels = levels.map(level => {
      const comp = completionMap[level.id];
      return {
        id: level.id,
        levelNumber: level.level_number,
        title: level.title,
        difficulty: level.difficulty,
        isCompleted: !!comp,
        stars: comp ? comp.stars : 0,
        isLocked: level.is_locked_default // Additional logic for unlocking next levels can be placed here
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
    const userId = req.user.id;

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
          imageUrl: `${process.env.API_BASE_URL}/uploads/${(assignment as any).image.image_url}`,
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
    const userId = req.user.id;

    // Optional: mark old sessions for this level as abandoned or keep them
    const session = await PuzzleSession.create({
      id: uuidv4(),
      user_id: userId,
      level_id: levelId
    });

    res.json({ success: true, data: { sessionId: session.id } });
  } catch (error) {
    next(error);
  }
};

export const saveProgress = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { levelId, sessionId, tileArrangement, emptyTileIndex, moveCount, elapsedTimeSeconds } = req.body;
    const userId = req.user.id;

    let progress = await UserGameProgress.findOne({ where: { session_id: sessionId } });

    if (progress) {
      progress.tile_arrangement = tileArrangement;
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
    const { levelId, imageId, moves, timeTakenSeconds, stars, puzzleSessionId } = req.body;
    const userId = req.user.id;

    const session = await PuzzleSession.findByPk(puzzleSessionId);
    if (!session || session.is_completed) {
      return res.status(400).json({ success: false, message: 'Invalid or already completed session' });
    }

    const level = await Level.findByPk(levelId);
    if (!level) return res.status(404).json({ success: false, message: 'Level not found' });

    // Prevent duplicate rewards
    const existingCompletion = await UserLevelCompletion.findOne({ where: { user_id: userId, level_id: levelId } });
    
    let pointsToAward = 0;
    if (!existingCompletion) {
      pointsToAward = level.reward_points;
      
      const user = await User.findByPk(userId);
      if (user) {
        user.total_points += pointsToAward;
        user.current_level = Math.max(user.current_level, level.level_number + 1);
        await user.save();
      }
    }

    await UserLevelCompletion.create({
      user_id: userId,
      level_id: levelId,
      session_id: puzzleSessionId,
      actress_image_id: imageId,
      moves,
      time_taken_seconds: timeTakenSeconds,
      stars,
      reward_points_earned: pointsToAward
    });

    session.is_completed = true;
    await session.save();

    res.json({ 
      success: true, 
      message: 'Level completed',
      data: { rewardPointsEarned: pointsToAward }
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

    // Find all images matching the selected actresses and the specific level
    const images = await ActressImage.findAll({
      where: {
        level_number: level,
        actress_id: { [Op.in]: actress_ids },
        is_active: true
      }
    });

    if (images.length === 0) {
      return res.status(404).json({ success: false, message: 'No image found for the selected actresses at this level' });
    }

    // Pick one image randomly if multiple exist
    const randomIndex = Math.floor(Math.random() * images.length);
    const selectedImage = images[randomIndex];

    res.json({
      level: selectedImage.level_number,
      image: {
        id: selectedImage.id,
        actress_id: selectedImage.actress_id,
        image_url: `${process.env.API_BASE_URL}/uploads/${selectedImage.image_url}`
      }
    });
  } catch (error) {
    next(error);
  }
};
