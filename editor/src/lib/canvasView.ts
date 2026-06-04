import type { PlacedEntity, ToyboxAsset, Vec2, WorldSettings } from './canvasState';

export const CATEGORY_COLORS: Record<string, string> = {
  heroes: '#60a5fa',
  terrain: '#6b7280',
  enemies: '#f87171',
  collectibles: '#fbbf24',
  portals: '#a78bfa',
  decorations: '#34d399',
  particles: '#c084fc'
};

export function calculateLevelLengthLabel(placed: PlacedEntity[]): string {
  const terrains = placed.filter((ent) => ent.category === 'terrain' || ent.type === 'terrain');
  if (terrains.length === 0) return '🎈 Empty Room';

  let minX = Infinity;
  let maxX = -Infinity;
  for (const ent of terrains) {
    if (ent.position.x < minX) minX = ent.position.x;
    if (ent.position.x > maxX) maxX = ent.position.x;
  }

  const width = maxX - minX;
  if (width < 800) return '🎈 Short Adventure';
  if (width < 1800) return '🚀 Medium Adventure';
  if (width < 3000) return '🏰 Long Quest';
  return '👑 Epic Quest!';
}

export function getCanvasCoords(clientX: number, clientY: number, rect: DOMRect, offsetX: number, offsetY: number, zoom: number): Vec2 {
  const screenX = clientX - rect.left;
  const screenY = clientY - rect.top;
  return {
    x: (screenX - offsetX) / zoom,
    y: (screenY - offsetY) / zoom
  };
}

export function getSnappedPosition(rawCoords: Vec2, asset: ToyboxAsset, placed: PlacedEntity[], snapEnabled: boolean): Vec2 {
  if (!snapEnabled) return rawCoords;

  const snapping = asset.snapping_type ?? (asset.category === 'terrain' ? 'edge_to_edge' : 'gravity_snap');
  if (snapping === 'edge_to_edge') {
    return {
      x: Math.round(rawCoords.x / 32) * 32,
      y: Math.round(rawCoords.y / 32) * 32
    };
  }

  const snapX = Math.round(rawCoords.x / 8) * 8;
  if (snapping !== 'gravity_snap') {
    return {
      x: snapX,
      y: Math.round(rawCoords.y / 8) * 8
    };
  }
  let stampHeight = asset.category === 'heroes' ? 48 : 32;
  if (asset.frames?.[0]) {
    stampHeight = asset.frames[0].h;
  }

  let bestTopY: number | null = null;
  for (const item of placed) {
    if (item.category !== 'terrain') continue;

    const left = item.position.x - 64;
    const right = item.position.x + 64;
    if (snapX < left || snapX > right) continue;

    const topEdge = item.position.y - 16;
    if (topEdge >= rawCoords.y - 16 && (bestTopY === null || topEdge < bestTopY)) {
      bestTopY = topEdge;
    }
  }

  if (bestTopY !== null) {
    return {
      x: snapX,
      y: bestTopY - stampHeight / 2
    };
  }

  return {
    x: snapX,
    y: Math.round(rawCoords.y / 8) * 8
  };
}

export function generateRoomThumbnail(roomId: string, placed: PlacedEntity[], worldSettings: WorldSettings): void {
  try {
    const canvas = document.createElement('canvas');
    canvas.width = 160;
    canvas.height = 90;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    ctx.fillStyle = roomBackgroundColor(worldSettings);
    ctx.fillRect(0, 0, 160, 90);

    if (placed.length === 0) {
      localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
      return;
    }

    const xs = placed.map((entity) => entity.position.x);
    const ys = placed.map((entity) => entity.position.y);
    const minX = Math.min(...xs) - 32;
    const minY = Math.min(...ys) - 32;
    const rangeX = Math.max(...xs) - minX + 64;
    const rangeY = Math.max(...ys) - minY + 64;
    const scale = Math.min(160 / rangeX, 90 / rangeY);

    for (const entity of placed) {
      const px = (entity.position.x - minX) * scale;
      const py = (entity.position.y - minY) * scale;
      ctx.fillStyle = CATEGORY_COLORS[entity.category] ?? '#94a3b8';
      if (entity.category === 'terrain') {
        ctx.fillRect(px - 6, py - 2, 12, 4);
      } else {
        ctx.beginPath();
        ctx.arc(px, py, entity.category === 'heroes' ? 5 : 3, 0, Math.PI * 2);
        ctx.fill();
      }
    }

    localStorage.setItem(`thumb_${roomId}`, canvas.toDataURL());
  } catch {
    // Thumbnails are an editor convenience; storage/canvas failures should not block editing.
  }
}

export function getStoredThumbnail(roomId: string): string | null {
  try {
    return localStorage.getItem(`thumb_${roomId}`);
  } catch {
    return null;
  }
}

function roomBackgroundColor(worldSettings: WorldSettings): string {
  if (worldSettings.time_of_day === 'night') return '#0f172a';
  if (worldSettings.time_of_day === 'sunset') return '#7c2d12';
  if (worldSettings.time_of_day === 'morning') return '#164e63';
  return '#1e3a5f';
}
