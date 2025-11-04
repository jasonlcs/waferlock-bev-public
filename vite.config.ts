import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
const API_PROXY_TARGET = process.env.VITE_PROXY_TARGET ?? 'https://liveamcore1.waferlock.com:10001';

export default defineConfig({
  plugins: [react()],
  base: '/waferlock-bev-public/',
  server: {
    proxy: {
      '/__waferlock': {
        target: API_PROXY_TARGET,
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/__waferlock/, ''),
      },
    },
  },
});
