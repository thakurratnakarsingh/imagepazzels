import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const apiBaseUrl = env.VITE_API_BASE_URL || 'http://192.168.31.220:5000/api/v1';
  const productionApiOrigin = apiBaseUrl.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');

  return {
    plugins: [react()],
    server: {
      port: 5173,
      host: true,
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
