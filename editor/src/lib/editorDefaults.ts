import type { DifficultyMode } from './roomPersistence';
import type { ThemeName } from './themeRooms';
import type { PlacedEntity, WorldSettings } from './canvasState';

export type ThemeDraft = {
  theme: ThemeName;
  adjective: string;
  noun: string;
};

export const DIFFICULTY_MODES: DifficultyMode[] = ['easy', 'normal', 'creative'];

export function createDefaultPlacedEntities(): PlacedEntity[] {
  return [
    {
      instance_id: 'hero_001',
      asset_id: 'hero_knight',
      category: 'heroes',
      type: 'player',
      position: { x: 128, y: 216 },
      is_camera_target: true,
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'floor_001',
      asset_id: 'stone_floor',
      category: 'terrain',
      type: 'terrain',
      position: { x: 320, y: 392 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    },
    {
      instance_id: 'enemy_001',
      asset_id: 'slime_patrol',
      category: 'enemies',
      type: 'enemy',
      position: { x: 520, y: 344 },
      modifiers: { variant: 'default', scale_multiplier: 1.0 }
    }
  ];
}

export function createDefaultWorldSettings(): WorldSettings {
  return {
    time_of_day: 'day',
    weather: 'clear',
    rising_hazard_type: '',
    rising_hazard_speed: 20,
    camera_autoscroll: false,
    camera_autoscroll_direction: 'right',
    camera_autoscroll_speed: 40,
    victory_rules: { win_condition: 'all_enemies', celebration: 'confetti' },
    loss_rules: { lose_condition: 'health_0', action: 'game_over' },
    room_rules: [],
    level_balancer_enabled: true,
    tutorial_whisperer_enabled: true
  };
}

export function createDefaultThemeDraft(): ThemeDraft {
  return {
    theme: 'space',
    adjective: 'Super',
    noun: 'World'
  };
}
