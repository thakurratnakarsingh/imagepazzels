# Actress Puzzle Game

This repository contains the Actress Puzzle Game project with a backend API, admin portal, and mobile Android client.

## Structure

- `server/api` — Express + TypeScript API, Sequelize models, file uploads, and admin/mobile endpoints.
- `server/admin` — React + Vite admin portal for managing actresses, splash screens, and assets.
- `mobile` — Android project source and Gradle configuration.

## Setup

Requirements: Node.js 18+, MySQL 8+, JDK 17, and Android SDK 34.

### API

1. Navigate to `server/api`
2. Import `server/database/actress_puzzle_game.sql` into MySQL.
3. Copy `.env.example` to `.env` and set the database, JWT secrets, and `API_BASE_URL`.
4. Install locked dependencies: `npm ci`
5. Run in development: `npm run dev`

### Admin Portal

1. Navigate to `server/admin`
2. Copy `.env.example` to `.env`
3. Install locked dependencies: `npm ci`
4. Run in development: `npm run dev`

### Android app

1. Ensure the API is running and the selected actresses have images uploaded for the levels you want to play.
2. The default API URL is `http://10.0.2.2:5000/`, which reaches the host machine from the Android emulator.
3. For a physical device, add a LAN address to `mobile/gradle.properties`, for example `API_BASE_URL=http://192.168.1.20:5000/`.
4. Build with `cd mobile && ./gradlew assembleDebug` or open the `mobile` directory in Android Studio.

The game supports solvable sliding puzzles, dynamic grid sizes, move/time tracking, local preferences, sound and vibration controls, server-backed save/restore, server-scored completion, rewards, and level advancement.

## Notes

- The API uses JWT authentication for mobile and admin users.
- Admin routes are protected with a bearer token.
- Image uploads are optimized and stored in the `uploads` folder.
- Support email and other runtime values come from the `app_configurations` table. Privacy-policy content comes from the active `privacy_policies` row.
