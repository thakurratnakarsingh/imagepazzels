# Public Web Game

This is the browser-playable client for Actress Puzzle Game.

## Run locally

```bash
cd server/web
npm install
npm run dev
```

Open `http://localhost:5177`.

The Vite dev server proxies `/api` and `/uploads` to `API_BASE_URL` from `base-url.properties`.

## App download links

- Direct APK: `public/downloads/actress-puzzle-game.apk`
- Google Play slot: set `PLAY_STORE_URL` in `base-url.properties` or `VITE_PLAY_STORE_URL`
- iOS slot: set `IOS_APP_URL` in `base-url.properties` or `VITE_IOS_APP_URL`

Android visitors automatically get a popup with the APK download button unless they dismiss it.
