import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const productionApiOrigin = 'http://54.167.49.121:5000';

export default defineConfig({
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
  }
});
