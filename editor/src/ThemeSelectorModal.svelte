<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import {
    ROOM_ADJECTIVES,
    ROOM_NOUNS,
    getThemeEmoji,
    randomRoomNoun,
    type ThemeName
  } from './lib/themeRooms';

  export let isVisible = false;
  export let initialTheme: ThemeName = 'space';
  export let initialAdjective = 'Super';
  export let initialNoun = 'World';

  const dispatch = createEventDispatcher<{
    create: { theme: ThemeName; adjective: string; noun: string };
    close: void;
  }>();

  const themes: ThemeName[] = ['space', 'candy', 'jungle', 'ice', 'volcano'];
  const adjectives = ROOM_ADJECTIVES;
  const nouns = ROOM_NOUNS;

  let selectedTheme: ThemeName = initialTheme;
  let selectedAdjective = initialAdjective;
  let selectedNoun = initialNoun;
  let wasVisible = false;

  $: if (isVisible && !wasVisible) {
    selectedTheme = initialTheme;
    selectedAdjective = initialAdjective;
    selectedNoun = initialNoun;
  }

  $: wasVisible = isVisible;

  function selectTheme(theme: ThemeName) {
    selectedTheme = theme;
    selectedNoun = randomRoomNoun(theme);
  }

  function createRoom() {
    dispatch('create', {
      theme: selectedTheme,
      adjective: selectedAdjective,
      noun: selectedNoun
    });
  }
</script>

{#if isVisible}
  <div class="backdrop" role="button" tabindex="-1" on:click={() => dispatch('close')}>
    <div class="modal theme-modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <h2>🌟 Create & Name Your New Adventure! 🌟</h2>

      <div class="preview-banner">
        <span>{getThemeEmoji(selectedTheme)}</span>
        <span>{selectedAdjective}</span>
        <span>{selectedNoun}</span>
      </div>

      <div class="picker-section">
        <h3>1. Choose Theme</h3>
        <div class="theme-grid">
          {#each themes as theme}
            <button
              class="theme-card-mini"
              class:selected={selectedTheme === theme}
              on:click={() => selectTheme(theme)}
            >
              <span class="theme-icon">{getThemeEmoji(theme)}</span>
              <span>{theme.toUpperCase()}</span>
            </button>
          {/each}
        </div>
      </div>

      <div class="picker-section">
        <h3>2. Choose a Fun Word</h3>
        <div class="word-grid">
          {#each adjectives as adjective}
            <button
              class:selected={selectedAdjective === adjective}
              on:click={() => selectedAdjective = adjective}
            >
              {adjective}
            </button>
          {/each}
        </div>
      </div>

      <div class="picker-section noun-section">
        <h3>3. Choose a Place</h3>
        <div class="word-grid">
          {#each nouns[selectedTheme] as noun}
            <button
              class:selected={selectedNoun === noun}
              on:click={() => selectedNoun = noun}
            >
              {noun}
            </button>
          {/each}
        </div>
      </div>

      <div class="actions">
        <button class="create-button" on:click={createRoom}>
          ✨ CREATE ROOM! 🚀
        </button>
        <button class="cancel-button" on:click={() => dispatch('close')}>
          ✕ CANCEL
        </button>
      </div>
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
    background: #0f172a;
    border: 4px solid #334155;
    border-radius: 32px;
    padding: 30px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
    max-width: 650px;
  }

  h2 {
    color: white;
    margin: 0 0 20px;
    font-size: 1.8rem;
    font-weight: 800;
    text-align: center;
  }

  .preview-banner {
    background: #1e293b;
    padding: 14px 20px;
    border-radius: 20px;
    border: 3px solid #fbbf24;
    margin-bottom: 24px;
    font-size: 2rem;
    font-weight: 900;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: #fbbf24;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.5);
    box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.8);
  }

  .picker-section {
    margin-bottom: 20px;
  }

  .noun-section {
    margin-bottom: 30px;
  }

  h3 {
    color: #94a3b8;
    font-size: 1.1rem;
    margin: 0 0 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    text-align: center;
  }

  .theme-grid {
    display: flex;
    gap: 10px;
    justify-content: center;
    flex-wrap: wrap;
  }

  .theme-card-mini {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 12px;
    width: 100px;
    border-radius: 20px;
    border: 3px solid #334155;
    background: #1e293b;
    color: white;
    cursor: pointer;
    transition: transform 0.15s, border-color 0.15s;
  }

  .theme-card-mini.selected {
    border-color: #fbbf24;
    background: rgba(251, 191, 36, 0.15);
  }

  .theme-icon {
    font-size: 2.2rem;
    margin-bottom: 4px;
  }

  .theme-card-mini span:last-child {
    font-size: 0.9rem;
    font-weight: 700;
  }

  .word-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
    max-width: 580px;
    margin: 0 auto;
  }

  .word-grid button {
    padding: 8px 16px;
    border-radius: 12px;
    border: none;
    font-weight: 800;
    cursor: pointer;
    font-size: 1rem;
    background: #1e293b;
    color: #94a3b8;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
    transition: all 0.1s;
  }

  .word-grid button.selected {
    background: #fbbf24;
    color: #0f172a;
  }

  .actions {
    display: flex;
    gap: 16px;
    justify-content: center;
  }

  .actions button {
    border: none;
    cursor: pointer;
  }

  .create-button {
    background: #10b981;
    color: white;
    padding: 12px 36px;
    border-radius: 18px;
    font-size: 1.3rem;
    font-weight: 900;
    box-shadow: 0 6px 12px rgba(16, 185, 129, 0.3);
  }

  .cancel-button {
    background: #ef4444;
    color: white;
    padding: 12px 24px;
    border-radius: 18px;
    font-size: 1.1rem;
    font-weight: 700;
  }
</style>
