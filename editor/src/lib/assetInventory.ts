import { toAssetUrl } from './assetUrls';
import type { AssetInventory, ToyboxAsset } from './canvasState';

export function flattenInventory(inventory: AssetInventory): ToyboxAsset[] {
  return Object.values(inventory).flat();
}

export function isStampReadyAsset(asset: ToyboxAsset): boolean {
  if (asset.is_spritesheet) return false;
  if ((asset.frames?.length ?? 0) > 1) return false;
  const frame = asset.frames?.[0];
  if (frame && (frame.w > 128 || frame.h > 128)) return false;

  const searchable = [
    asset.id,
    asset.name,
    asset.visual,
    asset.source_collection,
    asset.source_pack
  ].filter(Boolean).join(' ').toLowerCase();

  return !/(sprite[-_ ]?sheet|spritesheet|atlas|tileset|tilemap|tile[-_ ]?set|sheet\b)/i.test(searchable);
}

export function flattenStampInventory(inventory: AssetInventory): ToyboxAsset[] {
  return flattenInventory(inventory).filter(isStampReadyAsset);
}

export function favoriteInventoryItems(inventory: AssetInventory, favorites: string[]): ToyboxAsset[] {
  return flattenStampInventory(inventory).filter((item) => favorites.includes(item.id));
}

export function quickInventoryItems(inventory: AssetInventory, limit = 8): ToyboxAsset[] {
  return flattenStampInventory(inventory).slice(0, limit);
}

export function findInventoryAsset(inventory: AssetInventory, assetId: string): ToyboxAsset | undefined {
  return flattenInventory(inventory).find((asset) => asset.id === assetId);
}

export function firstInventoryAsset(inventory: AssetInventory): ToyboxAsset | undefined {
  return inventory.terrain?.find(isStampReadyAsset) ?? flattenStampInventory(inventory)[0];
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
