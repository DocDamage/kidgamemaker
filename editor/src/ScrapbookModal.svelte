<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';

  export let isVisible = false;

  const dispatch = createEventDispatcher<{
    close: void;
  }>();

  interface Achievement {
    id: string;
    title: string;
    description: string;
    emoji: string;
    color: string;
  }

  const ACHIEVEMENTS: Achievement[] = [
    {
      id: 'jungle_explorer',
      title: 'Jungle Explorer 🌴',
      description: 'Create a room with the Jungle theme!',
      emoji: '🌴',
      color: '#10b981'
    },
    {
      id: 'lava_runner',
      title: 'Lava Runner 🌋',
      description: 'Create a room with the Volcano theme!',
      emoji: '🌋',
      color: '#f97316'
    },
    {
      id: 'monster_masher',
      title: 'Monster Masher 👾',
      description: 'Summon 3 or more cheeky monsters in your level!',
      emoji: '👾',
      color: '#ec4899'
    },
    {
      id: 'coop_champ',
      title: 'Co-Op Champ 👥',
      description: 'Place 2 player start points for a cooperative game!',
      emoji: '👥',
      color: '#3b82f6'
    },
    {
      id: 'temporal_master',
      title: 'Temporal Master ⏳',
      description: 'Hold B (Player 1) or N (Player 2) to rewind time in play mode!',
      emoji: '⏳',
      color: '#a855f7'
    },
    {
      id: 'sound_designer',
      title: 'Sound Designer 🎹',
      description: 'Compose and save a custom synthesized chiptune BGM!',
      emoji: '🎹',
      color: '#fbbf24'
    },
    {
      id: 'world_architect',
      title: 'World Architect 🎲',
      description: 'Auto-generate a connected Spelunky-style world!',
      emoji: '🎲',
      color: '#06b6d4'
    }
  ];

  let unlockedIds: string[] = [];

  function loadAchievements() {
    try {
      const stored = localStorage.getItem('scrapbook_stickers');
      if (stored) {
        unlockedIds = JSON.parse(stored);
      } else {
        unlockedIds = [];
      }
    } catch (_) {
      unlockedIds = [];
    }
  }

  $: if (isVisible) {
    loadAchievements();
  }

  function close() {
    dispatch('close');
  }

  function clearAllStickers() {
    if (confirm("Are you sure you want to reset your Sticker Book? You will lose all your achievement stamps!")) {
      try {
        localStorage.removeItem('scrapbook_stickers');
        loadAchievements();
      } catch (_) {}
    }
  }
</script>

{#if isVisible}
  <div class="backdrop" role="button" tabindex="-1" on:click={close}>
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <div class="modal scrapbook-modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <header class="scrapbook-header">
        <h2>🏆 My Toybox Sticker Book 🏆</h2>
        <span class="count-badge">✨ {unlockedIds.length} / {ACHIEVEMENTS.length} Stickers Earned! ✨</span>
      </header>

      <div class="sticker-grid">
        {#each ACHIEVEMENTS as ach}
          {@const isUnlocked = unlockedIds.includes(ach.id)}
          <div class="sticker-card" class:unlocked={isUnlocked} style:--accent-color={ach.color}>
            <div class="sticker-wrapper">
              <span class="sticker-emoji">{ach.emoji}</span>
              {#if !isUnlocked}
                <span class="lock-overlay">🔒</span>
              {/if}
            </div>
            <div class="sticker-info">
              <h3>{ach.title}</h3>
              <p>{ach.description}</p>
            </div>
          </div>
        {/each}
      </div>

      <div class="scrapbook-footer">
        <button class="reset-btn" on:click={clearAllStickers} title="Reset stickers">🧹 Reset Book</button>
        <button class="close-btn" on:click={close}>Close Book ✕</button>
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
    background: #2a1f3d;
    border: 8px solid #a855f7;
    border-radius: 40px;
    padding: 30px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.7);
    display: flex;
    flex-direction: column;
    gap: 24px;
    max-width: 750px;
    width: 90vw;
    max-height: 85vh;
    overflow-y: auto;
  }

  .scrapbook-header {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    text-align: center;
  }

  .scrapbook-header h2 {
    margin: 0;
    font-size: 2.2rem;
    font-weight: 900;
    color: #fca5a5;
    text-shadow: 0 4px 0px rgba(0, 0, 0, 0.4);
  }

  .count-badge {
    background: #f472b6;
    color: white;
    font-weight: 900;
    padding: 6px 20px;
    border-radius: 20px;
    font-size: 1rem;
    box-shadow: 0 4px 0 #db2777;
    transform: rotate(-1.5deg);
  }

  .sticker-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
    margin-top: 10px;
  }

  .sticker-card {
    background: #1e1b4b;
    border: 4px solid #3730a3;
    border-radius: 24px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 12px;
    opacity: 0.65;
    filter: grayscale(100%);
    transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
  }

  .sticker-card.unlocked {
    opacity: 1;
    filter: none;
    background: #312e81;
    border-color: var(--accent-color);
    box-shadow: 0 8px 0 var(--accent-color), 0 12px 20px rgba(0,0,0,0.4);
    transform: translateY(-4px) rotate(calc(random() * 4deg - 2deg));
  }

  .sticker-card.unlocked:hover {
    transform: scale(1.05) rotate(0deg);
  }

  .sticker-wrapper {
    position: relative;
    width: 80px;
    height: 80px;
    background: rgba(15, 23, 42, 0.6);
    border-radius: 50%;
    display: grid;
    place-items: center;
    border: 3px dashed #4338ca;
  }

  .sticker-card.unlocked .sticker-wrapper {
    background: white;
    border-color: var(--accent-color);
    animation: pulse-glow 2s infinite alternate;
  }

  @keyframes pulse-glow {
    from { box-shadow: 0 0 4px rgba(255,255,255,0.2); }
    to { box-shadow: 0 0 12px var(--accent-color); }
  }

  .sticker-emoji {
    font-size: 3rem;
    line-height: 1;
  }

  .lock-overlay {
    position: absolute;
    bottom: -2px;
    right: -2px;
    background: #475569;
    border-radius: 50%;
    width: 24px;
    height: 24px;
    display: grid;
    place-items: center;
    font-size: 0.9rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.5);
  }

  .sticker-info h3 {
    margin: 0;
    font-size: 1.05rem;
    font-weight: 800;
    color: white;
  }

  .sticker-info p {
    margin: 6px 0 0 0;
    font-size: 0.78rem;
    color: #94a3b8;
    line-height: 1.3;
  }

  .sticker-card.unlocked .sticker-info h3 {
    color: #ffd84d;
  }

  .sticker-card.unlocked .sticker-info p {
    color: #cbd5e1;
  }

  .scrapbook-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 12px;
  }

  .close-btn {
    background: #a855f7;
    color: white;
    border: none;
    border-radius: 16px;
    padding: 10px 24px;
    font-weight: bold;
    font-size: 1.1rem;
    cursor: pointer;
    box-shadow: 0 4px 0 #7e22ce;
  }

  .close-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 #7e22ce;
  }

  .reset-btn {
    background: #ef4444;
    color: white;
    border: none;
    border-radius: 12px;
    padding: 8px 16px;
    font-weight: bold;
    font-size: 0.85rem;
    cursor: pointer;
    box-shadow: 0 3px 0 #b91c1c;
    opacity: 0.8;
  }

  .reset-btn:hover {
    opacity: 1;
  }

  .reset-btn:active {
    transform: translateY(2px);
    box-shadow: 0 1px 0 #b91c1c;
  }
</style>
