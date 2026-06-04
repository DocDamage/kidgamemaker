import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import fs from 'node:fs';
import path from 'node:path';

const engineAssetsDir = path.resolve(__dirname, '../engine/data/assets');

function contentTypeFor(filePath: string): string {
  const extension = path.extname(filePath).toLowerCase();
  if (extension === '.svg') return 'image/svg+xml';
  if (extension === '.png') return 'image/png';
  if (extension === '.jpg' || extension === '.jpeg') return 'image/jpeg';
  if (extension === '.webp') return 'image/webp';
  return 'application/octet-stream';
}

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
    }),
    {
      name: 'kidgamemaker-engine-assets',
      configureServer(server) {
        server.middlewares.use('/engine-assets', (req, res, next) => {
          const urlPath = decodeURIComponent((req.url || '').split('?')[0]).replace(/^\/+/, '');
          const filePath = path.resolve(engineAssetsDir, urlPath);
          if (!filePath.startsWith(engineAssetsDir + path.sep)) {
            res.statusCode = 403;
            res.end('Forbidden');
            return;
          }
          if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) {
            next();
            return;
          }
          res.setHeader('Content-Type', contentTypeFor(filePath));
          fs.createReadStream(filePath).pipe(res);
        });
      }
    }
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
