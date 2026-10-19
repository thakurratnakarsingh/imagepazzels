import path from 'path';
import { gridSizeForLevel } from '../src/utilities/levelGrid';
import { resolveUploadPath, getUploadRoot } from '../src/utilities/uploadStorage';
import { generateAccessToken, generateRefreshToken, verifyAccessToken, verifyRefreshToken } from '../src/utilities/jwt';
import { authenticateAdminToken, authenticateMobileToken } from '../src/middleware/auth';

beforeAll(() => {
  process.env.JWT_ACCESS_SECRET = 'unit-test-access-secret';
  process.env.JWT_REFRESH_SECRET = 'unit-test-refresh-secret';
});

test.each([[1, 3], [25, 3], [26, 4], [50, 4], [51, 5], [1000, 5]])('level %i uses grid %i', (level, size) => {
  expect(gridSizeForLevel(level)).toBe(size);
});

test('upload paths normalize separators and stay inside the upload directory', () => {
  expect(resolveUploadPath('images\\photo.webp')).toBe(path.join(getUploadRoot(), 'images', 'photo.webp'));
  expect(() => resolveUploadPath('../outside.webp')).toThrow('outside upload root');
  expect(() => resolveUploadPath('images/../../outside.webp')).toThrow('outside upload root');
});

test('access and refresh tokens use independent secrets', () => {
  const payload = { id: 7, uuid: 'test-user', type: 'user' as const };
  const access = generateAccessToken(payload);
  const refresh = generateRefreshToken(payload);
  expect(verifyAccessToken(access).id).toBe(7);
  expect(verifyRefreshToken(refresh).id).toBe(7);
  expect(() => verifyAccessToken(refresh)).toThrow();
  expect(() => verifyRefreshToken(access)).toThrow();
  expect(() => verifyAccessToken(`${access}broken`)).toThrow();
});

test.each([
  ['missing', undefined, 401],
  ['malformed', 'Basic token', 401],
  ['invalid', 'Bearer broken', 403],
] as const)('mobile auth rejects %s credentials', (_name, authorization, status) => {
  const res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
  const next = jest.fn();
  authenticateMobileToken({ headers: { authorization } } as any, res as any, next);
  expect(res.status).toHaveBeenCalledWith(status);
  expect(next).not.toHaveBeenCalled();
});

test('admin and user endpoints reject the other account type', () => {
  for (const [type, middleware] of [['user', authenticateAdminToken], ['admin', authenticateMobileToken]] as const) {
    const token = generateAccessToken({ id: 1, uuid: 'test', type });
    const res = { status: jest.fn().mockReturnThis(), json: jest.fn() };
    const next = jest.fn();
    middleware({ headers: { authorization: `Bearer ${token}` } } as any, res as any, next);
    expect(res.status).toHaveBeenCalledWith(403);
    expect(next).not.toHaveBeenCalled();
  }
});

test('valid user token attaches the user and continues', () => {
  const token = generateAccessToken({ id: 8, uuid: 'test', type: 'user' });
  const req: any = { headers: { authorization: `Bearer ${token}` } };
  const next = jest.fn();
  authenticateMobileToken(req, {} as any, next);
  expect(req.user.id).toBe(8);
  expect(next).toHaveBeenCalledTimes(1);
});
