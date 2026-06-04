<script lang="ts">
  import type { AgeMode, WorldSettings } from './lib/canvasState';
  import { getAgeModeDefaults } from './lib/canvasState';

  export let worldSettings: WorldSettings;
  export let onUpdate: (patch: Partial<WorldSettings>) => void;

  const currentMode: AgeMode = (worldSettings.age_mode as AgeMode) ?? 'growing';

  const MODES: Array<{
    id: AgeMode;
    emoji: string;
    label: string;
    sub: string;
    color: string;
    bg: string;
  }> = [
    {
      id: 'mellow',
      emoji: '🌈',
      label: 'Mellow',
      sub: 'Ages 4–6 · Big grid · Friendly world',
      color: '#7ecfff',
      bg: 'rgba(126,207,255,0.12)'
    },
    {
      id: 'growing',
      emoji: '⚡',
      label: 'Growing',
      sub: 'Ages 7–8 · Normal grid · Some challenge',
      color: '#a8ff78',
      bg: 'rgba(168,255,120,0.12)'
    },
    {
      id: 'creator',
      emoji: '🔥',
      label: 'Creator',
      sub: 'Ages 9+ · Free grid · Full control',
      color: '#ffb347',
      bg: 'rgba(255,179,71,0.12)'
    }
  ];

  function select(mode: AgeMode) {
    const defaults = getAgeModeDefaults(mode);
    onUpdate(defaults);
  }
</script>

<div class="age-mode-selector">
  <div class="age-mode-header">
    <span class="age-mode-icon">🎮</span>
    <div>
      <div class="age-mode-title">Game Mode</div>
      <div class="age-mode-desc">Choose who's playing — changes grid size, speed, and how much help the game gives.</div>
    </div>
  </div>

  <div class="age-mode-cards">
    {#each MODES as mode}
      <button
        class="age-mode-card"
        class:selected={currentMode === mode.id}
        style:--accent={mode.color}
        style:--bg={mode.bg}
        on:click={() => select(mode.id)}
        id="age-mode-{mode.id}"
      >
        <span class="age-mode-card-emoji">{mode.emoji}</span>
        <span class="age-mode-card-label">{mode.label}</span>
        <span class="age-mode-card-sub">{mode.sub}</span>
        {#if currentMode === mode.id}
          <span class="age-mode-check">✓</span>
        {/if}
      </button>
    {/each}
  </div>
</div>

<style>
  .age-mode-selector {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    border-radius: 12px;
    padding: 14px 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .age-mode-header {
    display: flex;
    gap: 10px;
    align-items: flex-start;
  }

  .age-mode-icon {
    font-size: 22px;
    line-height: 1;
    flex-shrink: 0;
  }

  .age-mode-title {
    font-size: 13px;
    font-weight: 700;
    color: rgba(255, 255, 255, 0.92);
    letter-spacing: 0.02em;
  }

  .age-mode-desc {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.45);
    margin-top: 2px;
    line-height: 1.4;
  }

  .age-mode-cards {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .age-mode-card {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    background: var(--bg);
    border: 1.5px solid rgba(255, 255, 255, 0.08);
    border-radius: 9px;
    cursor: pointer;
    text-align: left;
    position: relative;
    transition: border-color 0.15s, background 0.15s, transform 0.1s;
    width: 100%;
  }

  .age-mode-card:hover {
    border-color: var(--accent);
    transform: translateX(2px);
  }

  .age-mode-card.selected {
    border-color: var(--accent);
    background: color-mix(in srgb, var(--accent) 16%, transparent);
    box-shadow: 0 0 0 1px var(--accent) inset;
  }

  .age-mode-card-emoji {
    font-size: 20px;
    flex-shrink: 0;
    line-height: 1;
  }

  .age-mode-card-label {
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
    min-width: 62px;
    flex-shrink: 0;
  }

  .age-mode-card-sub {
    font-size: 11px;
    color: rgba(255, 255, 255, 0.45);
    flex: 1;
  }

  .age-mode-check {
    position: absolute;
    right: 10px;
    top: 50%;
    transform: translateY(-50%);
    color: var(--accent);
    font-size: 14px;
    font-weight: 700;
  }
</style>
