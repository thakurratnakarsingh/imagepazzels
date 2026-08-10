export * from './Admin';
export * from './User';
export * from './SplashScreen';
export * from './Actress';
export * from './ActressImage';
export * from './AppConfiguration';
export * from './Level';
export * from './UserLevelAssignment';
export * from './PuzzleSession';
export * from './UserGameProgress';
export * from './UserLevelCompletion';
export * from './UserActressSelection';
export * from './SupportTicket';
export * from './PrivacyPolicy';
export * from './TermsAndCondition';

import { Actress } from './Actress';
import { ActressImage } from './ActressImage';
import { User } from './User';
import { Level } from './Level';
import { PuzzleSession } from './PuzzleSession';
import { UserGameProgress } from './UserGameProgress';
import { UserLevelCompletion } from './UserLevelCompletion';
import { UserLevelAssignment } from './UserLevelAssignment';
import { UserActressSelection } from './UserActressSelection';

// Actress <-> ActressImage
Actress.hasMany(ActressImage, { foreignKey: 'actress_id', as: 'images' });
ActressImage.belongsTo(Actress, { foreignKey: 'actress_id', as: 'actress' });

// User <-> UserActressSelection
User.hasMany(UserActressSelection, { foreignKey: 'user_id', as: 'actress_selections' });
UserActressSelection.belongsTo(User, { foreignKey: 'user_id' });

// Actress <-> UserActressSelection
Actress.hasMany(UserActressSelection, { foreignKey: 'actress_id' });
UserActressSelection.belongsTo(Actress, { foreignKey: 'actress_id', as: 'actress' });

// Level <-> ActressImage (Fixed Image)
Level.belongsTo(ActressImage, { foreignKey: 'fixed_image_id', as: 'fixed_image' });

// UserLevelAssignment
User.hasMany(UserLevelAssignment, { foreignKey: 'user_id' });
UserLevelAssignment.belongsTo(User, { foreignKey: 'user_id' });
Level.hasMany(UserLevelAssignment, { foreignKey: 'level_id' });
UserLevelAssignment.belongsTo(Level, { foreignKey: 'level_id' });
ActressImage.hasMany(UserLevelAssignment, { foreignKey: 'actress_image_id' });
UserLevelAssignment.belongsTo(ActressImage, { foreignKey: 'actress_image_id', as: 'image' });

// PuzzleSession
User.hasMany(PuzzleSession, { foreignKey: 'user_id' });
PuzzleSession.belongsTo(User, { foreignKey: 'user_id' });
Level.hasMany(PuzzleSession, { foreignKey: 'level_id' });
PuzzleSession.belongsTo(Level, { foreignKey: 'level_id' });

// UserGameProgress
User.hasMany(UserGameProgress, { foreignKey: 'user_id' });
UserGameProgress.belongsTo(User, { foreignKey: 'user_id' });
Level.hasMany(UserGameProgress, { foreignKey: 'level_id' });
UserGameProgress.belongsTo(Level, { foreignKey: 'level_id' });
PuzzleSession.hasOne(UserGameProgress, { foreignKey: 'session_id' });
UserGameProgress.belongsTo(PuzzleSession, { foreignKey: 'session_id' });

// UserLevelCompletion
User.hasMany(UserLevelCompletion, { foreignKey: 'user_id' });
UserLevelCompletion.belongsTo(User, { foreignKey: 'user_id' });
Level.hasMany(UserLevelCompletion, { foreignKey: 'level_id' });
UserLevelCompletion.belongsTo(Level, { foreignKey: 'level_id' });
PuzzleSession.hasOne(UserLevelCompletion, { foreignKey: 'session_id' });
UserLevelCompletion.belongsTo(PuzzleSession, { foreignKey: 'session_id' });
ActressImage.hasMany(UserLevelCompletion, { foreignKey: 'actress_image_id' });
UserLevelCompletion.belongsTo(ActressImage, { foreignKey: 'actress_image_id' });
