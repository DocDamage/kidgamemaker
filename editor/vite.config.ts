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

function readAssetInventory() {
  const inventory: Record<string, unknown[]> = {};
  if (!fs.existsSync(engineAssetsDir)) return inventory;

  for (const category of fs.readdirSync(engineAssetsDir)) {
    const categoryDir = path.join(engineAssetsDir, category);
    if (!fs.statSync(categoryDir).isDirectory() || category.startsWith('_')) continue;
    for (const assetId of fs.readdirSync(categoryDir)) {
      const assetDir = path.join(categoryDir, assetId);
      if (!fs.statSync(assetDir).isDirectory()) continue;
      const sidecarPath = path.join(assetDir, `${assetId}.json`);
      if (!fs.existsSync(sidecarPath)) continue;
      try {
        const sidecar = JSON.parse(fs.readFileSync(sidecarPath, 'utf8'));
        const placement = sidecar.placement_logic || {};
        const summary = {
          id: sidecar.asset_id || assetId,
          name: sidecar.asset_name || assetId,
          category: sidecar.category || category,
          visual: sidecar.visual,
          type: sidecar.runtime_template || sidecar.type,
          sidecar_path: `engine/data/assets/${category}/${assetId}/${assetId}.json`,
          source_pack: sidecar.source_pack,
          source_author: sidecar.source_author || sidecar.creator_name,
          source_collection: sidecar.source_collection || sidecar.source_group,
          is_spritesheet: sidecar.is_spritesheet,
          frames: sidecar.frames,
          snapping_type: placement.snapping_type,
          parallax_bucket: placement.parallax_bucket
        };
        const summaryCategory = String(summary.category);
        inventory[summaryCategory] = [...(inventory[summaryCategory] || []), summary];
      } catch {
        // Skip malformed sidecars in browser preview; backend validation catches these.
      }
    }
  }
  return inventory;
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
        server.middlewares.use('/engine-asset-inventory', (_req, res) => {
          res.setHeader('Content-Type', 'application/json');
          res.end(JSON.stringify(readAssetInventory()));
        });

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
