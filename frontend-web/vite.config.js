import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    // Mirrors what nginx does in production, so the app uses relative paths
    // and needs no environment variables. AI calls go through /api/ai now,
    // so the AI service needs no proxy of its own.
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
  test: {
    // A browser-like DOM; requests are answered by MSW (src/test/server.js),
    // so the real axios client and interceptors run unmodified.
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.js'],
    coverage: {
      include: ['src/**/*.{js,jsx}'],
      exclude: ['src/test/**', 'src/**/*.test.{js,jsx}', 'src/main.jsx'],
    },
  },
})
