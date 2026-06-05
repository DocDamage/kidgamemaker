import { makeInstanceId, type AssetInventory, type PlacedEntity, type ToyboxAsset, type WorldSettings } from './canvasState';
import { buildThemeWorldSettings, type ThemeName, type GeneratedRoom } from './themeRooms';

// Seedable random number generator (Mulberry32)
export function createPRNG(seedStr: string) {
  let h = 2166136261 >>> 0;
  for (let i = 0; i < seedStr.length; i++) {
    h = Math.imul(h ^ seedStr.charCodeAt(i), 16777619);
  }
  let seed = h >>> 0;
  return function() {
    let t = seed += 0x6D2B79F5;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export function buildProceduralRoom(
  seed: string,
  biome: 'forest' | 'castle' | 'space',
  difficulty: 'easy' | 'medium' | 'hard',
  findAsset: (id: string) => ToyboxAsset | undefined,
  inventory?: AssetInventory
): GeneratedRoom {
  const rand = createPRNG(seed);

  // Map biome to theme
  const themeMap: Record<string, ThemeName> = {
    forest: 'jungle',
    castle: 'volcano',
    space: 'space'
  };
  const themeName = themeMap[biome] || 'jungle';

  const worldSettings: WorldSettings = {
    ...buildThemeWorldSettings(themeName),
    theme: themeName,
    difficulty: difficulty,
    calm_mode: false,
    victory_rules: { win_condition: 'portal', celebration: 'confetti' },
    loss_rules: { lose_condition: 'health_0', action: 'respawn' }
  } as WorldSettings;

  if (biome === 'space') {
    worldSettings.weather = 'clear';
    worldSettings.time_of_day = 'night';
  } else if (biome === 'castle') {
    worldSettings.weather = 'rain';
    worldSettings.time_of_day = 'sunset';
  } else {
    worldSettings.weather = 'clear';
    worldSettings.time_of_day = 'day';
  }

  // Resolve assets
  const heroAsset = findAsset('hero_knight') ?? findAsset('player_knight') ?? pickAsset(inventory, 'heroes', ['hero', 'player', 'knight'], []);
  const terrainAsset = pickAsset(inventory, 'terrain', biomeTerms[biome].terrain, [
    biome === 'space' ? 'brick_destructible' : 'stone_floor',
    'grass_block',
    'metal_block'
  ]) ?? findAsset('stone_floor');
  const rubyAsset = pickAsset(inventory, 'collectibles', ['gem', 'ruby', 'coin', 'diamond', 'star'], ['gold_ruby']);
  const keyAsset = pickAsset(inventory, 'collectibles', ['key'], ['gold_key', 'adventure_key_red']);
  const heartAsset = pickAsset(inventory, 'collectibles', ['heart', 'health', 'potion'], ['heart_pickup']);
  const slimeAsset = pickAsset(inventory, 'enemies', biomeTerms[biome].enemy, [
    biome === 'castle' ? 'red_slime_enemy' : 'slime_patrol',
    'slime_animation_enemy'
  ]);
  const portalAsset = pickAsset(inventory, 'portals', ['portal', 'exit'], ['exit_portal']) ?? findAsset('exit_portal');
  const lockDoorAsset = pickAsset(inventory, 'portals', ['door', 'gate', 'lock'], ['locked_door'])
    ?? pickAsset(inventory, 'decorations', ['door', 'gate', 'lock'], ['locked_gate_red']);
  const springAsset = pickAsset(inventory, 'collectibles', ['spring', 'jump', 'bounce'], ['charge_spring'])
    ?? pickAsset(inventory, 'decorations', ['spring', 'bounce', 'jelly'], ['jelly_trampoline', 'zonai_spring']);
  const ambientAsset = pickAsset(inventory, 'decorations', biomeTerms[biome].decoration, []);
  const hazardAsset = pickAsset(inventory, 'enemies', biomeTerms[biome].hazard, ['spike_hazard', 'cactus_hazard'])
    ?? pickAsset(inventory, 'decorations', biomeTerms[biome].hazard, ['chemistry_fire']);

  const safeHero = heroAsset ?? fallbackAsset('hero_knight', 'Hero Knight', 'heroes', 'player');
  const safeTerrain = terrainAsset ?? fallbackAsset('stone_floor', 'Stone Floor', 'terrain', 'terrain');
  const safeRuby = rubyAsset ?? fallbackAsset('gold_ruby', 'Gold Ruby', 'collectibles', 'collectible');
  const safeKey = keyAsset ?? fallbackAsset('gold_key', 'Gold Key', 'collectibles', 'collectible');
  const safeHeart = heartAsset ?? fallbackAsset('heart_pickup', 'Heart Pickup', 'collectibles', 'collectible');
  const safeEnemy = slimeAsset ?? fallbackAsset('slime_patrol', 'Slime Patrol', 'enemies', 'enemy');
  const safePortal = portalAsset ?? fallbackAsset('exit_portal', 'Exit Portal', 'portals', 'portal');
  const safeDoor = lockDoorAsset ?? fallbackAsset('locked_door', 'Locked Door', 'portals', 'portal');
  const safeSpring = springAsset ?? fallbackAsset('charge_spring', 'Charge Spring', 'collectibles', 'collectible');

  const placed: PlacedEntity[] = [];

  // Determine grammar sequence
  let chunks: string[] = [];
  if (difficulty === 'easy') {
    chunks = ['Start', 'Platform', 'Platform', 'Reward', 'Exit'];
  } else if (difficulty === 'medium') {
    chunks = ['Start', 'Platform', 'Gap', 'Reward', 'KeyLock', 'Platform', 'Exit'];
  } else {
    chunks = ['Start', 'Gap', 'Hazard', 'Gap', 'KeyLock', 'Hazard', 'Gap', 'Reward', 'Exit'];
  }

  let curX = 0;
  const cellSize = 64;
  const chunkWidth = 8;

  for (const chunk of chunks) {
    if (chunk === 'Start') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(safeHero.id),
        asset_id: safeHero.id,
        category: safeHero.category,
        type: safeHero.type ?? safeHero.category,
        position: { x: curX + 128, y: 320 },
        is_camera_target: true,
        modifiers: { variant: 'default', scale_multiplier: 1.0 }
      });
      if (ambientAsset) {
        placed.push({
          instance_id: makeInstanceId(ambientAsset.id),
          asset_id: ambientAsset.id,
          category: ambientAsset.category,
          type: ambientAsset.type ?? ambientAsset.category,
          position: { x: curX + 320, y: 320 },
          modifiers: { variant: 'default', scale_multiplier: 0.8, speech_text: 'Hello!' }
        });
      }
    } else if (chunk === 'Platform') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      for (let c of [2, 3, 4]) {
        placed.push({
          instance_id: makeInstanceId(safeRuby.id),
          asset_id: safeRuby.id,
          category: safeRuby.category,
          type: safeRuby.type ?? safeRuby.category,
          position: { x: curX + c * cellSize, y: 300 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, score_value: 10 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(safeEnemy.id),
        asset_id: safeEnemy.id,
        category: safeEnemy.category,
        type: safeEnemy.type ?? safeEnemy.category,
        position: { x: curX + 5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'patrol', patrol_speed: 60 }
      });
    } else if (chunk === 'Gap') {
      for (let c = 0; c < 2; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      if (difficulty === 'hard') {
        const activeHazard = hazardAsset ?? safeEnemy;
        placed.push({
          instance_id: makeInstanceId(activeHazard.id),
          asset_id: activeHazard.id,
          category: activeHazard.category,
          type: activeHazard.type ?? 'hazard',
          position: { x: curX + 3.5 * cellSize, y: 448 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, damage_value: 20 }
        });
      } else {
        placed.push({
          instance_id: makeInstanceId(safeSpring.id),
          asset_id: safeSpring.id,
          category: safeSpring.category,
          type: safeSpring.type ?? safeSpring.category,
          position: { x: curX + 3 * cellSize, y: 448 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, spring_force: 500 }
        });
      }
      for (let c = 6; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
    } else if (chunk === 'Hazard') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      const activeHazard = hazardAsset ?? safeEnemy;
      placed.push({
        instance_id: makeInstanceId(activeHazard.id),
        asset_id: activeHazard.id,
        category: activeHazard.category,
        type: activeHazard.type ?? 'hazard',
        position: { x: curX + 3 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, damage_value: 15 }
      });
      placed.push({
        instance_id: makeInstanceId(safeEnemy.id),
        asset_id: safeEnemy.id,
        category: safeEnemy.category,
        type: safeEnemy.type ?? safeEnemy.category,
        position: { x: curX + 1.5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'chase', move_speed: 70 }
      });
      placed.push({
        instance_id: makeInstanceId(safeEnemy.id),
        asset_id: safeEnemy.id,
        category: safeEnemy.category,
        type: safeEnemy.type ?? safeEnemy.category,
        position: { x: curX + 5.5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'jump' }
      });
    } else if (chunk === 'KeyLock') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      for (let c of [2, 3]) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 256 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(safeKey.id),
        asset_id: safeKey.id,
        category: safeKey.category,
        type: safeKey.type ?? safeKey.category,
        position: { x: curX + 2.5 * cellSize, y: 192 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, key_color: 'gold' }
      });
      placed.push({
        instance_id: makeInstanceId(safeDoor.id),
        asset_id: safeDoor.id,
        category: safeDoor.category,
        type: safeDoor.type ?? safeDoor.category,
        position: { x: curX + 6 * cellSize, y: 300 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, key_color: 'gold', target_room: '' }
      });
    } else if (chunk === 'Reward') {
      const heights = [320, 256, 320];
      const positions = [1, 3, 5];
      for (let i = 0; i < positions.length; i++) {
        const c = positions[i];
        const h = heights[i];
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: h },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
        placed.push({
          instance_id: makeInstanceId(safeRuby.id),
          asset_id: safeRuby.id,
          category: safeRuby.category,
          type: safeRuby.type ?? safeRuby.category,
          position: { x: curX + c * cellSize, y: h - 60 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, score_value: 20 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(safeHeart.id),
        asset_id: safeHeart.id,
        category: safeHeart.category,
        type: safeHeart.type ?? safeHeart.category,
        position: { x: curX + 3 * cellSize, y: 130 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, heal_value: 1 }
      });
    } else if (chunk === 'Exit') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(safeTerrain.id),
          asset_id: safeTerrain.id,
          category: safeTerrain.category,
          type: safeTerrain.type ?? safeTerrain.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(safePortal.id),
        asset_id: safePortal.id,
        category: safePortal.category,
        type: safePortal.type ?? safePortal.category,
        position: { x: curX + 4 * cellSize, y: 300 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, target_room: '' }
      });
    }

    curX += chunkWidth * cellSize;
  }

  return {
    roomId: `procedural_${biome}_${difficulty}_${randomRoomSuffix()}`,
    theme: themeName,
    worldSettings,
    placed,
    platformCount: chunks.length * chunkWidth
  };
}

function randomRoomSuffix(): number {
  return Math.floor(Math.random() * 900 + 100);
}

const biomeTerms: Record<'forest' | 'castle' | 'space', Record<'terrain' | 'enemy' | 'decoration' | 'hazard', string[]>> = {
  forest: {
    terrain: ['grass', 'forest', 'jungle', 'green', 'dirt', 'wood', 'platform', 'tile'],
    enemy: ['slime', 'frog', 'mushroom', 'wolf', 'bug', 'forest'],
    decoration: ['tree', 'plant', 'leaf', 'bush', 'grass', 'forest', 'mushroom'],
    hazard: ['spike', 'thorn', 'fire', 'lava', 'hazard']
  },
  castle: {
    terrain: ['stone', 'castle', 'dungeon', 'brick', 'wall', 'floor', 'tile'],
    enemy: ['skull', 'skeleton', 'demon', 'bat', 'ghost', 'golem', 'slime'],
    decoration: ['torch', 'gate', 'door', 'banner', 'castle', 'statue', 'lamp'],
    hazard: ['spike', 'fire', 'lava', 'hazard']
  },
  space: {
    terrain: ['metal', 'space', 'tech', 'sci', 'industrial', 'platform', 'tile'],
    enemy: ['alien', 'robot', 'drone', 'space', 'ship'],
    decoration: ['star', 'planet', 'space', 'ship', 'console', 'tech'],
    hazard: ['laser', 'spike', 'fire', 'hazard']
  }
};

function fallbackAsset(id: string, name: string, category: string, type: string): ToyboxAsset {
  return { id, name, category, type };
}

function pickAsset(
  inventory: AssetInventory | undefined,
  category: string,
  terms: string[],
  fallbackIds: string[]
): ToyboxAsset | undefined {
  const candidates = inventory?.[category] ?? [];
  const realAssets = candidates.filter(hasUsableVisual);

  for (const id of fallbackIds) {
    const byId = realAssets.find((asset) => asset.id === id);
    if (byId) {
      return byId;
    }
  }

  return realAssets.find((asset) => {
    const searchable = `${asset.id} ${asset.name} ${asset.type ?? ''} ${asset.visual ?? ''}`.toLowerCase();
    return terms.some((term) => searchable.includes(term));
  }) ?? realAssets[0];
}

function hasUsableVisual(asset: ToyboxAsset): boolean {
  const visual = asset.visual ?? '';
  return Boolean(asset.sidecar_path) && /\.(png|jpg|jpeg|webp|svg)$/i.test(visual);
}
