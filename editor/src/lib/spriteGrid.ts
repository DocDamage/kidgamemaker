export type PixelGrid = string[][];

export type PixelHistoryState = {
  history: PixelGrid[];
  index: number;
};

export type PixelFrameState = {
  frames: PixelGrid[];
  currentIndex: number;
  pixels: PixelGrid;
};

export function createEmptyGrid(size: number): PixelGrid {
  return Array(size)
    .fill(null)
    .map(() => Array(size).fill('transparent'));
}

export function cloneGrid(grid: PixelGrid): PixelGrid {
  return grid.map((row) => [...row]);
}

export function createPixelHistory(grid: PixelGrid): PixelHistoryState {
  return {
    history: [cloneGrid(grid)],
    index: 0
  };
}

export function pushPixelHistory(state: PixelHistoryState, grid: PixelGrid, maxEntries = 50): PixelHistoryState {
  let history = state.history;
  if (state.index < history.length - 1) {
    history = history.slice(0, state.index + 1);
  }

  history = [...history, cloneGrid(grid)];
  let index = history.length - 1;
  if (history.length > maxEntries) {
    history = history.slice(1);
    index -= 1;
  }

  return { history, index };
}

export function restorePixelHistory(
  state: PixelHistoryState,
  direction: 'undo' | 'redo'
): { state: PixelHistoryState; grid: PixelGrid } | null {
  const nextIndex = direction === 'undo' ? state.index - 1 : state.index + 1;
  if (nextIndex < 0 || nextIndex >= state.history.length) {
    return null;
  }

  return {
    state: {
      history: state.history,
      index: nextIndex
    },
    grid: cloneGrid(state.history[nextIndex])
  };
}

export function addAnimationFrame(state: PixelFrameState, maxFrames = 4): PixelFrameState | null {
  if (state.frames.length >= maxFrames) {
    return null;
  }

  const frames = state.frames.map(cloneGrid);
  frames[state.currentIndex] = cloneGrid(state.pixels);
  const newFrame = cloneGrid(state.pixels);
  const nextFrames = [...frames, newFrame];
  return {
    frames: nextFrames,
    currentIndex: nextFrames.length - 1,
    pixels: cloneGrid(newFrame)
  };
}

export function deleteAnimationFrame(state: PixelFrameState, index: number): PixelFrameState | null {
  if (state.frames.length <= 1 || index < 0 || index >= state.frames.length) {
    return null;
  }

  const nextFrames = state.frames.filter((_, frameIndex) => frameIndex !== index).map(cloneGrid);
  const nextIndex = Math.max(0, state.currentIndex - 1);
  return {
    frames: nextFrames,
    currentIndex: nextIndex,
    pixels: cloneGrid(nextFrames[nextIndex])
  };
}

export function selectAnimationFrame(state: PixelFrameState, index: number): PixelFrameState | null {
  if (index < 0 || index >= state.frames.length) {
    return null;
  }

  const frames = state.frames.map(cloneGrid);
  frames[state.currentIndex] = cloneGrid(state.pixels);
  return {
    frames,
    currentIndex: index,
    pixels: cloneGrid(frames[index])
  };
}

export function advanceAnimationFrame(state: PixelFrameState): PixelFrameState {
  const nextIndex = (state.currentIndex + 1) % state.frames.length;
  const frames = state.frames.map(cloneGrid);
  return {
    frames,
    currentIndex: nextIndex,
    pixels: cloneGrid(frames[nextIndex])
  };
}

export function applyTemplateGrid(template: readonly string[], size: number): PixelGrid {
  const grid = createEmptyGrid(size);
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      grid[y][x] = template[y]?.[x] === '#' ? '#212121' : 'transparent';
    }
  }
  return grid;
}

export function paintBrush(grid: PixelGrid, x: number, y: number, color: string, brushSize: number): boolean {
  const size = grid.length;
  const startX = x - Math.floor(brushSize / 2);
  const startY = y - Math.floor(brushSize / 2);
  let drawnAny = false;

  for (let dy = 0; dy < brushSize; dy++) {
    for (let dx = 0; dx < brushSize; dx++) {
      const px = startX + dx;
      const py = startY + dy;
      if (px >= 0 && px < size && py >= 0 && py < size && grid[py][px] !== color) {
        grid[py][px] = color;
        drawnAny = true;
      }
    }
  }

  return drawnAny;
}

export function floodFillGrid(grid: PixelGrid, startX: number, startY: number, targetColor: string, replacementColor: string) {
  if (targetColor === replacementColor) return;

  const size = grid.length;
  const queue: [number, number][] = [[startX, startY]];
  while (queue.length > 0) {
    const [cx, cy] = queue.shift()!;
    if (grid[cy][cx] !== targetColor) continue;

    grid[cy][cx] = replacementColor;
    if (cx > 0) queue.push([cx - 1, cy]);
    if (cx < size - 1) queue.push([cx + 1, cy]);
    if (cy > 0) queue.push([cx, cy - 1]);
    if (cy < size - 1) queue.push([cx, cy + 1]);
  }
}

export function drawPixelGrid(ctx: CanvasRenderingContext2D, canvas: HTMLCanvasElement, grid: PixelGrid) {
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  const size = grid.length;
  const cellSize = canvas.width / size;
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      if (grid[y][x] !== 'transparent') {
        ctx.fillStyle = grid[y][x];
        ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
      }
    }
  }
}

export function exportFramesToPngBase64(frames: PixelGrid[], currentGrid: PixelGrid, size: number, isSpritesheet: boolean): string {
  const exportCanvas = document.createElement('canvas');
  exportCanvas.width = isSpritesheet ? size * frames.length : size;
  exportCanvas.height = size;

  const exportCtx = exportCanvas.getContext('2d');
  if (!exportCtx) return '';

  if (isSpritesheet) {
    for (let f = 0; f < frames.length; f++) {
      drawFramePixels(exportCtx, frames[f], f * size, size);
    }
  } else {
    drawFramePixels(exportCtx, currentGrid, 0, size);
  }

  return exportCanvas.toDataURL('image/png').split(',')[1] ?? '';
}

function drawFramePixels(ctx: CanvasRenderingContext2D, grid: PixelGrid, xOffset: number, size: number) {
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      if (grid[y][x] !== 'transparent') {
        ctx.fillStyle = grid[y][x];
        ctx.fillRect(xOffset + x, y, 1, 1);
      }
    }
  }
}
