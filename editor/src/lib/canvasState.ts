export type Vec2 = {
  x: number;
  y: number;
};

export type PlacedEntity = {
  instance_id: string;
  asset_id: string;
  category: string;
  type: string;
  position: Vec2;
  is_camera_target?: boolean;
  modifiers: {
    variant: string;
    scale_multiplier: number;
    target_room?: string;
    target_portal?: string;
  };
};

export type ToyboxAsset = {
  id: string;
  name: string;
  category: string;
  visual?: string;
  type?: string;
  sidecar_path?: string;
  is_spritesheet?: boolean;
  frames?: Array<{ x: number; y: number; w: number; h: number }>;
  snapping_type?: string;
};

export type AssetInventory = Record<string, ToyboxAsset[]>;

export type WorldSettings = {
  time_of_day: 'day' | 'morning' | 'sunset' | 'night';
  weather: 'clear' | 'rain' | 'snow';
};

export type RoomPayload = {
  schema_version: 1;
  project_id: string;
  room_id: string;
  world_settings: WorldSettings;
  entities: PlacedEntity[];
};

export function makeInstanceId(prefix = 'entity'): string {
  const safePrefix = prefix.replace(/[^a-zA-Z0-9_]/g, '_');
  const randomPart = globalThis.crypto?.randomUUID?.() ?? Math.random().toString(16).slice(2);
  return `${safePrefix}_${randomPart}`;
}

export function snapPosition(point: Vec2, snapSize = 8, enabled = true): Vec2 {
  if (!enabled) return point;

  return {
    x: Math.round(point.x / snapSize) * snapSize,
    y: Math.round(point.y / snapSize) * snapSize
  };
}

export function stampEntity(
  current: PlacedEntity[],
  asset: ToyboxAsset,
  position: Vec2,
  options: Partial<PlacedEntity> = {}
): PlacedEntity[] {
  const entity: PlacedEntity = {
    instance_id: makeInstanceId(asset.id),
    asset_id: asset.id,
    category: asset.category,
    type: options.type ?? asset.type ?? asset.category,
    position,
    is_camera_target: options.is_camera_target ?? asset.category === 'heroes',
    modifiers: {
      variant: 'default',
      scale_multiplier: 1.0,
      ...(options.modifiers ?? {})
    }
  };

  return [...current, entity];
}

export function eraseEntity(current: PlacedEntity[], instanceId: string): PlacedEntity[] {
  return current.filter((item) => item.instance_id !== instanceId);
}

export function toRoomPayload(
  entities: PlacedEntity[],
  worldSettings?: WorldSettings,
  projectId = 'demo_project',
  roomId = 'test_chamber_01'
): RoomPayload {
  return {
    schema_version: 1,
    project_id: projectId,
    room_id: roomId,
    world_settings: worldSettings ?? { time_of_day: 'day', weather: 'clear' },
    entities
  };
}

export const fallbackInventory: AssetInventory = {
  heroes: [{ id: 'hero_knight', name: 'Hero Knight', category: 'heroes', visual: '🛡️', type: 'player', snapping_type: 'gravity_snap' }],
  terrain: [{ id: 'stone_floor', name: 'Stone Floor', category: 'terrain', visual: '🪨', type: 'terrain', snapping_type: 'edge_to_edge' }],
  enemies: [{ id: 'slime_patrol', name: 'Slime Patrol', category: 'enemies', visual: '👾', type: 'enemy', snapping_type: 'gravity_snap' }],
  collectibles: [{ id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', visual: '💎', type: 'collectible', snapping_type: 'free_float' }],
  decorations: [{ id: 'neon_sign', name: 'Neon Sign', category: 'decorations', visual: '💡', type: 'decoration', snapping_type: 'free_float' }]
};
