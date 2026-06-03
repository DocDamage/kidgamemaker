import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [
    svelte({
      onwarn(warning, defaultHandler) {
        if (warning.code?.startsWith('a11y_')) return;
        if (warning.code?.startsWith('a11y-')) return;
        if (warning.code === 'css_unused_selector' || warning.code === 'css-unused-selector') return;
        if (defaultHandler) {
          defaultHandler(warning);
        }
      }
    })
  ],
  clearScreen: false,
  server: {
    port: 5173,
    strictPort: true
  },
  envPrefix: ['VITE_', 'TAURI_'],
  build: {
    target: process.env.TAURI_PLATFORM === 'windows' ? 'chrome105' : 'safari13',
    minify: !process.env.TAURI_DEBUG,
    sourcemap: Boolean(process.env.TAURI_DEBUG)
  }
});
