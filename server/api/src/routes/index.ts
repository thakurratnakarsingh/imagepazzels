import { Router } from 'express';
import { adminLogin } from '../controllers/admin.auth.controller';
import { mobileGuestLogin } from '../controllers/mobile.auth.controller';
import { getActiveSplash } from '../controllers/mobile.splash.controller';
import { getActresses } from '../controllers/mobile.actress.controller';
import { getMobileConfig, getPrivacyPolicy } from '../controllers/mobile.config.controller';
import { getLevels, getLevelAssignment, startSession, saveProgress, completeLevel, getGameLevelImage } from '../controllers/mobile.game.controller';
import { createTicket, getTickets, getTicketMessages } from '../controllers/mobile.support.controller';
import { upload } from '../middleware/upload';
import { authenticateMobileToken, authenticateAdminToken } from '../middleware/auth';
import { getAllSplashes, createSplash, updateSplash, deleteSplash, toggleSplashStatus } from '../controllers/admin.splash.controller';
import { getAllActresses, createActress, updateActress, deleteActress } from '../controllers/admin.actress.controller';
import { getActressLevels, uploadLevelImage, deleteLevelImage } from '../controllers/admin.actress_image.controller';

const router = Router();

// --- Mobile APIs ---
router.post('/mobile/auth/guest', mobileGuestLogin);
router.get('/mobile/splash/active', getActiveSplash);
router.get('/mobile/actresses', getActresses);
router.get('/mobile/config', getMobileConfig);
router.get('/mobile/privacy-policy', getPrivacyPolicy);

// Mobile Game APIs (Authenticated)
router.post('/mobile/game/level-image', authenticateMobileToken, getGameLevelImage);
router.get('/mobile/game/levels', authenticateMobileToken, getLevels);
router.get('/mobile/game/level/:levelNumber', authenticateMobileToken, getLevelAssignment);
router.post('/mobile/game/session', authenticateMobileToken, startSession);
router.post('/mobile/game/progress', authenticateMobileToken, saveProgress);
router.post('/mobile/game/complete', authenticateMobileToken, completeLevel);

// Mobile Support APIs (Authenticated)
router.post('/mobile/support/tickets', authenticateMobileToken, createTicket);
router.get('/mobile/support/tickets', authenticateMobileToken, getTickets);
router.get('/mobile/support/tickets/:id', authenticateMobileToken, getTicketMessages);

// --- Admin APIs ---
router.post('/admin/auth/login', adminLogin);

// Splash Management APIs
router.get('/admin/splashes', authenticateAdminToken, getAllSplashes);
router.post('/admin/splashes', authenticateAdminToken, upload.single('image'), createSplash);
router.put('/admin/splashes/:id', authenticateAdminToken, upload.single('image'), updateSplash);
router.delete('/admin/splashes/:id', authenticateAdminToken, deleteSplash);
router.patch('/admin/splashes/:id/toggle', authenticateAdminToken, toggleSplashStatus);

// Actress CRUD APIs
router.get('/admin/actresses', authenticateAdminToken, getAllActresses);
router.post('/admin/actresses', authenticateAdminToken, upload.single('thumbnail'), createActress);
router.put('/admin/actresses/:id', authenticateAdminToken, upload.single('thumbnail'), updateActress);
router.delete('/admin/actresses/:id', authenticateAdminToken, deleteActress);

// Actress Levels APIs
router.get('/admin/actresses/:actressId/levels', authenticateAdminToken, getActressLevels);
router.post('/admin/actresses/:actressId/levels/:levelNumber/image', authenticateAdminToken, upload.single('image'), uploadLevelImage);
router.delete('/admin/actresses/:actressId/levels/:levelNumber/image', authenticateAdminToken, deleteLevelImage);

export default router;
