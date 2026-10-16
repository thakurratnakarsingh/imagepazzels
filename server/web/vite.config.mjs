import { defineConfig, loadEnv } from 'vite';
import fs from 'node:fs';
import path from 'node:path';

const readBaseUrls = () => {
  const filePath = path.resolve(process.cwd(), 'base-url.properties');
  if (!fs.existsSync(filePath)) return {};

  return Object.fromEntries(
    fs.readFileSync(filePath, 'utf8')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter((line) => line && !line.startsWith('#') && line.includes('='))
      .map((line) => {
        const separatorIndex = line.indexOf('=');
        return [
          line.slice(0, separatorIndex).trim(),
          line.slice(separatorIndex + 1).trim(),
        ];
      })
  );
};

const toApiV1Url = (apiBaseUrl) =>
  `${apiBaseUrl.replace(/\/$/, '')}/api/v1`;

const toHost = (url) => {
  try {
    return new URL(url).host;
  } catch {
    return '';
  }
};

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const baseUrls = readBaseUrls();
  const configuredApiBaseUrl = mode !== 'production' && baseUrls.API_BASE_URL
    ? toApiV1Url(baseUrls.API_BASE_URL)
    : undefined;
  const apiBaseUrl = env.VITE_API_BASE_URL
    || configuredApiBaseUrl
    || 'https://api.actressgamingserver.online/api/v1';
  const apiOrigin = apiBaseUrl.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');
  const webHost = toHost(baseUrls.WEB_BASE_URL || env.WEB_BASE_URL || '');
  const allowedHosts = [
    webHost,
    'actressgamingserver.online',
    'www.actressgamingserver.online',
    'adultactresspuzzles.fun',
    'www.adultactresspuzzles.fun',
  ]
    .filter(Boolean);

  return {
    define: {
      __API_BASE_URL__: JSON.stringify(apiBaseUrl),
      __APK_DOWNLOAD_URL__: JSON.stringify(
        env.VITE_APK_DOWNLOAD_URL || baseUrls.APK_DOWNLOAD_URL || '/downloads/actress-puzzle-game.apk'
      ),
      __PLAY_STORE_URL__: JSON.stringify(env.VITE_PLAY_STORE_URL || baseUrls.PLAY_STORE_URL || ''),
      __IOS_APP_URL__: JSON.stringify(env.VITE_IOS_APP_URL || baseUrls.IOS_APP_URL || ''),
    },
    server: {
      port: 5177,
      host: true,
      allowedHosts,
      proxy: {
        '/api': {
          target: apiOrigin,
          changeOrigin: true,
        },
        '/uploads': {
          target: apiOrigin,
          changeOrigin: true,
        },
      },
    },
    preview: {
      host: true,
      port: 5177,
      allowedHosts,
    },
  };
});
