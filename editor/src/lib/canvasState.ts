export type Vec2 = {
  x: number;
  y: number;
};

export type EntityModifierValue = string | number | boolean | string[] | undefined;

export type EntityModifiers = {
  variant: string;
  scale_multiplier: number;
  target_room?: string;
  target_portal?: string;
  battery_capacity?: number;
  behavior_type?: string;
  blast_radius?: number;
  boomerang_speed?: string;
  boost_direction?: number;
  boost_force?: number;
  boss_hud_style?: string;
  boss_mode?: boolean;
  boss_phases_count?: number;
  bounce_force?: number;
  charge_jump_speed?: string;
  conveyor_direction?: string;
  conveyor_speed?: number;
  cook_difficulty?: string;
  costume_id?: string;
  costume_tint?: string;
  crumble_delay?: number;
  damage?: number;
  damage_value?: number;
  drain_rate?: number;
  duration?: number;
  fuse_time?: number;
  grapple_range?: number;
  heal_value?: number;
  hero_class?: string;
  is_illusion?: boolean;
  is_moving_platform?: boolean;
  key_color?: string;
  lift_force?: number;
  magnet_duration?: number;
  move_axis?: string;
  move_speed?: number;
  move_travel?: number;
  palico_color?: string;
  particle_direction?: string;
  particle_intensity?: number;
  particle_theme?: string;
  patrol_speed?: number;
  pet_power?: string;
  pikmin_color?: string;
  powerup_type?: string;
  projectile_interval?: number;
  projectile_speed?: number;
  respawn_time?: number;
  rush_color?: string;
  score_value?: number;
  shoot_projectiles?: boolean;
  shop_item_1?: string;
  shop_item_2?: string;
  shop_price_1?: number;
  shop_price_2?: number;
  speech_text?: string;
  spring_force?: number;
  target_id?: string;
  thrust_force?: number;
  time_slow_factor?: number;
  water_buoyancy?: number;
  water_flavor?: string;
  wind_direction?: string;
  wind_force?: number;
  zonai_direction?: string;
  combined_with?: string;
  [key: string]: EntityModifierValue;
};

export type RoomRule = {
  trigger_type: string;
  trigger_id: string;
  action_type: string;
  action_id: string;
};

export type PlacedEntity = {
  instance_id: string;
  asset_id: string;
  category: string;
  type: string;
  position: Vec2;
  is_camera_target?: boolean;
  modifiers: EntityModifiers;
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

export type AgeMode = 'mellow' | 'growing' | 'creator';

export type WorldSettings = {
  time_of_day: 'day' | 'morning' | 'sunset' | 'night';
  weather: 'clear' | 'rain' | 'snow';
  rising_hazard_type?: 'water' | 'lava' | '';
  rising_hazard_speed?: number;
  camera_autoscroll?: boolean;
  camera_autoscroll_direction?: 'left' | 'right' | 'up' | 'down';
  camera_autoscroll_speed?: number;
  victory_rules?: { win_condition: string; celebration: string };
  loss_rules?: { lose_condition: string; action: string };
  room_rules?: RoomRule[];
  level_balancer_enabled?: boolean;
  tutorial_whisperer_enabled?: boolean;
  difficulty?: string;
  calm_mode?: boolean;
  theme?: string;
  story_title?: string;
  story_intro_text?: string;
  custom_bgm_sequence?: number[][];
  custom_bgm_instruments?: string[];
  /** Three-age accessibility mode. Controls grid snap, game speed, and fail behaviour. */
  age_mode?: AgeMode;
  /** Snap grid size in pixels — set automatically by age_mode selector */
  snap_size?: number;
  /** Game speed multiplier written into world_settings so Godot can read it */
  game_speed_multiplier?: number;
  grid_x?: number;
  grid_y?: number;
  health_style?: 'hearts' | 'diegetic';
};

export type PhaseAFeatureContract = {
  _meta: {
    feature_domain: string;
    minimum_schema_version: string;
  };
};

export type MovementSystemContract = PhaseAFeatureContract & {
  enabled: boolean;
  movement_ids: Array<'wall_jump' | 'double_jump' | 'dash' | 'glide' | 'ledge_grab' | 'ground_pound'>;
  params: {
    dash_cooldown_seconds: number;
    dash_duration_seconds: number;
    wall_cling_seconds: number;
    glide_stamina_seconds: number;
    ground_pound_speed: number;
  };
};

export type CombatSystemContract = PhaseAFeatureContract & {
  enabled: boolean;
  mechanics: Array<'sword_combo' | 'charge_shot' | 'parry' | 'shield_block'>;
  params: {
    combo_steps: number;
    combo_reset_seconds: number;
    parry_window_seconds: number;
    charge_shot_full_seconds: number;
  };
};

export type RulesEngineContract = PhaseAFeatureContract & {
  enabled: boolean;
  primitives: Array<'switch_door' | 'key_lock' | 'pressure_plate' | 'collectible_counter' | 'win_condition'>;
};

export type AiAssistContract = PhaseAFeatureContract & {
  level_balancer: boolean;
  tutorial_whisperer: boolean;
};

export type RoomPayload = {
  schema_version: string;
  project_id: string;
  room_id: string;
  world_settings: WorldSettings;
  movement_system: MovementSystemContract;
  combat_system: CombatSystemContract;
  rules_engine: RulesEngineContract;
  ai_assist: AiAssistContract;
  entities: PlacedEntity[];
};

export const PHASE_A_SCHEMA_VERSION = '2.0.0';

export function createDefaultMovementSystem(): MovementSystemContract {
  return {
    _meta: { feature_domain: 'movement_system', minimum_schema_version: PHASE_A_SCHEMA_VERSION },
    enabled: true,
    movement_ids: ['wall_jump', 'double_jump', 'dash', 'glide', 'ledge_grab', 'ground_pound'],
    params: {
      dash_cooldown_seconds: 1.2,
      dash_duration_seconds: 0.2,
      wall_cling_seconds: 0.3,
      glide_stamina_seconds: 4.0,
      ground_pound_speed: 900
    }
  };
}

export function createDefaultCombatSystem(): CombatSystemContract {
  return {
    _meta: { feature_domain: 'combat_system', minimum_schema_version: PHASE_A_SCHEMA_VERSION },
    enabled: true,
    mechanics: ['sword_combo', 'charge_shot', 'parry', 'shield_block'],
    params: {
      combo_steps: 3,
      combo_reset_seconds: 1.0,
      parry_window_seconds: 0.18,
      charge_shot_full_seconds: 1.0
    }
  };
}

export function createDefaultRulesEngine(): RulesEngineContract {
  return {
    _meta: { feature_domain: 'rules_engine', minimum_schema_version: PHASE_A_SCHEMA_VERSION },
    enabled: true,
    primitives: ['switch_door', 'key_lock', 'pressure_plate', 'collectible_counter', 'win_condition']
  };
}

export function createDefaultAiAssist(): AiAssistContract {
  return {
    _meta: { feature_domain: 'ai_assist', minimum_schema_version: PHASE_A_SCHEMA_VERSION },
    level_balancer: true,
    tutorial_whisperer: true
  };
}

export function makeInstanceId(prefix = 'entity'): string {
  const safePrefix = prefix.replace(/[^a-zA-Z0-9_]/g, '_');
  const randomPart = globalThis.crypto?.randomUUID?.() ?? Math.random().toString(16).slice(2);
  return `${safePrefix}_${randomPart}`;
}


/** Returns the WorldSettings overrides for each age mode. */
export function getAgeModeDefaults(mode: AgeMode): Partial<WorldSettings> {
  switch (mode) {
    case 'mellow':
      return {
        age_mode: 'mellow',
        snap_size: 80,
        game_speed_multiplier: 0.75,
        difficulty: 'easy',
        calm_mode: true,
        level_balancer_enabled: true,
        tutorial_whisperer_enabled: true
      };
    case 'growing':
      return {
        age_mode: 'growing',
        snap_size: 64,
        game_speed_multiplier: 0.9,
        difficulty: 'normal',
        calm_mode: false,
        level_balancer_enabled: true,
        tutorial_whisperer_enabled: true
      };
    case 'creator':
    default:
      return {
        age_mode: 'creator',
        snap_size: 32,
        game_speed_multiplier: 1.0,
        difficulty: 'normal',
        calm_mode: false,
        level_balancer_enabled: false,
        tutorial_whisperer_enabled: false
      };
  }
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

export function updateWeaponAdjacencies(current: PlacedEntity[]): { updated: PlacedEntity[], newLinks: Array<{p1: Vec2, p2: Vec2}> } {
  const updated = structuredClone(current) as PlacedEntity[];
  const newLinks: Array<{p1: Vec2, p2: Vec2}> = [];
  
  // Find all weapons
  const weapons = updated.filter(e => e.asset_id.startsWith('weapon_') || e.asset_id === 'tool_hammer');
  
  // Clear old links
  for (const w of weapons) {
    if (w.modifiers.combined_with) {
      delete w.modifiers.combined_with;
    }
  }

  // Link weapons if they are within 64px
  const linked = new Set<string>();
  for (let i = 0; i < weapons.length; i++) {
    for (let j = i + 1; j < weapons.length; j++) {
      const w1 = weapons[i];
      const w2 = weapons[j];
      
      if (linked.has(w1.instance_id) || linked.has(w2.instance_id)) continue;
      
      const dx = w1.position.x - w2.position.x;
      const dy = w1.position.y - w2.position.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      
      if (dist <= 64) {
        w1.modifiers.combined_with = w2.asset_id;
        w2.modifiers.combined_with = w1.asset_id;
        linked.add(w1.instance_id);
        linked.add(w2.instance_id);
        newLinks.push({ p1: w1.position, p2: w2.position });
      }
    }
  }

  return { updated, newLinks };
}

export function toRoomPayload(
  entities: PlacedEntity[],
  worldSettings?: WorldSettings,
  projectId = 'demo_project',
  roomId = 'test_chamber_01'
): RoomPayload {
  return {
    schema_version: PHASE_A_SCHEMA_VERSION,
    project_id: projectId,
    room_id: roomId,
    world_settings: worldSettings ?? { time_of_day: 'day', weather: 'clear' },
    movement_system: createDefaultMovementSystem(),
    combat_system: createDefaultCombatSystem(),
    rules_engine: createDefaultRulesEngine(),
    ai_assist: createDefaultAiAssist(),
    entities
  };
}

function defaultAssetVisual(category: string, id: string, file: string) {
  return {
    visual: file,
    sidecar_path: `engine/data/assets/${category}/${id}/${id}.json`
  };
}

export const fallbackInventory: AssetInventory = {
  heroes: [
    { id: 'hero_knight', name: 'Hero Knight', category: 'heroes', ...defaultAssetVisual('heroes', 'hero_knight', 'hero_knight.svg'), type: 'player', snapping_type: 'gravity_snap' },
    { id: 'pet_dog', name: 'Magnet Dog', category: 'heroes', visual: '🐶', type: 'pet', snapping_type: 'free_float' },
    { id: 'pet_fairy', name: 'Lantern Fairy', category: 'heroes', visual: '🧚‍♀️', type: 'pet', snapping_type: 'free_float' },
    { id: 'pet_robot', name: 'Shield Robot', category: 'heroes', visual: '🤖', type: 'pet', snapping_type: 'free_float' },
    { id: 'companion_pikmin', name: 'Pikmin Helper 🌱', category: 'heroes', visual: '🌱', type: 'companion_pikmin', snapping_type: 'gravity_snap' },
    { id: 'companion_ghost', name: 'Spooky Ghost 👻', category: 'heroes', visual: '👻', type: 'companion_ghost', snapping_type: 'free_float' },
    { id: 'companion_palico', name: 'Palico Sidekick 🐱', category: 'heroes', visual: '🐱', type: 'companion_palico', snapping_type: 'gravity_snap' },
    { id: 'companion_rush', name: 'Rush Dog 🐶', category: 'heroes', visual: '🐶', type: 'companion_rush', snapping_type: 'gravity_snap' }
  ],
  terrain: [
    { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', ...defaultAssetVisual('terrain', 'stone_floor', 'stone_floor.svg'), type: 'terrain', snapping_type: 'edge_to_edge' },
    { id: 'water_block', name: 'Water Block', category: 'terrain', visual: '💧', type: 'water_block', snapping_type: 'free_float' },
    { id: 'crumbling_cloud', name: 'Crumbling Cloud', category: 'terrain', visual: '☁️', type: 'crumbling_cloud', snapping_type: 'free_float' },
    { id: 'brick_destructible', name: 'Cracked Brick', category: 'terrain', ...defaultAssetVisual('terrain', 'brick_destructible', 'brick_destructible.svg'), type: 'destructible_terrain', snapping_type: 'edge_to_edge' },
    { id: 'ice_destructible', name: 'Brittle Ice', category: 'terrain', ...defaultAssetVisual('terrain', 'ice_destructible', 'ice_destructible.svg'), type: 'destructible_terrain', snapping_type: 'edge_to_edge' },
    { id: 'wood_block', name: 'Wood Block 🪵', category: 'terrain', visual: '🪵', type: 'wood_block', snapping_type: 'edge_to_edge' },
    { id: 'grass_block', name: 'Grass Block 🌿', category: 'terrain', visual: '🌿', type: 'grass_block', snapping_type: 'edge_to_edge' },
    { id: 'metal_block', name: 'Metal Block 🔩', category: 'terrain', visual: '🔩', type: 'metal_block', snapping_type: 'edge_to_edge' },
    { id: 'wall_run_surface', name: 'Wall-Run Surface ⚡', category: 'terrain', visual: '⚡', type: 'wall_run_surface', snapping_type: 'edge_to_edge' },
    { id: 'ceiling_run_surface', name: 'Ceiling-Run Surface 🌀', category: 'terrain', visual: '🌀', type: 'ceiling_run_surface', snapping_type: 'edge_to_edge' },
    { id: 'speed_booster_block', name: 'Speed Booster Block 🏃', category: 'terrain', visual: '🏃', type: 'speed_booster_block', snapping_type: 'edge_to_edge' }
  ],
  enemies: [
    {
      id: 'slime_patrol',
      name: 'Slime Patrol',
      category: 'enemies',
      visual: 'res://data/assets/enemies/red_slime_enemy/red_slime_enemy.png',
      sidecar_path: 'engine/data/assets/enemies/slime_patrol/slime_patrol.json',
      type: 'enemy',
      snapping_type: 'gravity_snap'
    },
    { id: 'cactus_hazard', name: 'Prickly Cactus', category: 'enemies', visual: '🌵', type: 'hazard', snapping_type: 'gravity_snap' },
    { id: 'spike_hazard', name: 'Ice Spike', category: 'enemies', visual: '🧊', type: 'hazard', snapping_type: 'free_float' }
  ],
  collectibles: [
    { id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', ...defaultAssetVisual('collectibles', 'gold_ruby', 'gold_ruby.svg'), type: 'collectible', snapping_type: 'free_float' },
    { id: 'gadget_glider', name: 'Glider Cape', category: 'collectibles', visual: '🪂', type: 'collectible', snapping_type: 'free_float' },
    { id: 'gadget_jetpack', name: 'Jetpack', category: 'collectibles', visual: '🚀', type: 'collectible', snapping_type: 'free_float' },
    { id: 'charge_spring', name: 'Charge Spring', category: 'collectibles', ...defaultAssetVisual('collectibles', 'charge_spring', 'charge_spring.svg'), type: 'collectible', snapping_type: 'free_float' },
    { id: 'adventure_key_red', name: 'Red Key 🔑', category: 'collectibles', visual: '🔑', type: 'key_collectible', snapping_type: 'free_float' },
    { id: 'adventure_key_blue', name: 'Blue Key 🗝️', category: 'collectibles', visual: '🗝️', type: 'key_collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_speed', name: 'Speed Potion 🧪', category: 'collectibles', visual: '🧪', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_jump', name: 'Jump Potion 🥤', category: 'collectibles', visual: '🥤', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_giant', name: 'Growth Potion 🍄', category: 'collectibles', visual: '🍄', type: 'collectible', snapping_type: 'free_float' },
    { id: 'alchemy_potion_gravity', name: 'Gravity Potion 🔮', category: 'collectibles', visual: '🔮', type: 'collectible', snapping_type: 'free_float' },
    { id: 'tool_hammer', name: 'Toy Hammer', category: 'collectibles', ...defaultAssetVisual('collectibles', 'tool_hammer', 'tool_hammer.svg'), type: 'collectible', snapping_type: 'free_float' },
    { id: 'tool_lantern', name: 'Lantern', category: 'collectibles', ...defaultAssetVisual('collectibles', 'tool_lantern', 'tool_lantern.svg'), type: 'collectible', snapping_type: 'free_float' },
    { id: 'weapon_sword', name: 'Toy Sword', category: 'collectibles', ...defaultAssetVisual('collectibles', 'weapon_sword', 'weapon_sword.svg'), type: 'collectible', snapping_type: 'free_float' },
    { id: 'weapon_boomerang', name: 'Toy Boomerang 🪃', category: 'collectibles', visual: '🪃', type: 'collectible', snapping_type: 'free_float' },
    { id: 'weapon_bomb', name: 'Toy Bomb 💣', category: 'collectibles', visual: '💣', type: 'collectible', snapping_type: 'free_float' },
    { id: 'focus_amulet', name: 'Time Amulet ⏳', category: 'collectibles', visual: '⏳', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_metal_scrap', name: 'Metal Scrap 🔩', category: 'collectibles', visual: '🔩', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_fire_powder', name: 'Fire Powder 🌶️', category: 'collectibles', visual: '🌶️', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_green_herb', name: 'Green Herb 🌿', category: 'collectibles', visual: '🌿', type: 'collectible', snapping_type: 'free_float' },
    { id: 'mat_sweet_honey', name: 'Sweet Honey 🍯', category: 'collectibles', visual: '🍯', type: 'collectible', snapping_type: 'free_float' },
    { id: 'weapon_paint_gun', name: 'Paint Gun 🔫', category: 'collectibles', visual: '🔫', type: 'collectible', snapping_type: 'free_float' },
    { id: 'star_piece', name: 'Star Piece 🌟', category: 'collectibles', visual: '🌟', type: 'collectible', snapping_type: 'free_float' }
  ],
  decorations: [
    { id: 'neon_sign', name: 'Neon Sign', category: 'decorations', ...defaultAssetVisual('decorations', 'neon_sign', 'neon_sign.svg'), type: 'decoration', snapping_type: 'free_float' },
    { id: 'trigger_button', name: 'Floor Button', category: 'decorations', visual: '🔘', type: 'trigger', snapping_type: 'free_float' },
    { id: 'trigger_lever', name: 'Wall Lever', category: 'decorations', visual: '🕹️', type: 'trigger', snapping_type: 'free_float' },
    { id: 'gate_block', name: 'Switch Gate', category: 'decorations', visual: '🚪', type: 'gate', snapping_type: 'free_float' },
    { id: 'locked_gate_red', name: 'Red Gate 🟥', category: 'decorations', visual: '🟥', type: 'locked_door', snapping_type: 'free_float' },
    { id: 'locked_gate_blue', name: 'Blue Gate 🟦', category: 'decorations', visual: '🟦', type: 'locked_door', snapping_type: 'free_float' },
    { id: 'jelly_trampoline', name: 'Bouncy Jelly', category: 'decorations', visual: '🪼', type: 'jelly', snapping_type: 'free_float' },
    { id: 'speed_pad', name: 'Turbo Arrow', category: 'decorations', visual: '⏩', type: 'speed_pad', snapping_type: 'free_float' },
    { id: 'speech_sign', name: 'Chatty Sign', category: 'decorations', visual: '🪧', type: 'speech_sign', snapping_type: 'free_float' },
    { id: 'wizard_buddy', name: 'Wandering Wizard', category: 'decorations', visual: '🧙‍♂️', type: 'speech_sign', snapping_type: 'free_float' },
    { id: 'npc_shopkeeper', name: 'Toy Shopkeeper', category: 'decorations', ...defaultAssetVisual('decorations', 'npc_shopkeeper', 'npc_shopkeeper.svg'), type: 'shopkeeper', snapping_type: 'gravity_snap' },
    { id: 'conveyor_belt', name: 'Conveyor Belt', category: 'decorations', ...defaultAssetVisual('decorations', 'conveyor_belt', 'conveyor_belt.svg'), type: 'conveyor', snapping_type: 'edge_to_edge' },
    { id: 'mystery_box', name: 'Mystery Box', category: 'decorations', ...defaultAssetVisual('decorations', 'mystery_box', 'mystery_box.svg'), type: 'mystery_box', snapping_type: 'free_float' },
    { id: 'gravity_zone', name: 'Gravity Zone', category: 'decorations', ...defaultAssetVisual('decorations', 'gravity_zone', 'gravity_zone.svg'), type: 'gravity_zone', snapping_type: 'free_float' },
    { id: 'wind_zone', name: 'Wind Gust', category: 'decorations', ...defaultAssetVisual('decorations', 'wind_zone', 'wind_zone.svg'), type: 'wind_zone', snapping_type: 'free_float' },
    { id: 'target_practice', name: 'Spinning Target', category: 'decorations', ...defaultAssetVisual('decorations', 'target_practice', 'target_practice.svg'), type: 'target_practice', snapping_type: 'free_float' },
    { id: 'trigger_pressure_plate', name: 'Pressure Plate', category: 'decorations', ...defaultAssetVisual('decorations', 'trigger_pressure_plate', 'trigger_pressure_plate.svg'), type: 'trigger', snapping_type: 'free_float' },
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
    { id: 'chemistry_lightning', name: 'Lightning Storm ⚡', category: 'decorations', visual: '⚡', type: 'chemistry_lightning', snapping_type: 'free_float' },
    { id: 'grapple_ring', name: 'Grapple Ring ⭕', category: 'decorations', visual: '⭕', type: 'grapple_ring', snapping_type: 'free_float' },
    { id: 'climbable_vine', name: 'Climbable Vine 🌿', category: 'decorations', visual: '🌿', type: 'climbable_vine', snapping_type: 'free_float' },
    { id: 'climbable_rope', name: 'Climbable Rope 🪢', category: 'decorations', visual: '🪢', type: 'climbable_rope', snapping_type: 'free_float' },
    { id: 'clear_pipe', name: 'Clear Pipe 🚇', category: 'decorations', visual: '🚇', type: 'clear_pipe', snapping_type: 'free_float' },
    { id: 'logic_and', name: 'Logic AND Gate 🛑', category: 'decorations', visual: '🛑', type: 'logic_and', snapping_type: 'free_float' },
    { id: 'logic_or', name: 'Logic OR Gate 🟢', category: 'decorations', visual: '🟢', type: 'logic_or', snapping_type: 'free_float' },
    { id: 'logic_not', name: 'Logic NOT Gate 🟡', category: 'decorations', visual: '🟡', type: 'logic_not', snapping_type: 'free_float' },
    { id: 'anvil_upgrade', name: 'Weapon Anvil ⚒️', category: 'decorations', visual: '⚒️', type: 'anvil_upgrade', snapping_type: 'gravity_snap' },
    { id: 'compass_stamp', name: 'Magic Compass 🧭', category: 'decorations', visual: '🧭', type: 'compass', snapping_type: 'free_float' }
  ],
  particles: [
    { id: 'effects_fire', name: 'Fire Effect', category: 'particles', visual: '🔥', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_sparkles', name: 'Magic Sparkles', category: 'particles', visual: '✨', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_snow', name: 'Snow Flurry', category: 'particles', visual: '❄️', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_hearts', name: 'Hearts Aura', category: 'particles', visual: '💖', type: 'particles', snapping_type: 'free_float' },
    { id: 'effects_smoke', name: 'Smoke Puff', category: 'particles', visual: '💨', type: 'particles', snapping_type: 'free_float' }
  ]
};
