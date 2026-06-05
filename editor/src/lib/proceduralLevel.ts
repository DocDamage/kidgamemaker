import { makeInstanceId, type PlacedEntity, type ToyboxAsset, type WorldSettings } from './canvasState';
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
  findAsset: (id: string) => ToyboxAsset | undefined
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
  const terrainId = biome === 'space' ? 'brick_destructible' : 'stone_floor';
  const enemyId = biome === 'space' ? 'slime_animation_enemy' : (biome === 'castle' ? 'red_slime_enemy' : 'slime_patrol');
  const heroAsset = findAsset('hero_knight') ?? findAsset('player_knight') ?? { id: 'hero_knight', category: 'heroes', type: 'player' };
  const terrainAsset = findAsset(terrainId) ?? { id: 'stone_floor', category: 'terrain', type: 'terrain' };
  const rubyAsset = findAsset('gold_ruby') ?? { id: 'gold_ruby', category: 'collectibles', type: 'collectible' };
  const keyAsset = findAsset('gold_key') ?? { id: 'gold_key', category: 'collectibles', type: 'collectible' };
  const heartAsset = findAsset('heart_pickup') ?? { id: 'heart_pickup', category: 'collectibles', type: 'collectible' };
  const slimeAsset = findAsset(enemyId) ?? { id: 'slime_patrol', category: 'enemies', type: 'enemy' };
  const portalAsset = findAsset('exit_portal') ?? { id: 'exit_portal', category: 'portals', type: 'portal' };
  const lockDoorAsset = findAsset('locked_door') ?? { id: 'locked_door', category: 'portals', type: 'portal' };
  const springAsset = findAsset('charge_spring') ?? { id: 'charge_spring', category: 'collectibles', type: 'collectible' };

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
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(heroAsset.id),
        asset_id: heroAsset.id,
        category: heroAsset.category,
        type: heroAsset.type ?? heroAsset.category,
        position: { x: curX + 128, y: 320 },
        is_camera_target: true,
        modifiers: { variant: 'default', scale_multiplier: 1.0 }
      });
      // Add a cute ambient animal (Living World)
      const animalVisual = biome === 'space' ? '👽' : (biome === 'castle' ? '🦇' : '🦋');
      placed.push({
        instance_id: `ambient_${Math.random().toString(36).substring(2, 6)}`,
        asset_id: 'ambient_creature',
        category: 'decorations',
        type: 'decoration',
        position: { x: curX + 320, y: 320 },
        modifiers: {
          variant: 'default',
          scale_multiplier: 0.8,
          visual: animalVisual,
          speech_text: animalVisual === '🦋' ? 'Flutter flutter!' : (animalVisual === '🦇' ? 'Squeak!' : 'Beep boop!')
        }
      });
    } else if (chunk === 'Platform') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      for (let c of [2, 3, 4]) {
        placed.push({
          instance_id: makeInstanceId(rubyAsset.id),
          asset_id: rubyAsset.id,
          category: rubyAsset.category,
          type: rubyAsset.type ?? rubyAsset.category,
          position: { x: curX + c * cellSize, y: 300 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, score_value: 10 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(slimeAsset.id),
        asset_id: slimeAsset.id,
        category: slimeAsset.category,
        type: slimeAsset.type ?? slimeAsset.category,
        position: { x: curX + 5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'patrol', patrol_speed: 60 }
      });
    } else if (chunk === 'Gap') {
      for (let c = 0; c < 2; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      if (difficulty === 'hard') {
        placed.push({
          instance_id: `spike_${Math.random().toString(36).substring(2, 6)}`,
          asset_id: 'spike_hazard',
          category: 'enemies',
          type: 'hazard',
          position: { x: curX + 3.5 * cellSize, y: 448 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, damage_value: 20 }
        });
      } else {
        placed.push({
          instance_id: makeInstanceId(springAsset.id),
          asset_id: springAsset.id,
          category: springAsset.category,
          type: springAsset.type ?? springAsset.category,
          position: { x: curX + 3 * cellSize, y: 448 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, spring_force: 500 }
        });
      }
      for (let c = 6; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
    } else if (chunk === 'Hazard') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: `spike_${Math.random().toString(36).substring(2, 6)}`,
        asset_id: 'spike_hazard',
        category: 'enemies',
        type: 'hazard',
        position: { x: curX + 3 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, damage_value: 15 }
      });
      placed.push({
        instance_id: makeInstanceId(slimeAsset.id),
        asset_id: slimeAsset.id,
        category: slimeAsset.category,
        type: slimeAsset.type ?? slimeAsset.category,
        position: { x: curX + 1.5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'chase', move_speed: 70 }
      });
      placed.push({
        instance_id: makeInstanceId(slimeAsset.id),
        asset_id: slimeAsset.id,
        category: slimeAsset.category,
        type: slimeAsset.type ?? slimeAsset.category,
        position: { x: curX + 5.5 * cellSize, y: 320 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, behavior_type: 'jump' }
      });
    } else if (chunk === 'KeyLock') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      for (let c of [2, 3]) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 256 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(keyAsset.id),
        asset_id: keyAsset.id,
        category: keyAsset.category,
        type: keyAsset.type ?? keyAsset.category,
        position: { x: curX + 2.5 * cellSize, y: 192 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, key_color: 'gold' }
      });
      placed.push({
        instance_id: makeInstanceId(lockDoorAsset.id),
        asset_id: lockDoorAsset.id,
        category: lockDoorAsset.category,
        type: lockDoorAsset.type ?? lockDoorAsset.category,
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
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: h },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
        placed.push({
          instance_id: makeInstanceId(rubyAsset.id),
          asset_id: rubyAsset.id,
          category: rubyAsset.category,
          type: rubyAsset.type ?? rubyAsset.category,
          position: { x: curX + c * cellSize, y: h - 60 },
          modifiers: { variant: 'default', scale_multiplier: 1.0, score_value: 20 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(heartAsset.id),
        asset_id: heartAsset.id,
        category: heartAsset.category,
        type: heartAsset.type ?? heartAsset.category,
        position: { x: curX + 3 * cellSize, y: 130 },
        modifiers: { variant: 'default', scale_multiplier: 1.0, heal_value: 1 }
      });
    } else if (chunk === 'Exit') {
      for (let c = 0; c < chunkWidth; c++) {
        placed.push({
          instance_id: makeInstanceId(terrainAsset.id),
          asset_id: terrainAsset.id,
          category: terrainAsset.category,
          type: terrainAsset.type ?? terrainAsset.category,
          position: { x: curX + c * cellSize, y: 384 },
          modifiers: { variant: 'default', scale_multiplier: 1.0 }
        });
      }
      placed.push({
        instance_id: makeInstanceId(portalAsset.id),
        asset_id: portalAsset.id,
        category: portalAsset.category,
        type: portalAsset.type ?? portalAsset.category,
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
