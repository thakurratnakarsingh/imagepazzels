# Actress Puzzle Game

This repository contains the Actress Puzzle Game project with a backend API, admin portal, and mobile Android client.

## Structure

- `server/api` — Express + TypeScript API, Sequelize models, file uploads, and admin/mobile endpoints.
- `server/admin` — React + Vite admin portal for managing actresses, splash screens, and assets.
- `mobile` — Android project source and Gradle configuration.

## Setup

### API

1. Navigate to `server/api`
2. Copy `.env.example` to `.env` and update values.
3. Install dependencies: `npm install`
4. Run in development: `npm run dev`

### Admin Portal

1. Navigate to `server/admin`
2. Copy `.env.example` to `.env`
3. Install dependencies: `npm install`
4. Run in development: `npm run dev`

## Notes

- The API uses JWT authentication for mobile and admin users.
- Admin routes are protected with a bearer token.
- Image uploads are optimized and stored in the `uploads` folder.
