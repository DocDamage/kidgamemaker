<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';

  export let isVisible = false;
  export let targetAssetId = '';
  export let category = 'decorations';
  export let isMuted = false;

  const dispatch = createEventDispatcher<{
    close: void;
    saved: string;
  }>();

  const GRID_SIZE = 16;
  let canvasElement: HTMLCanvasElement;
  let ctx: CanvasRenderingContext2D | null = null;

  // Curated premium high-contrast color palette for kids
  const COLORS = [
    '#ff4b4b', // Red
    '#ff9030', // Orange
    '#ffeb3b', // Yellow
    '#00e676', // Green
    '#2979ff', // Blue
    '#d500f9', // Purple
    '#ff4081', // Pink
    '#8d6e63', // Brown
    '#ffffff', // White
    '#212121'  // Black
  ];

  let currentColor = '#ff4b4b';
  let isDrawing = false;
  let isEraser = false;
  let brushSize = 1;
  let isBucket = false;
  let symmetryMode: 'none' | 'horizontal' | 'vertical' | 'both' = 'none';
  let isRainbowBrush = false;
  let rainbowHue = 0;

  let activeTab: 'draw' | 'sound' = 'draw';
  
  // Synthesizer parameters
  let sfxWaveType: 'sine' | 'square' | 'triangle' | 'sawtooth' | 'noise' = 'square';
  let sfxStartFreq = 440;
  let sfxEndFreq = 440;
  let sfxDuration = 0.25;
  let sfxSweep = 0; // custom sweep frequency change

  // Sound preset configs
  const presets = {
    jump: { waveType: 'square' as const, startFreq: 150, endFreq: 800, duration: 0.15 },
    laser: { waveType: 'sawtooth' as const, startFreq: 1200, endFreq: 100, duration: 0.2 },
    chime: { waveType: 'sine' as const, startFreq: 600, endFreq: 1200, duration: 0.3 },
    explosion: { waveType: 'noise' as const, startFreq: 400, endFreq: 50, duration: 0.4 },
    hurt: { waveType: 'triangle' as const, startFreq: 180, endFreq: 60, duration: 0.18 }
  };

  function applyPreset(name: 'jump' | 'laser' | 'chime' | 'explosion' | 'hurt') {
    const p = presets[name];
    sfxWaveType = p.waveType;
    sfxStartFreq = p.startFreq;
    sfxEndFreq = p.endFreq;
    sfxDuration = p.duration;
    sfxSweep = p.endFreq - p.startFreq;
    playSynthesizedPreview();
  }

  function playSynthesizedPreview() {
    if (isMuted) return;
    try {
      const ctx = getAudioContext();
      const now = ctx.currentTime;
      
      if (sfxWaveType === 'noise') {
        const bufferSize = ctx.sampleRate * sfxDuration;
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
          const t = i / ctx.sampleRate;
          const env = 1.0 - (t / sfxDuration);
          data[i] = (Math.random() * 2 - 1) * env * 0.25;
        }
        const noiseNode = ctx.createBufferSource();
        noiseNode.buffer = buffer;
        noiseNode.connect(ctx.destination);
        noiseNode.start(now);
      } else {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = sfxWaveType;
        
        osc.frequency.setValueAtTime(sfxStartFreq, now);
        osc.frequency.exponentialRampToValueAtTime(Math.max(10, sfxEndFreq), now + sfxDuration);
        
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + sfxDuration);
        
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + sfxDuration);
      }
    } catch (_) {}
  }

  function buildWav(samples: Int16Array, sampleRate = 22050): ArrayBuffer {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);

    writeString(view, 0, 'RIFF');
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(view, 8, 'WAVE');
    writeString(view, 12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);
    view.setUint16(22, 1, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 2, true);
    view.setUint16(32, 2, true);
    view.setUint16(34, 16, true);
    writeString(view, 36, 'data');
    view.setUint32(40, samples.length * 2, true);

    for (let i = 0; i < samples.length; i++) {
      view.setInt16(44 + i * 2, samples[i], true);
    }

    return buffer;
  }

  function writeString(view: DataView, offset: number, string: string) {
    for (let i = 0; i < string.length; i++) {
      view.setUint8(offset + i, string.charCodeAt(i));
    }
  }

  function arrayBufferToBase64(buffer: ArrayBuffer): string {
    let binary = '';
    const bytes = new Uint8Array(buffer);
    const len = bytes.byteLength;
    for (let i = 0; i < len; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
  }

  let isSavingAudio = false;
  let audioStatus = '';

  async function saveCustomAudio() {
    if (!targetAssetId) {
      audioStatus = 'Please draw and save a sprite first!';
      return;
    }
    
    isSavingAudio = true;
    audioStatus = 'Creating sound file...';

    try {
      const sampleRate = 22050;
      const totalSamples = Math.round(sfxDuration * sampleRate);
      const samples = new Int16Array(totalSamples);
      
      let phase = 0;
      for (let i = 0; i < totalSamples; i++) {
        const t = i / sampleRate;
        const ratio = t / sfxDuration;
        const freq = sfxStartFreq + (sfxEndFreq - sfxStartFreq) * ratio;
        phase += (2 * Math.PI * freq) / sampleRate;
        
        let val = 0;
        if (sfxWaveType === 'sine') {
          val = Math.sin(phase);
        } else if (sfxWaveType === 'square') {
          val = Math.sin(phase) >= 0 ? 1 : -1;
        } else if (sfxWaveType === 'triangle') {
          val = Math.abs((phase % (2 * Math.PI)) / Math.PI - 1) * 2 - 1;
        } else if (sfxWaveType === 'sawtooth') {
          val = (phase % (2 * Math.PI)) / Math.PI - 1;
        } else if (sfxWaveType === 'noise') {
          val = Math.random() * 2 - 1;
        }
        
        const env = 1.0 - ratio;
        const sampleVal = val * env * 0.3;
        
        samples[i] = Math.max(-32768, Math.min(32767, Math.round(sampleVal * 32767)));
      }
      
      const buffer = buildWav(samples, sampleRate);
      const base64Data = arrayBufferToBase64(buffer);
      
      audioStatus = 'Saving...';
      const result = await invoke<string>('save_custom_audio', {
        assetId: targetAssetId,
        category,
        base64Data
      });
      
      audioStatus = 'Saved successfully! 🎉';
      playDrawSound('chime');
      setTimeout(() => { audioStatus = ''; }, 3000);
    } catch (err: any) {
      console.error(err);
      audioStatus = `Failed to save: ${err}`;
    } finally {
      isSavingAudio = false;
    }
  }

  let pixels: string[][] = Array(GRID_SIZE)
    .fill(null)
    .map(() => Array(GRID_SIZE).fill('transparent'));

  // Run on visibility changes
  $: if (isVisible && canvasElement) {
    initCanvas();
    loadExistingSprite();
    activeTab = 'draw';
  }

  let audioCtx: AudioContext | null = null;
  function getAudioContext() {
    if (!audioCtx) {
      audioCtx = new (window.AudioContext || (window as any).webkitAudioContext)();
    }
    if (audioCtx.state === 'suspended') {
      audioCtx.resume();
    }
    return audioCtx;
  }

  function playDrawSound(type: 'draw' | 'clear' | 'chime') {
    if (isMuted) return;
    try {
      const ctx = getAudioContext();
      const now = ctx.currentTime;
      if (type === 'draw') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(1000 + Math.random() * 200, now);
        gain.gain.setValueAtTime(0.04, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.08);
      } else if (type === 'clear') {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(300, now);
        osc.frequency.exponentialRampToValueAtTime(80, now + 0.15);
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now);
        osc.stop(now + 0.15);
      } else if (type === 'chime') {
        const notes = [600, 800, 1000, 1200];
        notes.forEach((freq, i) => {
          const time = now + i * 0.04;
          const osc = ctx.createOscillator();
          const gain = ctx.createGain();
          osc.type = 'sine';
          osc.frequency.setValueAtTime(freq, time);
          gain.gain.setValueAtTime(0.05, time);
          gain.gain.exponentialRampToValueAtTime(0.001, time + 0.1);
          osc.connect(gain);
          gain.connect(ctx.destination);
          osc.start(time);
          osc.stop(time + 0.1);
        });
      }
    } catch (_) {}
  }

  const TEMPLATES = {
    sword: [
      '.......##.......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '......#..#......',
      '....###..###....',
      '....#......#....',
      '....########....',
      '......#..#......',
      '......#..#......',
      '.....##..##.....',
      '......####......'
    ],
    monster: [
      '......####......',
      '....##....##....',
      '..##........##..',
      '.#............#.',
      '#....#....#....#',
      '#...##....##...#',
      '#..............#',
      '#...#......#...#',
      '#....######....#',
      '.#............#.',
      '..##........##..',
      '....########....',
      '................',
      '................',
      '................',
      '................'
    ],
    coin: [
      '......####......',
      '....##....##....',
      '..##........##..',
      '.#...######...#.',
      '#...##....##...#',
      '#...#..##..#...#',
      '#...#..##..#...#',
      '#...#..##..#...#',
      '#...#..##..#...#',
      '#...#..##..#...#',
      '#...##....##...#',
      '.#...######...#.',
      '..##........##..',
      '....##....##....',
      '......####......',
      '................'
    ],
    heart: [
      '......####......',
      '....##....##....',
      '..##........##..',
      '.#............#.',
      '#..............#',
      '#..............#',
      '#..............#',
      '.#............#.',
      '..##........##..',
      '....##....##....',
      '......####......',
      '................',
      '................',
      '................',
      '................',
      '................'
    ],
    star: [
      '.......##.......',
      '......####......',
      '......####......',
      '....########....',
      '..############..',
      '...##########...',
      '....########....',
      '....########....',
      '...##########...',
      '..############..',
      '..##........##..',
      '.##..........##.',
      '................',
      '................',
      '................',
      '................'
    ],
    key: [
      '......####......',
      '....##....##....',
      '....#......#....',
      '....##....##....',
      '......####......',
      '......#..#......',
      '......#..#......',
      '......####......',
      '......#..#......',
      '......#..#......',
      '......####......',
      '......#..#......',
      '......#..#......',
      '......##........',
      '................',
      '................'
    ],
    crown: [
      '................',
      '.#....#...#....#',
      '.##..#.#.#.#..##',
      '.#.#.#.#.#.#.#.#',
      '.#..#.......#..#',
      '.#.............#',
      '.###############',
      '.###############',
      '.###############',
      '................',
      '................',
      '................',
      '................',
      '................',
      '................',
      '................'
    ]
  };

  // Undo/Redo history stack
  let history: string[][][] = [];
  let historyIndex = -1;

  function saveHistoryState() {
    if (historyIndex < history.length - 1) {
      history = history.slice(0, historyIndex + 1);
    }
    history.push(pixels.map(row => [...row]));
    historyIndex = history.length - 1;
    if (history.length > 50) {
      history.shift();
      historyIndex--;
    }
  }

  function handleUndo() {
    if (historyIndex > 0) {
      historyIndex--;
      pixels = history[historyIndex].map(row => [...row]);
      redrawGrid();
      triggerAutoSave();
      playDrawSound('draw');
    }
  }

  function handleRedo() {
    if (historyIndex < history.length - 1) {
      historyIndex++;
      pixels = history[historyIndex].map(row => [...row]);
      redrawGrid();
      triggerAutoSave();
      playDrawSound('draw');
    }
  }

  function applyTemplate(templateName: keyof typeof TEMPLATES) {
    const lines = TEMPLATES[templateName];
    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        if (lines[y][x] === '#') {
          pixels[y][x] = '#212121'; // black outline
        } else {
          pixels[y][x] = 'transparent';
        }
      }
    }
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('chime');
  }

  function initCanvas() {
    ctx = canvasElement.getContext('2d');
    if (!ctx) return;
    ctx.imageSmoothingEnabled = false;
  }

  // Animation frames state
  let frameList: string[][][] = [
    Array(GRID_SIZE).fill(null).map(() => Array(GRID_SIZE).fill('transparent'))
  ];
  let currentFrameIdx = 0;
  let isAnimPlaying = false;
  let animIntervalId: any = null;

  function addFrame() {
    if (frameList.length >= 4) return;
    // Save current frame before adding new one
    frameList[currentFrameIdx] = pixels.map(row => [...row]);
    
    // Duplicate current frame
    const newFrame = pixels.map(row => [...row]);
    frameList = [...frameList, newFrame];
    currentFrameIdx = frameList.length - 1;
    pixels = frameList[currentFrameIdx];
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('chime');
  }

  function deleteFrame(idx: number) {
    if (frameList.length <= 1) return;
    if (isAnimPlaying) toggleAnimPlayback();
    frameList = frameList.filter((_, i) => i !== idx);
    currentFrameIdx = Math.max(0, currentFrameIdx - 1);
    pixels = frameList[currentFrameIdx];
    redrawGrid();
    saveHistoryState();
    triggerAutoSave();
    playDrawSound('clear');
  }

  function selectFrame(idx: number) {
    if (isAnimPlaying) toggleAnimPlayback();
    // Save current editing grid into frameList
    frameList[currentFrameIdx] = pixels.map(row => [...row]);
    currentFrameIdx = idx;
    pixels = frameList[currentFrameIdx];
    redrawGrid();
    playDrawSound('draw');
  }

  function toggleAnimPlayback() {
    isAnimPlaying = !isAnimPlaying;
    if (isAnimPlaying) {
      // Save current frame before starting playback
      frameList[currentFrameIdx] = pixels.map(row => [...row]);
      animIntervalId = setInterval(() => {
        currentFrameIdx = (currentFrameIdx + 1) % frameList.length;
        pixels = frameList[currentFrameIdx];
        redrawGrid();
      }, 150); // 8fps loop
    } else {
      if (animIntervalId) {
        clearInterval(animIntervalId);
        animIntervalId = null;
      }
      // Re-align pixels to the correct current frame
      pixels = frameList[currentFrameIdx];
      redrawGrid();
    }
  }

  async function loadExistingSprite() {
    if (targetAssetId) {
      try {
        const loadedFrames = await invoke<string[][][]>('load_child_sprite', {
          assetId: targetAssetId,
          category: category
        });
        if (loadedFrames && loadedFrames.length > 0) {
          frameList = loadedFrames;
          currentFrameIdx = 0;
          pixels = frameList[0];
        }
      } catch (err) {
        console.error('Failed to load existing sprite:', err);
        frameList = [Array(GRID_SIZE).fill(null).map(() => Array(GRID_SIZE).fill('transparent'))];
        currentFrameIdx = 0;
        pixels = frameList[0];
      }
    } else {
      frameList = [Array(GRID_SIZE).fill(null).map(() => Array(GRID_SIZE).fill('transparent'))];
      currentFrameIdx = 0;
      pixels = frameList[0];
    }
    redrawGrid();
    // Reset history
    history = [pixels.map(row => [...row])];
    historyIndex = 0;
  }

  function redrawGrid() {
    if (!ctx || !canvasElement) return;
    ctx.clearRect(0, 0, canvasElement.width, canvasElement.height);

    const cellSize = canvasElement.width / GRID_SIZE;

    for (let y = 0; y < GRID_SIZE; y++) {
      for (let x = 0; x < GRID_SIZE; x++) {
        if (pixels[y][x] !== 'transparent') {
          ctx.fillStyle = pixels[y][x];
          ctx.fillRect(x * cellSize, y * cellSize, cellSize, cellSize);
        }
      }
    }
  }

  function paintPixel(x: number, y: number, color: string): boolean {
    const startX = x - Math.floor(brushSize / 2);
    const startY = y - Math.floor(brushSize / 2);
    let drawnAny = false;
    
    for (let dy = 0; dy < brushSize; dy++) {
      for (let dx = 0; dx < brushSize; dx++) {
        const px = startX + dx;
        const py = startY + dy;
        if (px >= 0 && px < GRID_SIZE && py >= 0 && py < GRID_SIZE) {
          if (pixels[py][px] !== color) {
            pixels[py][px] = color;
            drawnAny = true;
          }
        }
      }
    }
    return drawnAny;
  }

  function handlePointer(clientX: number, clientY: number) {
    if (!canvasElement || !ctx) return;
    const rect = canvasElement.getBoundingClientRect();
    const x = Math.floor((clientX - rect.left) / (canvasElement.width / GRID_SIZE));
    const y = Math.floor((clientY - rect.top) / (canvasElement.height / GRID_SIZE));

    if (x >= 0 && x < GRID_SIZE && y >= 0 && y < GRID_SIZE) {
      let colorToUse = isEraser ? 'transparent' : currentColor;
      if (isRainbowBrush && !isEraser && !isBucket) {
        colorToUse = `hsl(${rainbowHue}, 100%, 50%)`;
        rainbowHue = (rainbowHue + 15) % 360;
      }
      
      if (isBucket) {
        const targetColor = pixels[y][x];
        if (targetColor !== colorToUse) {
          floodFill(x, y, targetColor, colorToUse);
          redrawGrid();
          playDrawSound('chime');
        }
      } else {
        let drawnAny = false;
        drawnAny = paintPixel(x, y, colorToUse) || drawnAny;
        
        if (symmetryMode === 'horizontal' || symmetryMode === 'both') {
          drawnAny = paintPixel(GRID_SIZE - 1 - x, y, colorToUse) || drawnAny;
        }
        if (symmetryMode === 'vertical' || symmetryMode === 'both') {
          drawnAny = paintPixel(x, GRID_SIZE - 1 - y, colorToUse) || drawnAny;
        }
        if (symmetryMode === 'both') {
          drawnAny = paintPixel(GRID_SIZE - 1 - x, GRID_SIZE - 1 - y, colorToUse) || drawnAny;
        }
        
        if (drawnAny) {
          redrawGrid();
          playDrawSound('draw');
        }
      }
    }
  }

  function floodFill(startX: number, startY: number, targetColor: string, replacementColor: string) {
    if (targetColor === replacementColor) return;
    const queue: [number, number][] = [[startX, startY]];
    while (queue.length > 0) {
      const [cx, cy] = queue.shift()!;
      if (pixels[cy][cx] === targetColor) {
        pixels[cy][cx] = replacementColor;
        if (cx > 0) queue.push([cx - 1, cy]);
        if (cx < GRID_SIZE - 1) queue.push([cx + 1, cy]);
        if (cy > 0) queue.push([cx, cy - 1]);
        if (cy < GRID_SIZE - 1) queue.push([cx, cy + 1]);
      }
    }
  }

  async function triggerAutoSave() {
    if (!canvasElement) return;

    if (!targetAssetId) {
      const randomId = Math.random().toString(36).substring(2, 7);
      targetAssetId = `custom_${category.slice(0, 4)}_${randomId}`;
    }

    // Save current frame into frameList list
    frameList[currentFrameIdx] = pixels.map(row => [...row]);

    const isSpritesheetVal = frameList.length > 1 && (category === 'heroes' || category === 'enemies');
    const exportCanvas = document.createElement('canvas');
    
    if (isSpritesheetVal) {
      exportCanvas.width = GRID_SIZE * frameList.length;
      exportCanvas.height = GRID_SIZE;
    } else {
      exportCanvas.width = GRID_SIZE;
      exportCanvas.height = GRID_SIZE;
    }
    
    const exportCtx = exportCanvas.getContext('2d');
    if (!exportCtx) return;

    if (isSpritesheetVal) {
      for (let f = 0; f < frameList.length; f++) {
        const frameGrid = frameList[f];
        for (let y = 0; y < GRID_SIZE; y++) {
          for (let x = 0; x < GRID_SIZE; x++) {
            if (frameGrid[y][x] !== 'transparent') {
              exportCtx.fillStyle = frameGrid[y][x];
              exportCtx.fillRect(f * GRID_SIZE + x, y, 1, 1);
            }
          }
        }
      }
    } else {
      for (let y = 0; y < GRID_SIZE; y++) {
        for (let x = 0; x < GRID_SIZE; x++) {
          if (pixels[y][x] !== 'transparent') {
            exportCtx.fillStyle = pixels[y][x];
            exportCtx.fillRect(x, y, 1, 1);
          }
        }
      }
    }

    const base64Data = exportCanvas.toDataURL('image/png').split(',')[1];
    
    // Compile frames array coordinates
    const framesCoords = frameList.map((_, idx) => ({
      x: idx * GRID_SIZE,
      y: 0,
      w: GRID_SIZE,
      h: GRID_SIZE
    }));

    try {
      await invoke('save_child_sprite', {
        assetId: targetAssetId,
        category: category,
        base64Data: base64Data,
        isSpritesheet: isSpritesheetVal,
        frames: isSpritesheetVal ? framesCoords : null
      });
      dispatch('saved', targetAssetId);
    } catch (err) {
      console.error('Background sprite save failure:', err);
    }
  }

  function handleClear() {
    pixels = Array(GRID_SIZE)
      .fill(null)
      .map(() => Array(GRID_SIZE).fill('transparent'));
    redrawGrid();
    triggerAutoSave();
    playDrawSound('clear');
  }
</script>

{#if isVisible}
  <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
  <!-- svelte-ignore a11y_click_events_have_key_events -->
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')}>
    <div class="modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <header>
        <h2>🎨 Magic Brush</h2>
        <button class="close-btn" on:click={() => dispatch('close')}>✕ Done</button>
      </header>

      <div class="tabs-header">
        <button class="tab-btn" class:active={activeTab === 'draw'} on:click={() => activeTab = 'draw'}>🖌️ Draw Toy</button>
        <button class="tab-btn" class:active={activeTab === 'sound'} on:click={() => { activeTab = 'sound'; playDrawSound('chime'); }}>🎵 Toy Sound</button>
      </div>

      {#if activeTab === 'draw'}
        {#if !targetAssetId}
          <div class="category-panel">
            <span class="category-label">Choose Type:</span>
            <div class="category-options">
              <button class:active={category === 'decorations'} on:click={() => { category = 'decorations'; triggerAutoSave(); }}>🧸 Toy</button>
              <button class:active={category === 'terrain'} on:click={() => { category = 'terrain'; triggerAutoSave(); }}>🪨 Floor</button>
              <button class:active={category === 'heroes'} on:click={() => { category = 'heroes'; triggerAutoSave(); }}>🦸 Hero</button>
              <button class:active={category === 'enemies'} on:click={() => { category = 'enemies'; triggerAutoSave(); }}>👾 Monster</button>
              <button class:active={category === 'collectibles'} on:click={() => { category = 'collectibles'; triggerAutoSave(); }}>🪙 Reward</button>
            </div>
          </div>
        {/if}

        <div class="templates-panel">
          <span class="panel-label">Templates:</span>
          <div class="templates-buttons">
            <button class="tpl-btn" on:click={() => applyTemplate('sword')}>⚔️ Sword</button>
            <button class="tpl-btn" on:click={() => applyTemplate('monster')}>👾 Slime</button>
            <button class="tpl-btn" on:click={() => applyTemplate('coin')}>🪙 Coin</button>
            <button class="tpl-btn" on:click={() => applyTemplate('heart')}>❤️ Heart</button>
            <button class="tpl-btn" on:click={() => applyTemplate('star')}>⭐️ Star</button>
            <button class="tpl-btn" on:click={() => applyTemplate('key')}>🔑 Key</button>
            <button class="tpl-btn" on:click={() => applyTemplate('crown')}>👑 Crown</button>
          </div>
        </div>

        <div class="editor-workspace">
          <div class="canvas-area" style="display: flex; flex-direction: column; gap: 16px;">
            <!-- svelte-ignore a11y_no_static_element_interactions -->
            <canvas
              bind:this={canvasElement}
              width="360"
              height="360"
              class="draw-canvas"
              on:pointerdown={(e) => { isDrawing = true; handlePointer(e.clientX, e.clientY); }}
              on:pointermove={(e) => { if (isDrawing) handlePointer(e.clientX, e.clientY); }}
              on:pointerup={() => { if (isDrawing) { isDrawing = false; saveHistoryState(); triggerAutoSave(); } }}
              on:pointerleave={() => { isDrawing = false; }}
            ></canvas>

            {#if category === 'heroes' || category === 'enemies'}
              <div class="animation-timeline">
                <div class="timeline-frames">
                  {#each frameList as _, idx}
                    <button 
                      class="frame-tab" 
                      class:active={currentFrameIdx === idx} 
                      on:click={() => selectFrame(idx)}
                    >
                      🎬 {idx + 1}
                      {#if frameList.length > 1}
                        <span class="del-frame-x" on:click|stopPropagation={() => deleteFrame(idx)} role="button" tabindex="-1" title="Delete Frame">✕</span>
                      {/if}
                    </button>
                  {/each}
                  {#if frameList.length < 4}
                    <button class="frame-add-btn" on:click={addFrame}>➕ Copy Frame</button>
                  {/if}
                </div>
                <button class="anim-play-btn" class:playing={isAnimPlaying} on:click={toggleAnimPlayback}>
                  {isAnimPlaying ? '⏹️ Stop Preview' : '▶️ Loop Preview'}
                </button>
              </div>
            {/if}
          </div>

          <div class="side-panel">
            <div class="brush-selector">
              <button class="brush-btn" class:active={brushSize === 1 && !isBucket && !isEraser} on:click={() => { brushSize = 1; isBucket = false; isEraser = false; }} title="Small Brush">🟢 1x</button>
              <button class="brush-btn" class:active={brushSize === 2 && !isBucket && !isEraser} on:click={() => { brushSize = 2; isBucket = false; isEraser = false; }} title="Medium Brush">🟢 2x</button>
              <button class="brush-btn" class:active={brushSize === 3 && !isBucket && !isEraser} on:click={() => { brushSize = 3; isBucket = false; isEraser = false; }} title="Big Brush">🟢 3x</button>
            </div>

            <div class="colors-grid">
              {#each COLORS as color}
                <button
                  class="color-dot"
                  style:background={color}
                  class:selected={currentColor === color && !isEraser && !isBucket}
                  on:click={() => { currentColor = color; isEraser = false; isBucket = false; }}
                  aria-label="Color {color}"
                ></button>
              {/each}
            </div>

            <div class="brush-selector" style="margin-top: 10px; display: flex; flex-direction: column; gap: 8px; background: #0f172a; padding: 10px; border-radius: 14px; box-shadow: inset 0 2px 4px rgba(0,0,0,0.3); border: 2px solid #334155;">
              <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                <span style="font-size: 0.85rem; color: #94a3b8; font-weight: 800;">🪞 Mirror:</span>
                <select bind:value={symmetryMode} style="background: #1e293b; color: white; border: 1px solid #475569; border-radius: 6px; padding: 4px; font-size: 0.8rem; font-weight: bold; cursor: pointer; outline: none;">
                  <option value="none">None</option>
                  <option value="horizontal">↔️ Horiz</option>
                  <option value="vertical">↕️ Vert</option>
                  <option value="both">🔲 Both</option>
                </select>
              </div>
              <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                <span style="font-size: 0.85rem; color: #94a3b8; font-weight: 800;">🌈 Rainbow:</span>
                <input type="checkbox" bind:checked={isRainbowBrush} style="cursor: pointer; width: 16px; height: 16px; accent-color: #fbbf24;" />
              </div>
            </div>

            <div class="tool-actions">
              <button class="tool-btn undo-btn" disabled={historyIndex <= 0} on:click={handleUndo} title="Undo draw stroke">
                ↺ Undo
              </button>
              <button class="tool-btn redo-btn" disabled={historyIndex >= history.length - 1} on:click={handleRedo} title="Redo draw stroke">
                ↻ Redo
              </button>
              <button class="tool-btn eraser-btn" class:active={isEraser} on:click={() => { isEraser = true; isBucket = false; }}>
                🧽 Eraser
              </button>
              <button class="tool-btn bucket-btn" class:active={isBucket} on:click={() => { isBucket = true; isEraser = false; }}>
                🪣 Fill
              </button>
              <button class="tool-btn clear-btn" on:click={handleClear}>
                🗑️ Clear
              </button>
            </div>
          </div>
        </div>
      {:else}
        <div class="sound-studio-panel">
          <div class="presets-section">
            <span class="section-title">Presets 🎵</span>
            <div class="presets-buttons">
              <button class="preset-btn" on:click={() => applyPreset('jump')}>🦘 Jump</button>
              <button class="preset-btn" on:click={() => applyPreset('laser')}>🔫 Laser</button>
              <button class="preset-btn" on:click={() => applyPreset('chime')}>🪙 Chime</button>
              <button class="preset-btn" on:click={() => applyPreset('explosion')}>💥 Boom</button>
              <button class="preset-btn" on:click={() => applyPreset('hurt')}>🤕 Ouch</button>
            </div>
          </div>

          <div class="synth-controls">
            <span class="section-title">Sound Maker 🎛️</span>
            
            <div class="control-group">
              <span class="control-label">Wave Type:</span>
              <div class="wave-selectors">
                <button class="wave-btn" class:active={sfxWaveType === 'square'} on:click={() => { sfxWaveType = 'square'; playSynthesizedPreview(); }}>Square 🔳</button>
                <button class="wave-btn" class:active={sfxWaveType === 'sine'} on:click={() => { sfxWaveType = 'sine'; playSynthesizedPreview(); }}>Sine 〰️</button>
                <button class="wave-btn" class:active={sfxWaveType === 'triangle'} on:click={() => { sfxWaveType = 'triangle'; playSynthesizedPreview(); }}>Triangle 🔺</button>
                <button class="wave-btn" class:active={sfxWaveType === 'sawtooth'} on:click={() => { sfxWaveType = 'sawtooth'; playSynthesizedPreview(); }}>Saw 🪚</button>
                <button class="wave-btn" class:active={sfxWaveType === 'noise'} on:click={() => { sfxWaveType = 'noise'; playSynthesizedPreview(); }}>Noise 💨</button>
              </div>
            </div>

            <div class="control-group">
              <div class="control-label">
                <span>Start Pitch:</span>
                <span>{sfxStartFreq} Hz</span>
              </div>
              <input type="range" min="80" max="1800" step="10" class="control-slider" bind:value={sfxStartFreq} on:input={playSynthesizedPreview} />
            </div>

            <div class="control-group">
              <div class="control-label">
                <span>End Pitch:</span>
                <span>{sfxEndFreq} Hz</span>
              </div>
              <input type="range" min="80" max="1800" step="10" class="control-slider" bind:value={sfxEndFreq} on:input={playSynthesizedPreview} />
            </div>

            <div class="control-group">
              <div class="control-label">
                <span>Duration:</span>
                <span>{sfxDuration.toFixed(2)}s</span>
              </div>
              <input type="range" min="0.05" max="1.0" step="0.05" class="control-slider" bind:value={sfxDuration} on:input={playSynthesizedPreview} />
            </div>
          </div>

          <div class="action-buttons">
            <button class="action-btn play-btn" on:click={playSynthesizedPreview}>▶️ Listen</button>
            <button class="action-btn save-btn" on:click={saveCustomAudio} disabled={isSavingAudio || !targetAssetId}>
              {isSavingAudio ? 'Saving...' : '💾 Save Sound'}
            </button>
          </div>

          {#if audioStatus}
            <div class="audio-status">{audioStatus}</div>
          {/if}
        </div>
      {/if}
    </div>
  </div>
{/if}

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(15, 23, 42, 0.85);
    backdrop-filter: blur(8px);
    display: grid;
    place-items: center;
    z-index: 100;
  }

  .modal {
    background: #1e293b;
    border: 6px solid #fbbf24;
    border-radius: 40px;
    padding: 32px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 2px solid rgba(255, 255, 255, 0.1);
    padding-bottom: 12px;
  }

  h2 {
    margin: 0;
    color: #fbbf24;
    font-size: 2rem;
    font-weight: 900;
    letter-spacing: -0.5px;
  }

  .close-btn {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 4px 0 #b91c1c;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .close-btn:active {
    transform: translateY(4px);
    box-shadow: 0 0 0 #b91c1c;
  }

  .category-panel {
    display: flex;
    align-items: center;
    gap: 16px;
    background: #0f172a;
    padding: 12px 20px;
    border-radius: 20px;
  }

  .category-label {
    font-weight: 900;
    color: #94a3b8;
    font-size: 1rem;
  }

  .category-options {
    display: flex;
    gap: 10px;
  }

  .category-options button {
    border: 0;
    background: #334155;
    color: white;
    font-weight: 800;
    padding: 8px 16px;
    border-radius: 14px;
    cursor: pointer;
    font-size: 0.95rem;
    transition: background 0.2s, transform 0.1s;
  }

  .category-options button.active {
    background: #eab308;
    color: #0f172a;
    transform: scale(1.05);
  }

  .editor-workspace {
    display: flex;
    gap: 28px;
    align-items: stretch;
  }

  .draw-canvas {
    background: #0f172a;
    border: 4px solid #334155;
    border-radius: 24px;
    cursor: crosshair;
    touch-action: none;
    image-rendering: pixelated;
    box-shadow: inset 0 4px 10px rgba(0, 0, 0, 0.4);
  }

  .side-panel {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    width: 140px;
  }

  .colors-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .color-dot {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    border: 4px solid #1e293b;
    cursor: pointer;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
    transition: transform 0.1s;
  }

  .color-dot:hover {
    transform: scale(1.1);
  }

  .color-dot.selected {
    outline: 4px solid #fbbf24;
    transform: scale(1.05);
  }

  .tool-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-top: 20px;
  }

  .tool-btn {
    border: 0;
    border-radius: 18px;
    padding: 14px;
    font-size: 1.05rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.2);
    transition: transform 0.1s, background 0.2s;
  }

  .tool-btn:active {
    transform: translateY(2px);
  }

  .eraser-btn {
    background: #f1f5f9;
    color: #0f172a;
  }

  .eraser-btn.active {
    background: #fbbf24;
    color: #0f172a;
    outline: 4px solid white;
  }

  .clear-btn {
    background: #475569;
    color: white;
  }

  .bucket-btn {
    background: #e0f2fe;
    color: #0369a1;
  }

  .bucket-btn.active {
    background: #0284c7;
    color: white;
    outline: 4px solid white;
  }

  .templates-panel {
    display: flex;
    align-items: center;
    gap: 16px;
    background: #0f172a;
    padding: 12px 20px;
    border-radius: 20px;
  }

  .panel-label {
    font-weight: 900;
    color: #94a3b8;
    font-size: 1rem;
  }

  .templates-buttons {
    display: flex;
    gap: 10px;
  }

  .tpl-btn {
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 8px 16px;
    border-radius: 14px;
    cursor: pointer;
    font-size: 0.95rem;
    box-shadow: 0 4px 0 rgba(0, 0, 0, 0.25);
    transition: background 0.2s, transform 0.1s;
  }

  .tpl-btn:hover {
    background: #334155;
  }

  .tpl-btn:active {
    transform: translateY(2px);
  }

  .brush-selector {
    display: flex;
    gap: 6px;
    margin-bottom: 12px;
    background: #0f172a;
    padding: 6px;
    border-radius: 14px;
    justify-content: space-around;
  }

  .brush-btn {
    border: 0;
    background: #1e293b;
    color: #94a3b8;
    font-weight: 800;
    padding: 6px 10px;
    border-radius: 10px;
    cursor: pointer;
    font-size: 0.85rem;
    transition: background 0.2s, transform 0.1s;
  }

  .brush-btn.active {
    background: #fbbf24;
    color: #0f172a;
  }

  /* Tabs system */
  .tabs-header {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
    background: #0f172a;
    padding: 6px;
    border-radius: 16px;
  }

  .tab-btn {
    flex: 1;
    border: 0;
    background: transparent;
    color: #94a3b8;
    font-size: 1.05rem;
    font-weight: 800;
    padding: 10px;
    border-radius: 12px;
    cursor: pointer;
    transition: background 0.2s, color 0.2s;
  }

  .tab-btn.active {
    background: #fbbf24;
    color: #0f172a;
  }

  /* Sound Studio Panel */
  .sound-studio-panel {
    display: flex;
    flex-direction: column;
    gap: 20px;
    background: #0f172a;
    border: 4px solid #334155;
    border-radius: 24px;
    padding: 24px;
    color: white;
    width: 100%;
    box-sizing: border-box;
  }

  .presets-section {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .section-title {
    font-size: 1.1rem;
    font-weight: 900;
    color: #fbbf24;
    margin-bottom: 4px;
  }

  .presets-buttons {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 10px;
  }

  .preset-btn {
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 12px;
    border-radius: 14px;
    cursor: pointer;
    box-shadow: 0 4px 0 rgba(0,0,0,0.2);
    transition: background 0.2s, transform 0.1s;
    font-size: 0.9rem;
  }

  .preset-btn:hover {
    background: #334155;
  }

  .preset-btn:active {
    transform: translateY(2px);
  }

  .synth-controls {
    display: flex;
    flex-direction: column;
    gap: 14px;
    background: #1e293b;
    padding: 16px;
    border-radius: 18px;
  }

  .control-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .control-label {
    display: flex;
    justify-content: space-between;
    font-size: 0.9rem;
    font-weight: 800;
    color: #94a3b8;
  }

  .control-slider {
    width: 100%;
    accent-color: #fbbf24;
    cursor: pointer;
  }

  .wave-selectors {
    display: flex;
    gap: 6px;
    background: #0f172a;
    padding: 4px;
    border-radius: 10px;
  }

  .wave-btn {
    flex: 1;
    border: 0;
    background: transparent;
    color: #94a3b8;
    font-weight: 800;
    font-size: 0.8rem;
    padding: 6px;
    border-radius: 8px;
    cursor: pointer;
  }

  .wave-btn.active {
    background: #fbbf24;
    color: #0f172a;
  }

  .action-buttons {
    display: flex;
    gap: 16px;
  }

  .action-btn {
    flex: 1;
    border: 0;
    padding: 16px;
    border-radius: 18px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    box-shadow: 0 5px 0 rgba(0,0,0,0.25);
    transition: transform 0.1s;
  }

  .action-btn:active {
    transform: translateY(3px);
  }

  .play-btn {
    background: #10b981;
    color: white;
  }

  .save-btn {
    background: #fbbf24;
    color: #0f172a;
  }

  .audio-status {
    text-align: center;
    font-weight: 800;
    color: #fbbf24;
    min-height: 24px;
  }

  /* Timeline Styles */
  .animation-timeline {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #0f172a;
    padding: 10px 16px;
    border-radius: 18px;
    gap: 12px;
    border: 2px solid #334155;
  }

  .timeline-frames {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .frame-tab {
    position: relative;
    border: 0;
    background: #1e293b;
    color: white;
    font-weight: 800;
    padding: 8px 12px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .frame-tab.active {
    background: #fbbf24;
    color: #0f172a;
  }

  .del-frame-x {
    background: #ef4444;
    color: white;
    border: 0;
    border-radius: 50%;
    width: 16px;
    height: 16px;
    font-size: 0.7rem;
    cursor: pointer;
    display: grid;
    place-items: center;
    padding: 0;
    box-shadow: none;
    line-height: 1;
  }

  .frame-add-btn {
    border: 0;
    background: #10b981;
    color: white;
    font-weight: 800;
    padding: 8px 12px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
  }

  .anim-play-btn {
    border: 0;
    background: #6366f1;
    color: white;
    font-weight: 800;
    padding: 8px 14px;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.9rem;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
  }

  .anim-play-btn.playing {
    background: #ef4444;
  }
</style>
