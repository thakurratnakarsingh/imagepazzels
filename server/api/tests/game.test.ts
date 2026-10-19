jest.mock('../src/models', () => Object.fromEntries([
  'Level', 'PuzzleSession', 'UserGameProgress', 'UserLevelAssignment',
  'ActressImage', 'UserActressSelection', 'UserLevelCompletion', 'User',
].map(name => [name, {
  findByPk: jest.fn(), findOne: jest.fn(), findAll: jest.fn(),
  create: jest.fn(), update: jest.fn(), findOrCreate: jest.fn(),
}])));
jest.mock('../src/config/database', () => ({ sequelize: { transaction: jest.fn() } }));

import { completeLevel, getGameLevelImage, saveProgress, startSession } from '../src/controllers/mobile.game.controller';
import { Level, PuzzleSession, UserGameProgress, UserLevelCompletion, ActressImage, User } from '../src/models';
import { sequelize } from '../src/config/database';

const response = () => ({ status: jest.fn().mockReturnThis(), json: jest.fn() });
beforeEach(() => jest.resetAllMocks());

test.each([0, -1, 1001, 1.5, Infinity, NaN, '1'])('rejects invalid level %s before querying storage', async level => {
  const res = response();
  await getGameLevelImage({ body: { level, actress_ids: [1] }, user: { id: 1 } } as any, res as any, jest.fn());
  expect(res.status).toHaveBeenCalledWith(400);
  expect(Level.findOne).not.toHaveBeenCalled();
});

test('starting a session requires an integer level ID', async () => {
  const res = response();
  await startSession({ body: { levelId: '1' }, user: { id: 1 } } as any, res as any, jest.fn());
  expect(res.status).toHaveBeenCalledWith(400);
  expect(PuzzleSession.findOrCreate).not.toHaveBeenCalled();
});

const validProgress = {
  levelId: 1, sessionId: 'session', tileArrangement: [0, 1, 2, 3, 4, 5, 6, 8, 7],
  emptyTileIndex: 7, moveCount: 4, elapsedTimeSeconds: 10,
};
function mockSession() {
  (Level.findByPk as jest.Mock).mockResolvedValue({ level_number: 1 });
  (PuzzleSession.findOne as jest.Mock).mockResolvedValue({ id: 'session' });
  (UserGameProgress.findOne as jest.Mock).mockResolvedValue(null);
}

test.each([
  { tileArrangement: [0, 0, 2, 3, 4, 5, 6, 8, 7] },
  { tileArrangement: [-1, 1, 2, 3, 4, 5, 6, 8, 7] },
  { emptyTileIndex: '7' }, { emptyTileIndex: 8 },
  { moveCount: -1 }, { elapsedTimeSeconds: 1.5 },
])('rejects malformed progress %j', async patch => {
  mockSession();
  const res = response();
  await saveProgress({ body: { ...validProgress, ...patch }, user: { id: 1 } } as any, res as any, jest.fn());
  expect(res.status).toHaveBeenCalledWith(400);
  expect(UserGameProgress.create).not.toHaveBeenCalled();
});

test('does not save progress to another user’s session', async () => {
  mockSession();
  (PuzzleSession.findOne as jest.Mock).mockResolvedValue(null);
  const res = response();
  await saveProgress({ body: validProgress, user: { id: 1 } } as any, res as any, jest.fn());
  expect(res.status).toHaveBeenCalledWith(403);
  expect(UserGameProgress.create).not.toHaveBeenCalled();
  expect(PuzzleSession.findOne).toHaveBeenCalledWith({ where: {
    id: 'session', user_id: 1, level_id: 1, is_completed: false,
  } });
});

test('valid progress is saved with the current user and session', async () => {
  mockSession();
  const res = response(), next = jest.fn();
  await saveProgress({ body: validProgress, user: { id: 1 } } as any, res as any, next);
  expect(next).not.toHaveBeenCalled();
  expect(UserGameProgress.create).toHaveBeenCalledWith(expect.objectContaining({
    user_id: 1, session_id: 'session', move_count: 4,
  }));
  expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Progress saved' });
});

test('repeated completion does not award points twice', async () => {
  const transaction = { LOCK: { UPDATE: 'UPDATE' } };
  (sequelize.transaction as jest.Mock).mockImplementation(callback => callback(transaction));
  const session = { is_completed: true, save: jest.fn() };
  (PuzzleSession.findOne as jest.Mock).mockResolvedValue(session);
  (Level.findByPk as jest.Mock).mockResolvedValue({ level_number: 1 });
  (ActressImage.findOne as jest.Mock).mockResolvedValue({ id: 2 });
  (UserLevelCompletion.findOne as jest.Mock).mockResolvedValue({ stars: 3 });
  const res = response(), next = jest.fn();
  await completeLevel({ body: {
    levelId: 1, imageId: 2, moves: 10, timeTakenSeconds: 30, puzzleSessionId: 'session',
  }, user: { id: 1 } } as any, res as any, next);
  expect(next).not.toHaveBeenCalled();
  expect(UserLevelCompletion.create).not.toHaveBeenCalled();
  expect(User.findByPk).not.toHaveBeenCalled();
  expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
    data: { rewardPointsEarned: 0, stars: 3 },
  }));
});
