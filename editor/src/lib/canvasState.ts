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
  };
};

export type ToyboxAsset = {
  id: string;
  name: string;
  category: string;
  visual?: string;
  type?: string;
};

export type AssetInventory = Record<string, ToyboxAsset[]>;

export type RoomPayload = {
  schema_version: 1;
  project_id: string;
  room_id: string;
  world_settings: {
    time_of_day: string;
    weather: string;
  };
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

export function toRoomPayload(entities: PlacedEntity[]): RoomPayload {
  return {
    schema_version: 1,
    project_id: 'demo_project',
    room_id: 'test_chamber_01',
    world_settings: {
      time_of_day: 'day',
      weather: 'clear'
    },
    entities
  };
}

export const fallbackInventory: AssetInventory = {
  heroes: [{ id: 'hero_knight', name: 'Hero Knight', category: 'heroes', visual: '🛡️', type: 'player' }],
  terrain: [{ id: 'stone_floor', name: 'Stone Floor', category: 'terrain', visual: '🪨', type: 'terrain' }],
  enemies: [{ id: 'slime_patrol', name: 'Slime Patrol', category: 'enemies', visual: '👾', type: 'enemy' }],
  collectibles: [{ id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', visual: '💎', type: 'collectible' }],
  decorations: [{ id: 'neon_sign', name: 'Neon Sign', category: 'decorations', visual: '💡', type: 'decoration' }]
};
