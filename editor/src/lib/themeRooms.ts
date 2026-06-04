import { makeInstanceId, type PlacedEntity, type ToyboxAsset, type WorldSettings } from './canvasState';

export type ThemeName = 'space' | 'candy' | 'jungle' | 'ice' | 'volcano';
export type FindAsset = (assetId: string) => ToyboxAsset | undefined;

export type GeneratedRoom = {
  roomId: string;
  theme: ThemeName;
  worldSettings: WorldSettings;
  placed: PlacedEntity[];
  platformCount: number;
};

export const ROOM_ADJECTIVES = ['Super', 'Spooky', 'Bouncy', 'Magic', 'Secret', 'Happy', 'Mega', 'Rainbow', 'Cool'];

export const ROOM_NOUNS: Record<ThemeName, string[]> = {
  space: ['Castle', 'Cave', 'Cloud', 'Station', 'Galaxy', 'Stars', 'Moon'],
  candy: ['Land', 'Mountain', 'Hills', 'River', 'Forest', 'Castle', 'Kingdom'],
  jungle: ['Island', 'Jungle', 'Valley', 'Treehouse', 'Temple', 'Ruins', 'Swamp'],
  ice: ['Wonderland', 'Fortress', 'Glacier', 'Iceberg', 'Cave', 'Slide', 'Palace'],
  volcano: ['Volcano', 'Pit', 'Core', 'Chamber', 'Forge', 'Peak', 'Lair']
};

export function randomRoomAdjective(): string {
  return ROOM_ADJECTIVES[Math.floor(Math.random() * ROOM_ADJECTIVES.length)];
}

export function randomRoomNoun(theme: ThemeName): string {
  const nouns = ROOM_NOUNS[theme];
  return nouns[Math.floor(Math.random() * nouns.length)];
}

export function getThemeEmoji(theme: string): string {
  if (theme === 'space') return '🚀';
  if (theme === 'candy') return '🍭';
  if (theme === 'jungle') return '🌴';
  if (theme === 'ice') return '❄️';
  if (theme === 'volcano') return '🌋';
  return '🎮';
}

export function buildNamedThemeRoomId(theme: ThemeName, adjective: string, noun: string): string {
  const rawName = `${adjective} ${noun}`;
  const sanitized = rawName.toLowerCase().replace(/[^a-z0-9]/g, '_');
  return `${theme}_${sanitized}_${randomRoomSuffix()}`;
}

export function buildThemeRoomId(theme: ThemeName): string {
  return `${theme}_room_${randomRoomSuffix()}`;
}

export function buildThemeWorldSettings(theme: ThemeName): WorldSettings {
  const baseSettings = {
    rising_hazard_type: '' as const,
    rising_hazard_speed: 20,
    camera_autoscroll: false,
    camera_autoscroll_direction: 'right' as const,
    camera_autoscroll_speed: 40,
    victory_rules: { win_condition: 'all_enemies', celebration: 'confetti' },
    loss_rules: { lose_condition: 'health_0', action: 'game_over' },
    room_rules: [],
    level_balancer_enabled: true,
    tutorial_whisperer_enabled: true,
    theme
  };

  if (theme === 'space') {
    return { time_of_day: 'night', weather: 'clear', ...baseSettings };
  }
  if (theme === 'candy') {
    return { time_of_day: 'sunset', weather: 'clear', ...baseSettings };
  }
  if (theme === 'ice') {
    return { time_of_day: 'morning', weather: 'snow', ...baseSettings };
  }
  if (theme === 'volcano') {
    return { time_of_day: 'sunset', weather: 'clear', ...baseSettings };
  }
  return { time_of_day: 'day', weather: 'rain', ...baseSettings };
}

export function buildThemeStarterEntities(findAsset: FindAsset): PlacedEntity[] {
  const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
  const heroAsset = findAsset('hero_knight') ?? { id: 'hero_knight', name: 'Hero Knight', category: 'heroes', type: 'player' };
  const rubyAsset = findAsset('gold_ruby') ?? { id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', type: 'collectible' };

  const entities: PlacedEntity[] = [
    {
      instance_id: makeInstanceId(heroAsset.id),
      asset_id: heroAsset.id,
      category: heroAsset.category,
      type: heroAsset.type ?? heroAsset.category,
      position: { x: 128, y: 300 },
      is_camera_target: true,
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: makeInstanceId(rubyAsset.id),
      asset_id: rubyAsset.id,
      category: rubyAsset.category,
      type: rubyAsset.type ?? rubyAsset.category,
      position: { x: 800, y: 330 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    }
  ];

  for (let i = 0; i < 7; i++) {
    entities.push({
      instance_id: makeInstanceId(terrainAsset.id),
      asset_id: terrainAsset.id,
      category: terrainAsset.category,
      type: terrainAsset.type ?? terrainAsset.category,
      position: { x: 128 + i * 128, y: 392 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    });
  }

  return entities;
}

export function buildSurpriseRoom(findAsset: FindAsset, difficultyMode: string, calmMode: boolean): GeneratedRoom {
  const theme = randomThemeName();
  const worldSettings: WorldSettings = {
    ...buildThemeWorldSettings(theme),
    victory_rules: { win_condition: 'all_coins', celebration: 'confetti' },
    loss_rules: { lose_condition: 'health_0', action: 'respawn' },
    theme,
    difficulty: difficultyMode,
    calm_mode: calmMode
  } as WorldSettings;

  const terrainAsset = findAsset('stone_floor') ?? { id: 'stone_floor', name: 'Stone Floor', category: 'terrain', type: 'terrain' };
  const heroAsset = findAsset('hero_knight') ?? { id: 'hero_knight', name: 'Hero Knight', category: 'heroes', type: 'player' };
  const rubyAsset = findAsset('gold_ruby') ?? { id: 'gold_ruby', name: 'Gold Ruby', category: 'collectibles', type: 'collectible' };
  const slimeAsset = findAsset('slime_patrol') ?? { id: 'slime_patrol', name: 'Slime', category: 'enemies', type: 'enemy' };
  const portalAsset = findAsset('exit_portal');
  const placed: PlacedEntity[] = [
    {
      instance_id: makeInstanceId(heroAsset.id),
      asset_id: heroAsset.id,
      category: heroAsset.category,
      type: heroAsset.type ?? heroAsset.category,
      position: { x: 128, y: 300 },
      is_camera_target: true,
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    }
  ];

  let curX = 0;
  let curY = 392;
  const platformCount = 8 + Math.floor(Math.random() * 6);
  const platformPositions: Array<{ x: number; y: number }> = [];

  for (let i = 0; i < platformCount; i++) {
    placed.push({
      instance_id: makeInstanceId(terrainAsset.id),
      asset_id: terrainAsset.id,
      category: terrainAsset.category,
      type: terrainAsset.type ?? terrainAsset.category,
      position: { x: curX, y: curY },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    });
    platformPositions.push({ x: curX, y: curY });
    curX += 128 + Math.floor(Math.random() * 64);
    curY += (Math.floor(Math.random() * 5) - 2) * 32;
    curY = Math.max(200, Math.min(500, curY));
  }

  const collectibleCount = 5 + Math.floor(Math.random() * 6);
  for (let i = 0; i < collectibleCount; i++) {
    const platform = platformPositions[Math.floor(Math.random() * platformPositions.length)];
    const offsetX = (Math.random() - 0.5) * 80;
    placed.push({
      instance_id: makeInstanceId(rubyAsset.id),
      asset_id: rubyAsset.id,
      category: rubyAsset.category,
      type: rubyAsset.type ?? rubyAsset.category,
      position: { x: platform.x + offsetX, y: platform.y - 60 - Math.random() * 40 },
      modifiers: { variant: 'default', scale_multiplier: 1.0, score_value: 10 }
    });
  }

  if (slimeAsset) {
    const enemyCount = 2 + Math.floor(Math.random() * 4);
    for (let i = 0; i < enemyCount; i++) {
      const platformIndex = Math.floor(platformPositions.length * 0.3 + Math.random() * platformPositions.length * 0.7);
      const platform = platformPositions[Math.min(platformIndex, platformPositions.length - 1)];
      const behaviors = ['patrol', 'chase', 'jump'];
      placed.push({
        instance_id: makeInstanceId(slimeAsset.id),
        asset_id: slimeAsset.id,
        category: slimeAsset.category,
        type: slimeAsset.type ?? slimeAsset.category,
        position: { x: platform.x + 40, y: platform.y - 48 },
        modifiers: {
          variant: 'default',
          scale_multiplier: 1.0,
          behavior_type: behaviors[Math.floor(Math.random() * behaviors.length)],
          patrol_speed: 50 + Math.floor(Math.random() * 100)
        }
      });
    }
  }

  if (portalAsset) {
    const lastPlatform = platformPositions[platformPositions.length - 1];
    placed.push({
      instance_id: makeInstanceId(portalAsset.id),
      asset_id: portalAsset.id,
      category: portalAsset.category,
      type: portalAsset.type ?? portalAsset.category,
      position: { x: lastPlatform.x, y: lastPlatform.y - 48 },
      modifiers: { variant: 'default', scale_multiplier: 1.0, target_room: '' }
    });
  }

  return {
    roomId: `surprise_${theme}_${randomRoomSuffix()}`,
    theme,
    worldSettings,
    placed,
    platformCount
  };
}

export function remixPlacedRoom(placed: PlacedEntity[], worldSettings: WorldSettings): { placed: PlacedEntity[]; worldSettings: WorldSettings } {
  const heroEntities = placed.filter((ent) => ent.category === 'heroes' && ent.type === 'player');
  const terrainEntities = placed.filter((ent) => ent.category === 'terrain');
  const enemyEntities = placed.filter((ent) => ent.category === 'enemies');
  const collectibleEntities = placed.filter((ent) => ent.category === 'collectibles');
  const otherEntities = placed.filter((ent) =>
    ent.category !== 'heroes' &&
    ent.category !== 'terrain' &&
    ent.category !== 'enemies' &&
    ent.category !== 'collectibles'
  );

  const remixedTerrain = terrainEntities.map((ent) => ({
    ...ent,
    position: {
      x: Math.max(0, ent.position.x + (Math.floor(Math.random() * 3) - 1) * 32),
      y: Math.max(0, ent.position.y + (Math.floor(Math.random() * 3) - 1) * 32)
    }
  }));

  const shuffledEnemyPositions = shufflePositions(enemyEntities);
  const remixedEnemies = enemyEntities.map((ent, index) => ({
    ...ent,
    position: shuffledEnemyPositions[index] ?? ent.position
  }));

  const shuffledCollectiblePositions = shufflePositions(collectibleEntities);
  const remixedCollectibles = collectibleEntities.map((ent, index) => ({
    ...ent,
    position: shuffledCollectiblePositions[index] ?? ent.position
  }));

  const times: WorldSettings['time_of_day'][] = ['day', 'morning', 'sunset', 'night'];
  const weathers: WorldSettings['weather'][] = ['clear', 'rain', 'snow'];

  return {
    placed: [
      ...heroEntities,
      ...remixedTerrain,
      ...remixedEnemies,
      ...remixedCollectibles,
      ...otherEntities
    ],
    worldSettings: {
      ...worldSettings,
      time_of_day: times[Math.floor(Math.random() * times.length)],
      weather: weathers[Math.floor(Math.random() * weathers.length)]
    }
  };
}

function randomThemeName(): ThemeName {
  const themes: ThemeName[] = ['space', 'candy', 'jungle', 'ice', 'volcano'];
  return themes[Math.floor(Math.random() * themes.length)];
}

function randomRoomSuffix(): number {
  return Math.floor(Math.random() * 900 + 100);
}

function shufflePositions(entities: PlacedEntity[]): Array<{ x: number; y: number }> {
  return entities
    .map((ent) => ({ ...ent.position }))
    .sort(() => Math.random() - 0.5);
}
