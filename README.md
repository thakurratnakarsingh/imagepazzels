# Actress Puzzle Game

This repository contains the Actress Puzzle Game project with a backend API, admin portal, and mobile Android client.

## Structure

- `server/api` — Express + TypeScript API, Sequelize models, file uploads, and admin/mobile endpoints.
- `server/admin` — React + Vite admin portal for managing actresses, splash screens, and assets.
- `mobile` — Original Android puzzle client.
- `mobile-slide` — Separately installable Android clone with drag-and-drop tile swapping.

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
2. The configured API URL is `http://10.184.70.192:5000/` for devices connected to the same network.
3. If the machine IP changes, update `API_BASE_URL` in `mobile/gradle.properties` and both server `.env` files.
4. Build with `cd mobile && ./gradlew assembleDebug` or open the `mobile` directory in Android Studio.

The game supports solvable sliding puzzles, dynamic grid sizes, move/time tracking, local preferences, sound and vibration controls, server-backed save/restore, server-scored completion, rewards, and level advancement.

### Drag-and-swap Android clone

1. Open `mobile-slide` as a separate project in Android Studio, or run `cd mobile-slide && ./gradlew assembleDebug`.
2. It uses the same `API_BASE_URL` Gradle property and the same mobile API, database, uploaded images, admin configuration, authentication, progress, and completion endpoints as the original client.
3. Its application ID is `com.actresspuzzlegame.slide`, so it can be installed beside the original app.
4. Every image tile remains visible. Drag any tile onto any other tile and release; the two tiles exchange positions, with the displaced tile moving directly back to the dragged tile's original position.
5. Users can select up to 10 models. The selection screen enforces the limit, and the game home screen displays every selected model in a two-row collection.

The clone uses one blue, teal, white, and gold visual system across its splash, login, model selection, home, game, tutorial, completion, and settings experiences.

The debug APK is generated at `mobile-slide/app/build/outputs/apk/debug/app-debug.apk`.

## Notes

- The API uses JWT authentication for mobile and admin users.
- Admin routes are protected with a bearer token.
- Image uploads are optimized and stored in the `uploads` folder.
- Support email and other runtime values come from the `app_configurations` table. Privacy-policy content comes from the active `privacy_policies` row.
