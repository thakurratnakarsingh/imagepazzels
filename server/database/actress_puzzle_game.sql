-- phpMyAdmin SQL Dump
-- Generation Time: 2026-07-25T11:17:04.869Z
-- Database: `actress_puzzle_game`

CREATE DATABASE IF NOT EXISTS `actress_puzzle_game` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `actress_puzzle_game`;

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- --------------------------------------------------------
-- Table structure for table `app_configurations`
-- --------------------------------------------------------
CREATE TABLE `app_configurations` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `config_key` varchar(255) NOT NULL,
  `config_value` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_configurations_config_key_unique` (`config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `app_configurations` (`config_key`, `config_value`) VALUES
('min_supported_app_version', '1.0.0'),
('latest_app_version', '1.0.0'),
('force_update_enabled', 'false'),
('maintenance_mode', 'false'),
('maintenance_message', 'We are currently under maintenance. Please check back later.'),
('support_email', 'support@example.com'),
('privacy_policy_version', '1.0'),
('terms_version', '1.0'),
('max_image_upload_size_mb', '10'),
('banner_advertisement_enabled', 'false'),
('banner_advertisement_provider', 'admob'),
('music_default', 'true'),
('sound_default', 'true'),
('vibration_default', 'true'),
('default_splash_duration', '3000'),
('api_pagination_limit', '20'),
('image_base_url', 'http://192.168.1.10:5000/uploads');

-- --------------------------------------------------------
-- Table structure for table `admins`
-- --------------------------------------------------------
CREATE TABLE `admins` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('super_admin','admin') NOT NULL DEFAULT 'admin',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_email_unique` (`email`),
  UNIQUE KEY `admins_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `admins` (`uuid`, `name`, `email`, `password`, `role`, `is_active`) VALUES
('d1446bd8-0e3c-4144-84c4-754eb5e7f1a5', 'Super Admin', 'admin@example.com', '$2a$12$R9h/cIPz0gi.URNNX3rub.0WvT6bHjI7f7K4A1B8jJbJjY2Z9YkGq', 'super_admin', 1);

-- --------------------------------------------------------
-- Table structure for table `admin_refresh_tokens`
-- --------------------------------------------------------
CREATE TABLE `admin_refresh_tokens` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) UNSIGNED NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `admin_refresh_tokens_admin_id_foreign` (`admin_id`),
  CONSTRAINT `admin_refresh_tokens_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `users`
-- --------------------------------------------------------
CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `login_type` enum('email','guest') NOT NULL DEFAULT 'guest',
  `device_id` varchar(255) DEFAULT NULL,
  `current_level` int(11) NOT NULL DEFAULT 1,
  `total_points` int(11) NOT NULL DEFAULT 0,
  `status` enum('active','banned','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_uuid_unique` (`uuid`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_refresh_tokens`
-- --------------------------------------------------------
CREATE TABLE `user_refresh_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_refresh_tokens_user_id_foreign` (`user_id`),
  CONSTRAINT `user_refresh_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `password_reset_tokens`
-- --------------------------------------------------------
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `splash_screens`
-- --------------------------------------------------------
CREATE TABLE `splash_screens` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `cta_text` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) NOT NULL,
  `display_duration` int(11) NOT NULL DEFAULT 3000,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `priority` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `splash_screens` (`title`, `subtitle`, `cta_text`, `image_url`, `display_duration`, `is_active`) VALUES
('Actress Puzzle', 'Complete the picture', 'Play Now', 'splash-1.jpg', 3000, 1);

-- --------------------------------------------------------
-- Table structure for table `actresses`
-- --------------------------------------------------------
CREATE TABLE `actresses` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `biography` text DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `thumbnail_image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `actresses_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert 10 Sample Actresses
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-1', 'Sample Actress 1', 'Biography for Sample Actress 1', 'USA', 'thumb-1.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-2', 'Sample Actress 2', 'Biography for Sample Actress 2', 'USA', 'thumb-2.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-3', 'Sample Actress 3', 'Biography for Sample Actress 3', 'USA', 'thumb-3.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-4', 'Sample Actress 4', 'Biography for Sample Actress 4', 'USA', 'thumb-4.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-5', 'Sample Actress 5', 'Biography for Sample Actress 5', 'USA', 'thumb-5.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-6', 'Sample Actress 6', 'Biography for Sample Actress 6', 'USA', 'thumb-6.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-7', 'Sample Actress 7', 'Biography for Sample Actress 7', 'USA', 'thumb-7.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-8', 'Sample Actress 8', 'Biography for Sample Actress 8', 'USA', 'thumb-8.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-9', 'Sample Actress 9', 'Biography for Sample Actress 9', 'USA', 'thumb-9.jpg', 1);
INSERT INTO `actresses` (`slug`, `name`, `biography`, `country`, `thumbnail_image`, `is_active`) VALUES ('actress-10', 'Sample Actress 10', 'Biography for Sample Actress 10', 'USA', 'thumb-10.jpg', 1);

-- --------------------------------------------------------
-- Table structure for table `actress_images`
-- --------------------------------------------------------
CREATE TABLE `actress_images` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `actress_id` int(11) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `alt_text` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) NOT NULL,
  `thumbnail_url` varchar(255) NOT NULL,
  `priority` int(11) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_portrait` tinyint(1) NOT NULL DEFAULT 1,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `mime_type` varchar(50) DEFAULT 'image/jpeg',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `actress_images_actress_id_foreign` (`actress_id`),
  CONSTRAINT `actress_images_actress_id_foreign` FOREIGN KEY (`actress_id`) REFERENCES `actresses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert 20 Sample Images (2 per actress)
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (1, 'Image 1 for Actress 1', 'image-1-1.jpg', 'thumb-1-1.jpg', 1080, 1350, 1),
  (1, 'Image 2 for Actress 1', 'image-1-2.jpg', 'thumb-1-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (2, 'Image 1 for Actress 2', 'image-2-1.jpg', 'thumb-2-1.jpg', 1080, 1350, 1),
  (2, 'Image 2 for Actress 2', 'image-2-2.jpg', 'thumb-2-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (3, 'Image 1 for Actress 3', 'image-3-1.jpg', 'thumb-3-1.jpg', 1080, 1350, 1),
  (3, 'Image 2 for Actress 3', 'image-3-2.jpg', 'thumb-3-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (4, 'Image 1 for Actress 4', 'image-4-1.jpg', 'thumb-4-1.jpg', 1080, 1350, 1),
  (4, 'Image 2 for Actress 4', 'image-4-2.jpg', 'thumb-4-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (5, 'Image 1 for Actress 5', 'image-5-1.jpg', 'thumb-5-1.jpg', 1080, 1350, 1),
  (5, 'Image 2 for Actress 5', 'image-5-2.jpg', 'thumb-5-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (6, 'Image 1 for Actress 6', 'image-6-1.jpg', 'thumb-6-1.jpg', 1080, 1350, 1),
  (6, 'Image 2 for Actress 6', 'image-6-2.jpg', 'thumb-6-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (7, 'Image 1 for Actress 7', 'image-7-1.jpg', 'thumb-7-1.jpg', 1080, 1350, 1),
  (7, 'Image 2 for Actress 7', 'image-7-2.jpg', 'thumb-7-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (8, 'Image 1 for Actress 8', 'image-8-1.jpg', 'thumb-8-1.jpg', 1080, 1350, 1),
  (8, 'Image 2 for Actress 8', 'image-8-2.jpg', 'thumb-8-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (9, 'Image 1 for Actress 9', 'image-9-1.jpg', 'thumb-9-1.jpg', 1080, 1350, 1),
  (9, 'Image 2 for Actress 9', 'image-9-2.jpg', 'thumb-9-2.jpg', 1080, 1350, 1);
INSERT INTO `actress_images` (`actress_id`, `title`, `image_url`, `thumbnail_url`, `width`, `height`, `is_active`) VALUES 
  (10, 'Image 1 for Actress 10', 'image-10-1.jpg', 'thumb-10-1.jpg', 1080, 1350, 1),
  (10, 'Image 2 for Actress 10', 'image-10-2.jpg', 'thumb-10-2.jpg', 1080, 1350, 1);

-- --------------------------------------------------------
-- Table structure for table `user_actress_selections`
-- --------------------------------------------------------
CREATE TABLE `user_actress_selections` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `actress_id` int(11) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_actress_unique` (`user_id`,`actress_id`),
  KEY `uas_actress_id_foreign` (`actress_id`),
  CONSTRAINT `uas_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `uas_actress_id_foreign` FOREIGN KEY (`actress_id`) REFERENCES `actresses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `levels`
-- --------------------------------------------------------
CREATE TABLE `levels` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `level_number` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `difficulty` enum('beginner','easy','medium','hard','expert') NOT NULL,
  `rows` int(11) NOT NULL,
  `columns` int(11) NOT NULL,
  `shuffle_count` int(11) NOT NULL,
  `time_limit_seconds` int(11) DEFAULT NULL,
  `min_stars_required` int(11) NOT NULL DEFAULT 1,
  `max_moves_3_stars` int(11) NOT NULL,
  `max_moves_2_stars` int(11) NOT NULL,
  `reward_points` int(11) NOT NULL DEFAULT 10,
  `is_locked_default` tinyint(1) NOT NULL DEFAULT 1,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `fixed_image_id` int(11) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `levels_level_number_unique` (`level_number`),
  KEY `levels_fixed_image_id_foreign` (`fixed_image_id`),
  CONSTRAINT `levels_fixed_image_id_foreign` FOREIGN KEY (`fixed_image_id`) REFERENCES `actress_images` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Generate 1000 levels
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (1, 'Level 1', 'beginner', 3, 3, 50, 75, 125, 30, 0);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (2, 'Level 2', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (3, 'Level 3', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (4, 'Level 4', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (5, 'Level 5', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (6, 'Level 6', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (7, 'Level 7', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (8, 'Level 8', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (9, 'Level 9', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (10, 'Level 10', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (11, 'Level 11', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (12, 'Level 12', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (13, 'Level 13', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (14, 'Level 14', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (15, 'Level 15', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (16, 'Level 16', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (17, 'Level 17', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (18, 'Level 18', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (19, 'Level 19', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (20, 'Level 20', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (21, 'Level 21', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (22, 'Level 22', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (23, 'Level 23', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (24, 'Level 24', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (25, 'Level 25', 'beginner', 3, 3, 50, 75, 125, 30, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (26, 'Level 26', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (27, 'Level 27', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (28, 'Level 28', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (29, 'Level 29', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (30, 'Level 30', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (31, 'Level 31', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (32, 'Level 32', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (33, 'Level 33', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (34, 'Level 34', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (35, 'Level 35', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (36, 'Level 36', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (37, 'Level 37', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (38, 'Level 38', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (39, 'Level 39', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (40, 'Level 40', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (41, 'Level 41', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (42, 'Level 42', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (43, 'Level 43', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (44, 'Level 44', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (45, 'Level 45', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (46, 'Level 46', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (47, 'Level 47', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (48, 'Level 48', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (49, 'Level 49', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (50, 'Level 50', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (51, 'Level 51', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (52, 'Level 52', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (53, 'Level 53', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (54, 'Level 54', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (55, 'Level 55', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (56, 'Level 56', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (57, 'Level 57', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (58, 'Level 58', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (59, 'Level 59', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (60, 'Level 60', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (61, 'Level 61', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (62, 'Level 62', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (63, 'Level 63', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (64, 'Level 64', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (65, 'Level 65', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (66, 'Level 66', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (67, 'Level 67', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (68, 'Level 68', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (69, 'Level 69', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (70, 'Level 70', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (71, 'Level 71', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (72, 'Level 72', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (73, 'Level 73', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (74, 'Level 74', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (75, 'Level 75', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (76, 'Level 76', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (77, 'Level 77', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (78, 'Level 78', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (79, 'Level 79', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (80, 'Level 80', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (81, 'Level 81', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (82, 'Level 82', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (83, 'Level 83', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (84, 'Level 84', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (85, 'Level 85', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (86, 'Level 86', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (87, 'Level 87', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (88, 'Level 88', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (89, 'Level 89', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (90, 'Level 90', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (91, 'Level 91', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (92, 'Level 92', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (93, 'Level 93', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (94, 'Level 94', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (95, 'Level 95', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (96, 'Level 96', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (97, 'Level 97', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (98, 'Level 98', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (99, 'Level 99', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (100, 'Level 100', 'easy', 4, 4, 100, 150, 250, 40, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (101, 'Level 101', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (102, 'Level 102', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (103, 'Level 103', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (104, 'Level 104', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (105, 'Level 105', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (106, 'Level 106', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (107, 'Level 107', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (108, 'Level 108', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (109, 'Level 109', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (110, 'Level 110', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (111, 'Level 111', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (112, 'Level 112', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (113, 'Level 113', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (114, 'Level 114', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (115, 'Level 115', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (116, 'Level 116', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (117, 'Level 117', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (118, 'Level 118', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (119, 'Level 119', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (120, 'Level 120', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (121, 'Level 121', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (122, 'Level 122', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (123, 'Level 123', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (124, 'Level 124', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (125, 'Level 125', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (126, 'Level 126', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (127, 'Level 127', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (128, 'Level 128', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (129, 'Level 129', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (130, 'Level 130', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (131, 'Level 131', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (132, 'Level 132', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (133, 'Level 133', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (134, 'Level 134', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (135, 'Level 135', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (136, 'Level 136', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (137, 'Level 137', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (138, 'Level 138', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (139, 'Level 139', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (140, 'Level 140', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (141, 'Level 141', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (142, 'Level 142', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (143, 'Level 143', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (144, 'Level 144', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (145, 'Level 145', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (146, 'Level 146', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (147, 'Level 147', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (148, 'Level 148', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (149, 'Level 149', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (150, 'Level 150', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (151, 'Level 151', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (152, 'Level 152', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (153, 'Level 153', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (154, 'Level 154', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (155, 'Level 155', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (156, 'Level 156', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (157, 'Level 157', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (158, 'Level 158', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (159, 'Level 159', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (160, 'Level 160', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (161, 'Level 161', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (162, 'Level 162', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (163, 'Level 163', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (164, 'Level 164', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (165, 'Level 165', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (166, 'Level 166', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (167, 'Level 167', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (168, 'Level 168', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (169, 'Level 169', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (170, 'Level 170', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (171, 'Level 171', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (172, 'Level 172', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (173, 'Level 173', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (174, 'Level 174', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (175, 'Level 175', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (176, 'Level 176', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (177, 'Level 177', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (178, 'Level 178', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (179, 'Level 179', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (180, 'Level 180', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (181, 'Level 181', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (182, 'Level 182', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (183, 'Level 183', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (184, 'Level 184', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (185, 'Level 185', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (186, 'Level 186', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (187, 'Level 187', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (188, 'Level 188', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (189, 'Level 189', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (190, 'Level 190', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (191, 'Level 191', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (192, 'Level 192', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (193, 'Level 193', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (194, 'Level 194', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (195, 'Level 195', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (196, 'Level 196', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (197, 'Level 197', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (198, 'Level 198', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (199, 'Level 199', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (200, 'Level 200', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (201, 'Level 201', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (202, 'Level 202', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (203, 'Level 203', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (204, 'Level 204', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (205, 'Level 205', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (206, 'Level 206', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (207, 'Level 207', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (208, 'Level 208', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (209, 'Level 209', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (210, 'Level 210', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (211, 'Level 211', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (212, 'Level 212', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (213, 'Level 213', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (214, 'Level 214', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (215, 'Level 215', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (216, 'Level 216', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (217, 'Level 217', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (218, 'Level 218', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (219, 'Level 219', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (220, 'Level 220', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (221, 'Level 221', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (222, 'Level 222', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (223, 'Level 223', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (224, 'Level 224', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (225, 'Level 225', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (226, 'Level 226', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (227, 'Level 227', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (228, 'Level 228', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (229, 'Level 229', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (230, 'Level 230', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (231, 'Level 231', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (232, 'Level 232', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (233, 'Level 233', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (234, 'Level 234', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (235, 'Level 235', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (236, 'Level 236', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (237, 'Level 237', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (238, 'Level 238', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (239, 'Level 239', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (240, 'Level 240', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (241, 'Level 241', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (242, 'Level 242', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (243, 'Level 243', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (244, 'Level 244', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (245, 'Level 245', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (246, 'Level 246', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (247, 'Level 247', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (248, 'Level 248', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (249, 'Level 249', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (250, 'Level 250', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (251, 'Level 251', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (252, 'Level 252', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (253, 'Level 253', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (254, 'Level 254', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (255, 'Level 255', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (256, 'Level 256', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (257, 'Level 257', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (258, 'Level 258', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (259, 'Level 259', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (260, 'Level 260', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (261, 'Level 261', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (262, 'Level 262', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (263, 'Level 263', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (264, 'Level 264', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (265, 'Level 265', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (266, 'Level 266', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (267, 'Level 267', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (268, 'Level 268', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (269, 'Level 269', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (270, 'Level 270', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (271, 'Level 271', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (272, 'Level 272', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (273, 'Level 273', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (274, 'Level 274', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (275, 'Level 275', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (276, 'Level 276', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (277, 'Level 277', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (278, 'Level 278', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (279, 'Level 279', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (280, 'Level 280', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (281, 'Level 281', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (282, 'Level 282', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (283, 'Level 283', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (284, 'Level 284', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (285, 'Level 285', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (286, 'Level 286', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (287, 'Level 287', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (288, 'Level 288', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (289, 'Level 289', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (290, 'Level 290', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (291, 'Level 291', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (292, 'Level 292', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (293, 'Level 293', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (294, 'Level 294', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (295, 'Level 295', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (296, 'Level 296', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (297, 'Level 297', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (298, 'Level 298', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (299, 'Level 299', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (300, 'Level 300', 'medium', 5, 5, 180, 270, 450, 50, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (301, 'Level 301', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (302, 'Level 302', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (303, 'Level 303', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (304, 'Level 304', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (305, 'Level 305', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (306, 'Level 306', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (307, 'Level 307', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (308, 'Level 308', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (309, 'Level 309', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (310, 'Level 310', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (311, 'Level 311', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (312, 'Level 312', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (313, 'Level 313', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (314, 'Level 314', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (315, 'Level 315', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (316, 'Level 316', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (317, 'Level 317', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (318, 'Level 318', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (319, 'Level 319', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (320, 'Level 320', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (321, 'Level 321', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (322, 'Level 322', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (323, 'Level 323', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (324, 'Level 324', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (325, 'Level 325', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (326, 'Level 326', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (327, 'Level 327', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (328, 'Level 328', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (329, 'Level 329', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (330, 'Level 330', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (331, 'Level 331', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (332, 'Level 332', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (333, 'Level 333', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (334, 'Level 334', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (335, 'Level 335', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (336, 'Level 336', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (337, 'Level 337', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (338, 'Level 338', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (339, 'Level 339', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (340, 'Level 340', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (341, 'Level 341', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (342, 'Level 342', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (343, 'Level 343', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (344, 'Level 344', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (345, 'Level 345', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (346, 'Level 346', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (347, 'Level 347', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (348, 'Level 348', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (349, 'Level 349', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (350, 'Level 350', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (351, 'Level 351', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (352, 'Level 352', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (353, 'Level 353', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (354, 'Level 354', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (355, 'Level 355', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (356, 'Level 356', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (357, 'Level 357', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (358, 'Level 358', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (359, 'Level 359', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (360, 'Level 360', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (361, 'Level 361', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (362, 'Level 362', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (363, 'Level 363', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (364, 'Level 364', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (365, 'Level 365', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (366, 'Level 366', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (367, 'Level 367', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (368, 'Level 368', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (369, 'Level 369', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (370, 'Level 370', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (371, 'Level 371', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (372, 'Level 372', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (373, 'Level 373', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (374, 'Level 374', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (375, 'Level 375', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (376, 'Level 376', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (377, 'Level 377', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (378, 'Level 378', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (379, 'Level 379', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (380, 'Level 380', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (381, 'Level 381', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (382, 'Level 382', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (383, 'Level 383', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (384, 'Level 384', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (385, 'Level 385', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (386, 'Level 386', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (387, 'Level 387', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (388, 'Level 388', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (389, 'Level 389', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (390, 'Level 390', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (391, 'Level 391', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (392, 'Level 392', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (393, 'Level 393', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (394, 'Level 394', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (395, 'Level 395', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (396, 'Level 396', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (397, 'Level 397', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (398, 'Level 398', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (399, 'Level 399', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (400, 'Level 400', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (401, 'Level 401', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (402, 'Level 402', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (403, 'Level 403', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (404, 'Level 404', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (405, 'Level 405', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (406, 'Level 406', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (407, 'Level 407', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (408, 'Level 408', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (409, 'Level 409', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (410, 'Level 410', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (411, 'Level 411', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (412, 'Level 412', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (413, 'Level 413', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (414, 'Level 414', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (415, 'Level 415', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (416, 'Level 416', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (417, 'Level 417', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (418, 'Level 418', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (419, 'Level 419', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (420, 'Level 420', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (421, 'Level 421', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (422, 'Level 422', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (423, 'Level 423', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (424, 'Level 424', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (425, 'Level 425', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (426, 'Level 426', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (427, 'Level 427', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (428, 'Level 428', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (429, 'Level 429', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (430, 'Level 430', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (431, 'Level 431', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (432, 'Level 432', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (433, 'Level 433', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (434, 'Level 434', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (435, 'Level 435', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (436, 'Level 436', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (437, 'Level 437', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (438, 'Level 438', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (439, 'Level 439', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (440, 'Level 440', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (441, 'Level 441', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (442, 'Level 442', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (443, 'Level 443', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (444, 'Level 444', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (445, 'Level 445', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (446, 'Level 446', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (447, 'Level 447', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (448, 'Level 448', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (449, 'Level 449', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (450, 'Level 450', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (451, 'Level 451', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (452, 'Level 452', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (453, 'Level 453', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (454, 'Level 454', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (455, 'Level 455', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (456, 'Level 456', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (457, 'Level 457', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (458, 'Level 458', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (459, 'Level 459', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (460, 'Level 460', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (461, 'Level 461', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (462, 'Level 462', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (463, 'Level 463', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (464, 'Level 464', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (465, 'Level 465', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (466, 'Level 466', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (467, 'Level 467', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (468, 'Level 468', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (469, 'Level 469', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (470, 'Level 470', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (471, 'Level 471', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (472, 'Level 472', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (473, 'Level 473', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (474, 'Level 474', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (475, 'Level 475', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (476, 'Level 476', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (477, 'Level 477', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (478, 'Level 478', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (479, 'Level 479', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (480, 'Level 480', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (481, 'Level 481', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (482, 'Level 482', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (483, 'Level 483', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (484, 'Level 484', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (485, 'Level 485', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (486, 'Level 486', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (487, 'Level 487', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (488, 'Level 488', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (489, 'Level 489', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (490, 'Level 490', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (491, 'Level 491', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (492, 'Level 492', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (493, 'Level 493', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (494, 'Level 494', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (495, 'Level 495', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (496, 'Level 496', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (497, 'Level 497', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (498, 'Level 498', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (499, 'Level 499', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (500, 'Level 500', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (501, 'Level 501', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (502, 'Level 502', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (503, 'Level 503', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (504, 'Level 504', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (505, 'Level 505', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (506, 'Level 506', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (507, 'Level 507', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (508, 'Level 508', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (509, 'Level 509', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (510, 'Level 510', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (511, 'Level 511', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (512, 'Level 512', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (513, 'Level 513', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (514, 'Level 514', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (515, 'Level 515', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (516, 'Level 516', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (517, 'Level 517', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (518, 'Level 518', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (519, 'Level 519', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (520, 'Level 520', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (521, 'Level 521', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (522, 'Level 522', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (523, 'Level 523', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (524, 'Level 524', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (525, 'Level 525', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (526, 'Level 526', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (527, 'Level 527', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (528, 'Level 528', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (529, 'Level 529', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (530, 'Level 530', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (531, 'Level 531', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (532, 'Level 532', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (533, 'Level 533', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (534, 'Level 534', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (535, 'Level 535', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (536, 'Level 536', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (537, 'Level 537', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (538, 'Level 538', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (539, 'Level 539', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (540, 'Level 540', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (541, 'Level 541', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (542, 'Level 542', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (543, 'Level 543', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (544, 'Level 544', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (545, 'Level 545', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (546, 'Level 546', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (547, 'Level 547', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (548, 'Level 548', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (549, 'Level 549', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (550, 'Level 550', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (551, 'Level 551', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (552, 'Level 552', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (553, 'Level 553', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (554, 'Level 554', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (555, 'Level 555', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (556, 'Level 556', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (557, 'Level 557', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (558, 'Level 558', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (559, 'Level 559', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (560, 'Level 560', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (561, 'Level 561', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (562, 'Level 562', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (563, 'Level 563', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (564, 'Level 564', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (565, 'Level 565', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (566, 'Level 566', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (567, 'Level 567', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (568, 'Level 568', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (569, 'Level 569', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (570, 'Level 570', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (571, 'Level 571', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (572, 'Level 572', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (573, 'Level 573', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (574, 'Level 574', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (575, 'Level 575', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (576, 'Level 576', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (577, 'Level 577', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (578, 'Level 578', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (579, 'Level 579', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (580, 'Level 580', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (581, 'Level 581', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (582, 'Level 582', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (583, 'Level 583', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (584, 'Level 584', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (585, 'Level 585', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (586, 'Level 586', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (587, 'Level 587', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (588, 'Level 588', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (589, 'Level 589', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (590, 'Level 590', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (591, 'Level 591', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (592, 'Level 592', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (593, 'Level 593', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (594, 'Level 594', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (595, 'Level 595', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (596, 'Level 596', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (597, 'Level 597', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (598, 'Level 598', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (599, 'Level 599', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (600, 'Level 600', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (601, 'Level 601', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (602, 'Level 602', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (603, 'Level 603', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (604, 'Level 604', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (605, 'Level 605', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (606, 'Level 606', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (607, 'Level 607', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (608, 'Level 608', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (609, 'Level 609', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (610, 'Level 610', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (611, 'Level 611', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (612, 'Level 612', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (613, 'Level 613', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (614, 'Level 614', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (615, 'Level 615', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (616, 'Level 616', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (617, 'Level 617', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (618, 'Level 618', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (619, 'Level 619', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (620, 'Level 620', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (621, 'Level 621', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (622, 'Level 622', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (623, 'Level 623', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (624, 'Level 624', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (625, 'Level 625', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (626, 'Level 626', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (627, 'Level 627', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (628, 'Level 628', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (629, 'Level 629', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (630, 'Level 630', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (631, 'Level 631', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (632, 'Level 632', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (633, 'Level 633', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (634, 'Level 634', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (635, 'Level 635', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (636, 'Level 636', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (637, 'Level 637', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (638, 'Level 638', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (639, 'Level 639', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (640, 'Level 640', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (641, 'Level 641', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (642, 'Level 642', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (643, 'Level 643', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (644, 'Level 644', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (645, 'Level 645', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (646, 'Level 646', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (647, 'Level 647', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (648, 'Level 648', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (649, 'Level 649', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (650, 'Level 650', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (651, 'Level 651', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (652, 'Level 652', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (653, 'Level 653', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (654, 'Level 654', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (655, 'Level 655', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (656, 'Level 656', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (657, 'Level 657', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (658, 'Level 658', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (659, 'Level 659', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (660, 'Level 660', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (661, 'Level 661', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (662, 'Level 662', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (663, 'Level 663', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (664, 'Level 664', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (665, 'Level 665', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (666, 'Level 666', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (667, 'Level 667', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (668, 'Level 668', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (669, 'Level 669', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (670, 'Level 670', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (671, 'Level 671', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (672, 'Level 672', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (673, 'Level 673', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (674, 'Level 674', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (675, 'Level 675', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (676, 'Level 676', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (677, 'Level 677', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (678, 'Level 678', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (679, 'Level 679', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (680, 'Level 680', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (681, 'Level 681', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (682, 'Level 682', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (683, 'Level 683', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (684, 'Level 684', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (685, 'Level 685', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (686, 'Level 686', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (687, 'Level 687', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (688, 'Level 688', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (689, 'Level 689', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (690, 'Level 690', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (691, 'Level 691', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (692, 'Level 692', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (693, 'Level 693', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (694, 'Level 694', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (695, 'Level 695', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (696, 'Level 696', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (697, 'Level 697', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (698, 'Level 698', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (699, 'Level 699', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (700, 'Level 700', 'hard', 6, 6, 280, 420, 700, 60, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (701, 'Level 701', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (702, 'Level 702', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (703, 'Level 703', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (704, 'Level 704', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (705, 'Level 705', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (706, 'Level 706', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (707, 'Level 707', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (708, 'Level 708', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (709, 'Level 709', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (710, 'Level 710', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (711, 'Level 711', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (712, 'Level 712', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (713, 'Level 713', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (714, 'Level 714', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (715, 'Level 715', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (716, 'Level 716', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (717, 'Level 717', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (718, 'Level 718', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (719, 'Level 719', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (720, 'Level 720', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (721, 'Level 721', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (722, 'Level 722', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (723, 'Level 723', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (724, 'Level 724', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (725, 'Level 725', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (726, 'Level 726', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (727, 'Level 727', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (728, 'Level 728', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (729, 'Level 729', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (730, 'Level 730', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (731, 'Level 731', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (732, 'Level 732', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (733, 'Level 733', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (734, 'Level 734', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (735, 'Level 735', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (736, 'Level 736', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (737, 'Level 737', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (738, 'Level 738', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (739, 'Level 739', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (740, 'Level 740', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (741, 'Level 741', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (742, 'Level 742', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (743, 'Level 743', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (744, 'Level 744', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (745, 'Level 745', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (746, 'Level 746', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (747, 'Level 747', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (748, 'Level 748', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (749, 'Level 749', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (750, 'Level 750', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (751, 'Level 751', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (752, 'Level 752', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (753, 'Level 753', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (754, 'Level 754', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (755, 'Level 755', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (756, 'Level 756', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (757, 'Level 757', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (758, 'Level 758', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (759, 'Level 759', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (760, 'Level 760', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (761, 'Level 761', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (762, 'Level 762', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (763, 'Level 763', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (764, 'Level 764', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (765, 'Level 765', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (766, 'Level 766', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (767, 'Level 767', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (768, 'Level 768', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (769, 'Level 769', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (770, 'Level 770', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (771, 'Level 771', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (772, 'Level 772', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (773, 'Level 773', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (774, 'Level 774', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (775, 'Level 775', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (776, 'Level 776', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (777, 'Level 777', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (778, 'Level 778', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (779, 'Level 779', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (780, 'Level 780', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (781, 'Level 781', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (782, 'Level 782', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (783, 'Level 783', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (784, 'Level 784', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (785, 'Level 785', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (786, 'Level 786', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (787, 'Level 787', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (788, 'Level 788', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (789, 'Level 789', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (790, 'Level 790', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (791, 'Level 791', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (792, 'Level 792', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (793, 'Level 793', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (794, 'Level 794', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (795, 'Level 795', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (796, 'Level 796', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (797, 'Level 797', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (798, 'Level 798', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (799, 'Level 799', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (800, 'Level 800', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (801, 'Level 801', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (802, 'Level 802', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (803, 'Level 803', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (804, 'Level 804', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (805, 'Level 805', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (806, 'Level 806', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (807, 'Level 807', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (808, 'Level 808', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (809, 'Level 809', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (810, 'Level 810', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (811, 'Level 811', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (812, 'Level 812', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (813, 'Level 813', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (814, 'Level 814', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (815, 'Level 815', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (816, 'Level 816', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (817, 'Level 817', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (818, 'Level 818', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (819, 'Level 819', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (820, 'Level 820', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (821, 'Level 821', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (822, 'Level 822', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (823, 'Level 823', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (824, 'Level 824', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (825, 'Level 825', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (826, 'Level 826', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (827, 'Level 827', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (828, 'Level 828', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (829, 'Level 829', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (830, 'Level 830', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (831, 'Level 831', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (832, 'Level 832', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (833, 'Level 833', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (834, 'Level 834', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (835, 'Level 835', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (836, 'Level 836', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (837, 'Level 837', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (838, 'Level 838', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (839, 'Level 839', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (840, 'Level 840', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (841, 'Level 841', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (842, 'Level 842', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (843, 'Level 843', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (844, 'Level 844', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (845, 'Level 845', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (846, 'Level 846', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (847, 'Level 847', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (848, 'Level 848', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (849, 'Level 849', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (850, 'Level 850', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (851, 'Level 851', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (852, 'Level 852', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (853, 'Level 853', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (854, 'Level 854', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (855, 'Level 855', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (856, 'Level 856', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (857, 'Level 857', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (858, 'Level 858', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (859, 'Level 859', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (860, 'Level 860', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (861, 'Level 861', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (862, 'Level 862', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (863, 'Level 863', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (864, 'Level 864', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (865, 'Level 865', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (866, 'Level 866', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (867, 'Level 867', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (868, 'Level 868', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (869, 'Level 869', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (870, 'Level 870', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (871, 'Level 871', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (872, 'Level 872', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (873, 'Level 873', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (874, 'Level 874', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (875, 'Level 875', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (876, 'Level 876', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (877, 'Level 877', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (878, 'Level 878', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (879, 'Level 879', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (880, 'Level 880', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (881, 'Level 881', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (882, 'Level 882', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (883, 'Level 883', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (884, 'Level 884', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (885, 'Level 885', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (886, 'Level 886', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (887, 'Level 887', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (888, 'Level 888', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (889, 'Level 889', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (890, 'Level 890', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (891, 'Level 891', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (892, 'Level 892', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (893, 'Level 893', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (894, 'Level 894', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (895, 'Level 895', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (896, 'Level 896', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (897, 'Level 897', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (898, 'Level 898', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (899, 'Level 899', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (900, 'Level 900', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (901, 'Level 901', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (902, 'Level 902', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (903, 'Level 903', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (904, 'Level 904', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (905, 'Level 905', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (906, 'Level 906', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (907, 'Level 907', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (908, 'Level 908', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (909, 'Level 909', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (910, 'Level 910', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (911, 'Level 911', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (912, 'Level 912', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (913, 'Level 913', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (914, 'Level 914', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (915, 'Level 915', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (916, 'Level 916', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (917, 'Level 917', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (918, 'Level 918', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (919, 'Level 919', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (920, 'Level 920', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (921, 'Level 921', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (922, 'Level 922', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (923, 'Level 923', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (924, 'Level 924', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (925, 'Level 925', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (926, 'Level 926', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (927, 'Level 927', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (928, 'Level 928', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (929, 'Level 929', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (930, 'Level 930', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (931, 'Level 931', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (932, 'Level 932', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (933, 'Level 933', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (934, 'Level 934', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (935, 'Level 935', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (936, 'Level 936', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (937, 'Level 937', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (938, 'Level 938', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (939, 'Level 939', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (940, 'Level 940', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (941, 'Level 941', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (942, 'Level 942', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (943, 'Level 943', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (944, 'Level 944', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (945, 'Level 945', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (946, 'Level 946', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (947, 'Level 947', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (948, 'Level 948', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (949, 'Level 949', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (950, 'Level 950', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (951, 'Level 951', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (952, 'Level 952', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (953, 'Level 953', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (954, 'Level 954', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (955, 'Level 955', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (956, 'Level 956', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (957, 'Level 957', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (958, 'Level 958', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (959, 'Level 959', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (960, 'Level 960', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (961, 'Level 961', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (962, 'Level 962', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (963, 'Level 963', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (964, 'Level 964', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (965, 'Level 965', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (966, 'Level 966', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (967, 'Level 967', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (968, 'Level 968', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (969, 'Level 969', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (970, 'Level 970', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (971, 'Level 971', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (972, 'Level 972', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (973, 'Level 973', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (974, 'Level 974', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (975, 'Level 975', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (976, 'Level 976', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (977, 'Level 977', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (978, 'Level 978', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (979, 'Level 979', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (980, 'Level 980', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (981, 'Level 981', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (982, 'Level 982', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (983, 'Level 983', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (984, 'Level 984', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (985, 'Level 985', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (986, 'Level 986', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (987, 'Level 987', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (988, 'Level 988', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (989, 'Level 989', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (990, 'Level 990', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (991, 'Level 991', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (992, 'Level 992', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (993, 'Level 993', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (994, 'Level 994', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (995, 'Level 995', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (996, 'Level 996', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (997, 'Level 997', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (998, 'Level 998', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (999, 'Level 999', 'expert', 7, 7, 400, 600, 1000, 70, 1);
INSERT INTO `levels` (`level_number`, `title`, `difficulty`, `rows`, `columns`, `shuffle_count`, `max_moves_3_stars`, `max_moves_2_stars`, `reward_points`, `is_locked_default`) VALUES (1000, 'Level 1000', 'expert', 7, 7, 400, 600, 1000, 70, 1);

-- --------------------------------------------------------
-- Table structure for table `user_level_assignments`
-- --------------------------------------------------------
CREATE TABLE `user_level_assignments` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `level_id` int(11) UNSIGNED NOT NULL,
  `actress_image_id` int(11) UNSIGNED NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ula_user_level_unique` (`user_id`,`level_id`),
  KEY `ula_user_id_foreign` (`user_id`),
  KEY `ula_level_id_foreign` (`level_id`),
  KEY `ula_image_id_foreign` (`actress_image_id`),
  CONSTRAINT `ula_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ula_level_id_foreign` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ula_image_id_foreign` FOREIGN KEY (`actress_image_id`) REFERENCES `actress_images` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `puzzle_sessions`
-- --------------------------------------------------------
CREATE TABLE `puzzle_sessions` (
  `id` char(36) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `level_id` int(11) UNSIGNED NOT NULL,
  `started_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `last_activity_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `ps_user_id_foreign` (`user_id`),
  KEY `ps_level_id_foreign` (`level_id`),
  CONSTRAINT `ps_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ps_level_id_foreign` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_game_progress`
-- --------------------------------------------------------
CREATE TABLE `user_game_progress` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `level_id` int(11) UNSIGNED NOT NULL,
  `session_id` char(36) NOT NULL,
  `tile_arrangement` json NOT NULL,
  `empty_tile_index` int(11) NOT NULL,
  `move_count` int(11) NOT NULL DEFAULT 0,
  `elapsed_time_seconds` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ugp_user_level_unique` (`user_id`,`level_id`),
  KEY `ugp_session_id_foreign` (`session_id`),
  CONSTRAINT `ugp_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ugp_level_id_foreign` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ugp_session_id_foreign` FOREIGN KEY (`session_id`) REFERENCES `puzzle_sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_level_completions`
-- --------------------------------------------------------
CREATE TABLE `user_level_completions` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `level_id` int(11) UNSIGNED NOT NULL,
  `session_id` char(36) NOT NULL,
  `actress_image_id` int(11) UNSIGNED NOT NULL,
  `moves` int(11) NOT NULL,
  `time_taken_seconds` int(11) NOT NULL,
  `stars` int(11) NOT NULL,
  `reward_points_earned` int(11) NOT NULL,
  `completed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ulc_user_level_unique` (`user_id`,`level_id`),
  KEY `ulc_session_id_foreign` (`session_id`),
  KEY `ulc_image_id_foreign` (`actress_image_id`),
  CONSTRAINT `ulc_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ulc_level_id_foreign` FOREIGN KEY (`level_id`) REFERENCES `levels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ulc_session_id_foreign` FOREIGN KEY (`session_id`) REFERENCES `puzzle_sessions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ulc_image_id_foreign` FOREIGN KEY (`actress_image_id`) REFERENCES `actress_images` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_settings`
-- --------------------------------------------------------
CREATE TABLE `user_settings` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `music_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `sound_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `vibration_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `us_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `support_tickets`
-- --------------------------------------------------------
CREATE TABLE `support_tickets` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `subject` varchar(255) NOT NULL,
  `category` varchar(100) NOT NULL,
  `status` enum('open','in_progress','resolved','closed') NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `st_user_id_foreign` (`user_id`),
  CONSTRAINT `st_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `support_ticket_messages`
-- --------------------------------------------------------
CREATE TABLE `support_ticket_messages` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `sender_type` enum('user','admin') NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `stm_ticket_id_foreign` (`ticket_id`),
  CONSTRAINT `stm_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `privacy_policies`
-- --------------------------------------------------------
CREATE TABLE `privacy_policies` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `version` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `privacy_policies` (`version`, `content`) VALUES ('1.0', 'Sample Privacy Policy Content for Actress Puzzle Game.');

-- --------------------------------------------------------
-- Table structure for table `terms_and_conditions`
-- --------------------------------------------------------
CREATE TABLE `terms_and_conditions` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `version` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `terms_and_conditions` (`version`, `content`) VALUES ('1.0', 'Sample Terms and Conditions for Actress Puzzle Game.');

-- --------------------------------------------------------
-- Table structure for table `audit_logs`
-- --------------------------------------------------------
CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) UNSIGNED DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` varchar(100) DEFAULT NULL,
  `old_values` json DEFAULT NULL,
  `new_values` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `al_admin_id_foreign` (`admin_id`),
  CONSTRAINT `al_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `media_files`
-- --------------------------------------------------------
CREATE TABLE `media_files` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `size_bytes` bigint(20) NOT NULL,
  `path` varchar(500) NOT NULL,
  `uploaded_by` int(11) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `mf_uploaded_by_foreign` (`uploaded_by`),
  CONSTRAINT `mf_uploaded_by_foreign` FOREIGN KEY (`uploaded_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `notifications`
-- --------------------------------------------------------
CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('system','event','promotion') NOT NULL DEFAULT 'system',
  `is_global` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `user_notifications`
-- --------------------------------------------------------
CREATE TABLE `user_notifications` (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `notification_id` bigint(20) UNSIGNED NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `un_user_id_foreign` (`user_id`),
  KEY `un_notification_id_foreign` (`notification_id`),
  CONSTRAINT `un_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `un_notification_id_foreign` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Table structure for table `application_versions`
-- --------------------------------------------------------
CREATE TABLE `application_versions` (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `platform` enum('android','ios') NOT NULL,
  `version_code` varchar(50) NOT NULL,
  `release_date` date NOT NULL,
  `release_notes` text DEFAULT NULL,
  `is_mandatory` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
