import { convertFileSrc } from '@tauri-apps/api/core';

export function toAssetUrl(path: string): string {
  const localPath = path.startsWith('res://') ? path.replace('res://', 'engine/') : path;

  try {
    return convertFileSrc(localPath);
  } catch {
    if (localPath.startsWith('engine/data/assets/')) {
      return `/engine-assets/${localPath.slice('engine/data/assets/'.length)}`;
    }
    return localPath;
  }
}
