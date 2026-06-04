import { toAssetUrl } from './assetUrls';
import type { AssetInventory, ToyboxAsset } from './canvasState';

export function flattenInventory(inventory: AssetInventory): ToyboxAsset[] {
  return Object.values(inventory).flat();
}

export function favoriteInventoryItems(inventory: AssetInventory, favorites: string[]): ToyboxAsset[] {
  return flattenInventory(inventory).filter((item) => favorites.includes(item.id));
}

export function quickInventoryItems(inventory: AssetInventory, limit = 8): ToyboxAsset[] {
  return flattenInventory(inventory).slice(0, limit);
}

export function findInventoryAsset(inventory: AssetInventory, assetId: string): ToyboxAsset | undefined {
  return flattenInventory(inventory).find((asset) => asset.id === assetId);
}

export function firstInventoryAsset(inventory: AssetInventory): ToyboxAsset | undefined {
  return inventory.terrain?.[0] ?? flattenInventory(inventory)[0];
}

export function isEmojiVisual(visual: string | undefined): boolean {
  if (!visual) return true;
  return !visual.includes('.') && !visual.includes('/') && !visual.includes('\\');
}

export function getInventoryAssetUrl(asset: ToyboxAsset): string {
  if (!asset.visual || isEmojiVisual(asset.visual)) return '';
  if (asset.visual.startsWith('res://')) return toAssetUrl(asset.visual);
  if (!asset.sidecar_path) return asset.visual;
  const lastSlash = Math.max(asset.sidecar_path.lastIndexOf('/'), asset.sidecar_path.lastIndexOf('\\'));
  if (lastSlash === -1) return asset.visual;
  const dir = asset.sidecar_path.substring(0, lastSlash + 1);
  return toAssetUrl(dir + asset.visual);
}
