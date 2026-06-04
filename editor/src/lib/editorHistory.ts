import type { PlacedEntity } from './canvasState';

export type LevelHistoryState = {
  history: PlacedEntity[][];
  index: number;
};

export function clonePlacedEntities(placed: PlacedEntity[]): PlacedEntity[] {
  return placed.map((entity) => ({
    ...entity,
    position: { ...entity.position },
    modifiers: entity.modifiers ? { ...entity.modifiers } : { variant: 'default', scale_multiplier: 1.0 }
  }));
}

export function createLevelHistory(placed: PlacedEntity[]): LevelHistoryState {
  return {
    history: [clonePlacedEntities(placed)],
    index: 0
  };
}

export function pushLevelHistory(state: LevelHistoryState, placed: PlacedEntity[], maxEntries = 50): LevelHistoryState {
  let history = state.history;
  if (state.index < history.length - 1) {
    history = history.slice(0, state.index + 1);
  }

  history = [...history, clonePlacedEntities(placed)];
  let index = history.length - 1;
  if (history.length > maxEntries) {
    history = history.slice(1);
    index -= 1;
  }

  return { history, index };
}

export function restoreLevelHistory(state: LevelHistoryState, direction: 'undo' | 'redo'): { state: LevelHistoryState; placed: PlacedEntity[] } | null {
  const nextIndex = direction === 'undo' ? state.index - 1 : state.index + 1;
  if (nextIndex < 0 || nextIndex >= state.history.length) {
    return null;
  }

  return {
    state: {
      history: state.history,
      index: nextIndex
    },
    placed: clonePlacedEntities(state.history[nextIndex])
  };
}
