import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const apiBaseUrl = env.VITE_API_BASE_URL || 'https://vids-libraries-appointment-success.trycloudflare.com/api/v1';
  const productionApiOrigin = apiBaseUrl.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');

  return {
    plugins: [react()],
    server: {
      port: 5173,
      host: true,
      allowedHosts: ['biotechnology-vincent-henderson-additionally.trycloudflare.com'],
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
