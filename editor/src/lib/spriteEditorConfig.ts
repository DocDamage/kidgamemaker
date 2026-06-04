export const SPRITE_EDITOR_GRID_SIZE = 16;

export const SPRITE_EDITOR_COLORS = [
  '#ff4b4b',
  '#ff9030',
  '#ffeb3b',
  '#00e676',
  '#2979ff',
  '#d500f9',
  '#ff4081',
  '#8d6e63',
  '#ffffff',
  '#212121'
] as const;

export function formatUnknownError(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
