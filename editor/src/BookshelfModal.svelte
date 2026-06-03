<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let isVisible = false;
  export let rooms: string[] = [];
  export let activeRoomId: string = '';

  const dispatch = createEventDispatcher<{
    selectRoom: string;
    newRoom: void;
    deleteRoom: string;
    close: void;
  }>();

  const TIME_ICONS: Record<string, string> = {
    day: '☀️',
    morning: '🌅',
    sunset: '🌇',
    night: '🌙'
  };

  function handleKey(e: KeyboardEvent) {
    if (e.key === 'Escape') dispatch('close');
  }
</script>

{#if isVisible}
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    class="backdrop"
    role="button"
    tabindex="-1"
    on:click={() => dispatch('close')}
    on:keydown={handleKey}
  >
    <!-- svelte-ignore a11y_no_noninteractive_element_interactions -->
    <div
      class="shelf-modal"
      role="dialog"
      aria-modal="true"
      aria-label="Game Bookshelf"
      tabindex="0"
      on:click|stopPropagation
      on:keydown|stopPropagation
    >
      <header>
        <div class="shelf-title">
          <span class="shelf-icon">📚</span>
          <h2>My Rooms</h2>
        </div>
        <div class="shelf-header-actions">
          <button class="new-btn" id="bookshelf-new-room" on:click={() => dispatch('newRoom')}>
            ➕ New Room
          </button>
          <button class="close-btn" on:click={() => dispatch('close')}>✕</button>
        </div>
      </header>

      <div class="rooms-grid">
        {#each rooms as room}
          {@const isActive = room === activeRoomId}
          <div
            class="room-card"
            class:active={isActive}
            id="bookshelf-room-{room}"
          >
            <div class="room-thumb">
              <span class="room-thumb-icon">{isActive ? '🖊️' : '🗺️'}</span>
            </div>

            <div class="room-info">
              <strong class="room-name" title={room}>{room}</strong>
              {#if isActive}
                <span class="active-badge">Editing</span>
              {/if}
            </div>

            <div class="room-actions">
              <button
                class="open-btn"
                id="bookshelf-open-{room}"
                on:click={() => dispatch('selectRoom', room)}
                disabled={isActive}
              >
                {isActive ? 'Open' : '▶ Open'}
              </button>
              {#if !isActive}
                <button
                  class="delete-btn"
                  id="bookshelf-delete-{room}"
                  title="Delete room"
                  on:click={() => dispatch('deleteRoom', room)}
                >
                  🗑
                </button>
              {/if}
            </div>
          </div>
        {/each}

        {#if rooms.length === 0}
          <div class="empty-state">
            <span>📭</span>
            <p>No rooms yet. Press <strong>New Room</strong> to start!</p>
          </div>
        {/if}
      </div>
    </div>
  </div>
{/if}

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.65);
    backdrop-filter: blur(4px);
    display: grid;
    place-items: center;
    z-index: 60;
    animation: fade-in 0.15s ease;
  }

  @keyframes fade-in {
    from { opacity: 0; }
    to   { opacity: 1; }
  }

  .shelf-modal {
    width: min(860px, 94vw);
    max-height: 88vh;
    overflow: auto;
    border-radius: 28px;
    background: linear-gradient(160deg, #1a1f35 0%, #111827 100%);
    color: white;
    padding: 28px 32px;
    box-shadow: 0 32px 90px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(255,255,255,0.06);
    animation: slide-up 0.2s cubic-bezier(0.34, 1.56, 0.64, 1);
  }

  @keyframes slide-up {
    from { transform: translateY(24px); opacity: 0; }
    to   { transform: translateY(0);    opacity: 1; }
  }

  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 16px;
    margin-bottom: 28px;
  }

  .shelf-title {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .shelf-icon {
    font-size: 2rem;
    filter: drop-shadow(0 2px 6px rgba(255,200,60,0.4));
  }

  h2 {
    margin: 0;
    font-size: 1.6rem;
    font-weight: 900;
    background: linear-gradient(90deg, #ffd84d, #f9a825);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .shelf-header-actions {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .new-btn {
    background: linear-gradient(135deg, #22c55e, #16a34a);
    color: white;
    border: 0;
    border-radius: 18px;
    padding: 10px 20px;
    font-weight: 900;
    font-size: 0.95rem;
    cursor: pointer;
    box-shadow: 0 4px 0 rgba(0,0,0,0.3);
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .new-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 0 rgba(0,0,0,0.3);
  }

  .new-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 rgba(0,0,0,0.3);
  }

  .close-btn {
    background: rgba(255,255,255,0.08);
    color: white;
    border: 0;
    border-radius: 50%;
    width: 40px;
    height: 40px;
    font-size: 1rem;
    cursor: pointer;
    display: grid;
    place-items: center;
    transition: background 0.15s;
  }

  .close-btn:hover {
    background: rgba(255,255,255,0.15);
  }

  .rooms-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
  }

  .room-card {
    background: rgba(255, 255, 255, 0.05);
    border: 2px solid rgba(255, 255, 255, 0.08);
    border-radius: 20px;
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 10px;
    transition: border-color 0.15s, background 0.15s, transform 0.15s;
  }

  .room-card:hover {
    background: rgba(255, 255, 255, 0.08);
    border-color: rgba(255, 255, 255, 0.18);
    transform: translateY(-2px);
  }

  .room-card.active {
    border-color: #ffd84d;
    background: rgba(255, 216, 77, 0.08);
    box-shadow: 0 0 0 1px rgba(255,216,77,0.3);
  }

  .room-thumb {
    background: rgba(0, 0, 0, 0.25);
    border-radius: 14px;
    height: 88px;
    display: grid;
    place-items: center;
  }

  .room-thumb-icon {
    font-size: 2.6rem;
  }

  .room-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .room-name {
    font-size: 0.9rem;
    font-weight: 800;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: #e2e8f0;
  }

  .active-badge {
    font-size: 0.72rem;
    font-weight: 700;
    color: #ffd84d;
    background: rgba(255, 216, 77, 0.15);
    border-radius: 8px;
    padding: 2px 8px;
    display: inline-block;
    width: fit-content;
  }

  .room-actions {
    display: flex;
    gap: 8px;
    align-items: center;
    margin-top: auto;
  }

  .open-btn {
    flex: 1;
    background: linear-gradient(135deg, #6366f1, #4f46e5);
    color: white;
    border: 0;
    border-radius: 14px;
    padding: 8px 12px;
    font-weight: 800;
    font-size: 0.85rem;
    cursor: pointer;
    box-shadow: 0 3px 0 rgba(0,0,0,0.3);
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .open-btn:not(:disabled):hover {
    transform: translateY(-1px);
    box-shadow: 0 5px 0 rgba(0,0,0,0.3);
  }

  .open-btn:active {
    transform: translateY(2px);
    box-shadow: 0 1px 0 rgba(0,0,0,0.3);
  }

  .open-btn:disabled {
    background: rgba(255,255,255,0.1);
    color: rgba(255,255,255,0.4);
    cursor: default;
    box-shadow: none;
  }

  .delete-btn {
    background: rgba(239, 68, 68, 0.15);
    color: #ef4444;
    border: 0;
    border-radius: 12px;
    width: 36px;
    height: 36px;
    font-size: 1rem;
    cursor: pointer;
    display: grid;
    place-items: center;
    transition: background 0.15s;
  }

  .delete-btn:hover {
    background: rgba(239, 68, 68, 0.3);
  }

  .empty-state {
    grid-column: 1 / -1;
    text-align: center;
    padding: 48px 24px;
    color: rgba(255,255,255,0.35);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
  }

  .empty-state span {
    font-size: 3rem;
  }

  .empty-state p {
    margin: 0;
    font-size: 1rem;
  }
</style>
