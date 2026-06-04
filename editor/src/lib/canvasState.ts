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
  rising_hazard_type?: 'water' | 'lava' | '';
  rising_hazard_speed?: number;
  victory_rules?: { win_condition: string; celebration: string };
  loss_rules?: { lose_condition: string; action: string };
  room_rules?: any[];
  theme?: string;
  story_title?: string;
  story_intro_text?: string;
  custom_bgm_sequence?: number[][];
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
  heroes: [
    { id: 'hero_knight', name: 'Hero Knight', category: 'heroes', visual: '🛡️', type: 'player', snapping_type: 'gravity_snap' },
    { id: 'pet_dog', name: 'Magnet Dog', category: 'heroes', visual: '🐶', type: 'pet', snapping_type: 'free_float' },
    { id: 'pet_fairy', name: 'Lantern Fairy', category: 'heroes', visual: '🧚‍♀️', type: 'pet', snapping_type: 'free_float' },
    { id: 'pet_robot', name: 'Shield Robot', category: 'heroes', visual: '🤖', type: 'pet', snapping_type: 'free_float' },
    { id: 'companion_pikmin', name: 'Pikmin Helper 🌱', category: 'heroes', visual: '🌱', type: 'companion_pikmin', snapping_type: 'gravity_snap' },
    { id: 'companion_ghost', name: 'Spooky Ghost 👻', category: 'heroes', visual: '👻', type: 'companion_ghost', snapping_type: 'free_float' }
  ],
  terrain: [
    { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', visual: '🪨', type: 'terrain', snapping_type: 'edge_to_edge' },
    { id: 'water_block', name: 'Water Block', category: 'terrain', visual: '💧', type: 'water_block', snapping_type: 'free_float' },
    { id: 'crumbling_cloud', name: 'Crumbling Cloud', category: 'terrain', visual: '☁️', type: 'crumbling_cloud', snapping_type: 'free_float' },
    { id: 'brick_destructible', name: 'Cracked Brick 🧱', category: 'terrain', visual: '🧱', type: 'destructible_terrain', snapping_type: 'edge_to_edge' },
    { id: 'ice_destructible', name: 'Brittle Ice 🧊', category: 'terrain', visual: '🧊', type: 'destructible_terrain', snapping_type: 'edge_to_edge' },
    { id: 'wood_block', name: 'Wood Block 🪵', category: 'terrain', visual: '🪵', type: 'wood_block', snapping_type: 'edge_to_edge' },
    { id: 'grass_block', name: 'Grass Block 🌿', category: 'terrain', visual: '🌿', type: 'grass_block', snapping_type: 'edge_to_edge' },
    { id: 'metal_block', name: 'Metal Block 🔩', category: 'terrain', visual: '🔩', type: 'metal_block', snapping_type: 'edge_to_edge' }
  ],
  enemies: [
    { id: 'slime_patrol', name: 'Slime Patrol', category: 'enemies', visual: '👾', type: 'enemy', snapping_type: 'gravity_snap' },
    { id: 'cactus_hazard', name: 'Prickly Cactus', category: 'enemies', visual: '🌵', type: 'hazard', snapping_type: 'gravity_snap' },
    { id: 'spike_hazard', name: 'Ice Spike', category: 'enemies', visual: '🧊', type: 'hazard', snapping_type: 'free_float' }
  ],
  collectibles: [
    { id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', visual: '💎', type: 'collectible', snapping_type: 'free_float' },
    { id: 'gadget_glider', name: 'Glider Cape', category: 'collectibles', visual: '🪂', type: 'collectible', snapping_type: 'free_float' },
    { id: 'gadget_jetpack', name: 'Jetpack', category: 'collectibles', visual: '🚀', type: 'collectible', snapping_type: 'free_float' },
    { id: 'adventure_key_red', name: 'Red Key 🔑', category: 'collectibles', visual: '🔑', type: 'key_collectible', snapping_type: 'free_float' },
    { id: 'adventure_key_blue', name: 'Blue Key 🗝️', category: 'collectibles', visual: '🗝️', type: 'key_collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_speed', name: 'Speed Potion 🧪', category: 'collectibles', visual: '🧪', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_jump', name: 'Jump Potion 🥤', category: 'collectibles', visual: '🥤', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_giant', name: 'Growth Potion 🍄', category: 'collectibles', visual: '🍄', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_gravity', name: 'Gravity Potion 🔮', category: 'collectibles', visual: '🔮', type: 'collectible', snapping_type: 'free_float' },
    { id: 'tool_hammer', name: 'Toy Hammer 🔨', category: 'collectibles', visual: '🔨', type: 'collectible', snapping_type: 'free_float' },
    { id: 'tool_lantern', name: 'Lantern 🔦', category: 'collectibles', visual: '🔦', type: 'collectible', snapping_type: 'free_float' },
    { id: 'weapon_sword', name: 'Toy Sword ⚔️', category: 'collectibles', visual: '⚔️', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_metal_scrap', name: 'Metal Scrap 🔩', category: 'collectibles', visual: '🔩', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_fire_powder', name: 'Fire Powder 🌶️', category: 'collectibles', visual: '🌶️', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_green_herb', name: 'Green Herb 🌿', category: 'collectibles', visual: '🌿', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_sweet_honey', name: 'Sweet Honey 🍯', category: 'collectibles', visual: '🍯', type: 'collectible', snapping_type: 'free_float' }
  ],
  decorations: [
    { id: 'neon_sign', name: 'Neon Sign', category: 'decorations', visual: '💡', type: 'decoration', snapping_type: 'free_float' },
    { id: 'trigger_button', name: 'Floor Button', category: 'decorations', visual: '🔘', type: 'trigger', snapping_type: 'free_float' },
    { id: 'trigger_lever', name: 'Wall Lever', category: 'decorations', visual: '🕹️', type: 'trigger', snapping_type: 'free_float' },
    { id: 'gate_block', name: 'Switch Gate', category: 'decorations', visual: '🚪', type: 'gate', snapping_type: 'free_float' },
    { id: 'locked_gate_red', name: 'Red Gate 🟥', category: 'decorations', visual: '🟥', type: 'locked_door', snapping_type: 'free_float' },
    { id: 'locked_gate_blue', name: 'Blue Gate 🟦', category: 'decorations', visual: '🟦', type: 'locked_door', snapping_type: 'free_float' },
    { id: 'jelly_trampoline', name: 'Bouncy Jelly', category: 'decorations', visual: '🪼', type: 'jelly', snapping_type: 'free_float' },
    { id: 'speed_pad', name: 'Turbo Arrow', category: 'decorations', visual: '⏩', type: 'speed_pad', snapping_type: 'free_float' },
    { id: 'speech_sign', name: 'Chatty Sign', category: 'decorations', visual: '🪧', type: 'speech_sign', snapping_type: 'free_float' },
    { id: 'wizard_buddy', name: 'Wandering Wizard', category: 'decorations', visual: '🧙‍♂️', type: 'speech_sign', snapping_type: 'free_float' },
    { id: 'npc_shopkeeper', name: 'Toy Shopkeeper 🧸', category: 'decorations', visual: '🧸', type: 'shopkeeper', snapping_type: 'gravity_snap' },
    { id: 'conveyor_belt', name: 'Conveyor Belt ⚙️', category: 'decorations', visual: '⚙️', type: 'conveyor', snapping_type: 'edge_to_edge' },
    { id: 'mystery_box', name: 'Mystery Box ❓', category: 'decorations', visual: '❓', type: 'mystery_box', snapping_type: 'free_float' },
    { id: 'gravity_zone', name: 'Gravity Zone 🌀', category: 'decorations', visual: '🌀', type: 'gravity_zone', snapping_type: 'free_float' },
    { id: 'wind_zone', name: 'Wind Gust 💨', category: 'decorations', visual: '💨', type: 'wind_zone', snapping_type: 'free_float' },
    { id: 'target_practice', name: 'Spinning Target 🎯', category: 'decorations', visual: '🎯', type: 'target_practice', snapping_type: 'free_float' },
    { id: 'trigger_pressure_plate', name: 'Pressure Plate 🟨', category: 'decorations', visual: '🟨', type: 'trigger', snapping_type: 'free_float' },
    { id: 'zonai_fan', name: 'Zonai Fan 🌬️', category: 'decorations', visual: '🌬️', type: 'zonai_fan', snapping_type: 'free_float' },
    { id: 'zonai_rocket', name: 'Zonai Rocket 🚀', category: 'decorations', visual: '🚀', type: 'zonai_rocket', snapping_type: 'free_float' },
    { id: 'zonai_balloon', name: 'Zonai Balloon 🎈', category: 'decorations', visual: '🎈', type: 'zonai_balloon', snapping_type: 'free_float' },
    { id: 'zonai_spring', name: 'Zonai Spring 🌀', category: 'decorations', visual: '🌀', type: 'zonai_spring', snapping_type: 'free_float' },
    { id: 'zonai_beam', name: 'Zonai Laser 🔫', category: 'decorations', visual: '🔫', type: 'zonai_beam', snapping_type: 'free_float' },
    { id: 'zonai_battery', name: 'Zonai Battery 🔋', category: 'decorations', visual: '🔋', type: 'zonai_battery', snapping_type: 'free_float' },
    { id: 'crafting_bench', name: 'Crafting Bench 🔨', category: 'decorations', visual: '🔨', type: 'crafting_bench', snapping_type: 'gravity_snap' },
    { id: 'bbq_spit', name: 'BBQ Spit 🍖', category: 'decorations', visual: '🍖', type: 'bbq_spit', snapping_type: 'gravity_snap' },
    { id: 'chemistry_fire', name: 'Fire Torch 🔥', category: 'decorations', visual: '🔥', type: 'chemistry_fire', snapping_type: 'free_float' },
    { id: 'chemistry_water', name: 'Water Spout 💧', category: 'decorations', visual: '💧', type: 'chemistry_water', snapping_type: 'free_float' },
    { id: 'chemistry_ice', name: 'Ice Crystal ❄️', category: 'decorations', visual: '❄️', type: 'chemistry_ice', snapping_type: 'free_float' },
    { id: 'chemistry_lightning', name: 'Lightning Storm ⚡', category: 'decorations', visual: '⚡', type: 'chemistry_lightning', snapping_type: 'free_float' }
  ],
  particles: [
    { id: 'effects_fire', name: 'Fire Effect', category: 'particles', visual: '🔥', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_sparkles', name: 'Magic Sparkles', category: 'particles', visual: '✨', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_snow', name: 'Snow Flurry', category: 'particles', visual: '❄️', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_hearts', name: 'Hearts Aura', category: 'particles', visual: '💖', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_smoke', name: 'Smoke Puff', category: 'particles', visual: '💨', type: 'particles', snapping_type: 'free_float' }
  ]
};
