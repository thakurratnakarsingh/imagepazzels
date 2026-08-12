import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

const productionApiOrigin = 'http://34.201.82.188:5000';

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
