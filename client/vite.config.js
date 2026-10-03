import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    react(),
    tailwindcss(),
  ],
  server: {
    port: 3000
  },
  // Add this for proper routing in production
  build: {
    outDir: 'dist',
    sourcemap: false
  }
})