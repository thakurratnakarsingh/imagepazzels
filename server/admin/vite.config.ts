import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import fs from 'node:fs';
import path from 'node:path';

type BaseUrlConfig = Partial<{
  API_BASE_URL: string;
  ADMIN_BASE_URL: string;
}>;

const readBaseUrls = (): BaseUrlConfig => {
  const filePath = path.resolve(__dirname, 'base-url.properties');
  if (!fs.existsSync(filePath)) return {};

  return Object.fromEntries(
    fs.readFileSync(filePath, 'utf8')
      .split(/\r?\n/)
      .map((line) => line.trim())
      .filter((line) => line && !line.startsWith('#'))
      .map((line) => {
        const separatorIndex = line.indexOf('=');
        return [
          line.slice(0, separatorIndex).trim(),
          line.slice(separatorIndex + 1).trim(),
        ];
      })
  );
};

const toApiV1Url = (apiBaseUrl: string) =>
  `${apiBaseUrl.replace(/\/$/, '')}/api/v1`;

const toHost = (url: string) => {
  try {
    return new URL(url).host;
  } catch {
    return '';
  }
};

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const baseUrls = readBaseUrls();
  const configuredApiBaseUrl = baseUrls.API_BASE_URL
    ? toApiV1Url(baseUrls.API_BASE_URL)
    : undefined;
  const apiBaseUrl = configuredApiBaseUrl
    || env.VITE_API_BASE_URL
    || 'https://vids-libraries-appointment-success.trycloudflare.com/api/v1';
  const productionApiOrigin = apiBaseUrl.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');
  const allowedHost = toHost(baseUrls.ADMIN_BASE_URL || env.ADMIN_BASE_URL || '');

  return {
    plugins: [react()],
    define: {
      __API_BASE_URL__: JSON.stringify(apiBaseUrl),
    },
    server: {
      port: 5173,
      host: true,
      allowedHosts: allowedHost ? [allowedHost] : [],
      proxy: {
        '/api': {
          target: productionApiOrigin,
          changeOrigin: true,
        },
        '/uploads': {
          target: productionApiOrigin,
          changeOrigin: true,
        },
      },
    },
  };
});
