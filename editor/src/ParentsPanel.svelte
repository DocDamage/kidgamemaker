<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { ToyboxAsset, WorldSettings } from './lib/canvasState';
  import type { DifficultyMode } from './lib/roomPersistence';
  import AgeModeSelector from './AgeModeSelector.svelte';

  export let rooms: string[] = [];
  export let activeRoomId = '';
  export let activeAsset: ToyboxAsset;
  export let difficultyMode: DifficultyMode = 'normal';
  export let calmMode = false;
  export let worldSettings: WorldSettings;

  const dispatch = createEventDispatcher<{
    browseRooms: void;
    activeRoomIdChange: string;
    loadRoom: string;
    createNewRoom: void;
    saveRoom: void;
    exportGame: void;
    shareGame: void;
    refreshInventory: void;
    difficultyChange: string;
    calmModeChange: boolean;
    ageModeChange: Partial<WorldSettings>;
  }>();

  function animateClick(event: MouseEvent) {
    const target = event.currentTarget as HTMLElement;
    target.classList.remove('bounce-click');
    void target.offsetWidth;
    target.classList.add('bounce-click');
  }

  function dispatchClick(event: MouseEvent, eventName: 'browseRooms' | 'createNewRoom' | 'saveRoom' | 'exportGame' | 'shareGame' | 'refreshInventory') {
    animateClick(event);
    dispatch(eventName);
  }
</script>

<div class="parents-panel-container">
  <div class="parents-panel-header">
    <h3>⚙️ Parents & Developers Settings</h3>
  </div>
  <div class="parents-panel-body">
    <div class="panel-section">
      <h4>Room Manager</h4>
      <div class="panel-row">
        <button class="bookshelf-btn" on:click={(event) => dispatchClick(event, 'browseRooms')}>📚 Browse Rooms</button>
        <select id="room-selector" value={activeRoomId} on:change={(event) => dispatch('loadRoom', event.currentTarget.value)}>
          {#each rooms as room}
            <option value={room}>{room}</option>
          {/each}
        </select>
        <input
          id="room-name-input"
          type="text"
          value={activeRoomId}
          placeholder="Room ID"
          title="Change Room Name"
          on:input={(event) => dispatch('activeRoomIdChange', event.currentTarget.value)}
        />
        <button id="btn-new-room" class="icon-btn" on:click={(event) => dispatchClick(event, 'createNewRoom')} title="New Room">➕ New</button>
      </div>
    </div>

    <div class="panel-section">
      <h4>Actions</h4>
      <div class="panel-row">
        <button id="btn-save" class="save" on:click={(event) => dispatchClick(event, 'saveRoom')}>💾 SAVE</button>
        <button id="btn-export" class="export" on:click={(event) => dispatchClick(event, 'exportGame')}>📦 EXPORT</button>
        <button id="btn-share" class="share" on:click={(event) => dispatchClick(event, 'shareGame')}>✨ SHARE TOYBOX (.ktoy)</button>
        <button id="btn-refresh-toybox" class="icon-btn refresh-btn" on:click={(event) => dispatchClick(event, 'refreshInventory')} title="Refresh Toybox from disk">🔄 RELOAD</button>
      </div>
    </div>

    <div class="panel-section">
      <h4>Active Toy Specs</h4>
      <div class="panel-row spec-labels">
        <span><strong>ID:</strong> {activeAsset.id}</span>
        <span><strong>Category:</strong> {activeAsset.category}</span>
        <span><strong>Snap Type:</strong> {activeAsset.snapping_type || 'default'}</span>
      </div>
    </div>

    <div class="panel-section">
      <h4>🎮 Game Mode</h4>
      <AgeModeSelector
        {worldSettings}
        onUpdate={(patch) => dispatch('ageModeChange', patch)}
      />
    </div>

    <div class="panel-section">
      <h4>🛡️ Fine-tune Difficulty</h4>
      <div class="panel-row">
        <select id="difficulty-selector" value={difficultyMode} on:change={(event) => dispatch('difficultyChange', event.currentTarget.value)}>
          <option value="easy">🌟 Easy Mode (50% damage, 200% HP)</option>
          <option value="normal">⚔️ Normal Mode</option>
          <option value="creative">🌈 Creative Mode (Invincible!)</option>
        </select>
      </div>
      <div class="panel-row calm-row">
        <label>
          <input
            type="checkbox"
            checked={calmMode}
            on:change={(event) => dispatch('calmModeChange', event.currentTarget.checked)}
          />
          🌼 Calm Mode (Friendly enemies, no game over)
        </label>
      </div>
    </div>
  </div>
</div>

<style>
  .parents-panel-container {
    background: #0f172a;
    border-bottom: 4px solid #374151;
    padding: 16px 24px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    color: white;
  }

  .parents-panel-header h3 {
    margin: 0;
    font-size: 1.1rem;
    color: #fbbf24;
  }

  .parents-panel-body {
    display: flex;
    gap: 32px;
    flex-wrap: wrap;
  }

  .panel-section {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .panel-section h4 {
    margin: 0;
    font-size: 0.85rem;
    color: #9ca3af;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .panel-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .panel-row select,
  .panel-row input[type='text'] {
    background: #1f2937;
    color: white;
    border: 1px solid #4b5563;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 0.9rem;
    font-weight: 700;
  }

  .panel-row input[type='text'] {
    width: 140px;
  }

  .spec-labels {
    font-family: monospace;
    font-size: 0.85rem;
    color: #cbd5e1;
    gap: 16px;
  }

  .export {
    background: #10b981;
    color: white;
  }

  .share {
    background: #a855f7;
    color: white;
  }

  .calm-row {
    gap: 12px;
    margin-top: 8px;
  }

  .calm-row label {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #e2e8f0;
    font-weight: 700;
    cursor: pointer;
  }

  .calm-row input {
    width: 20px;
    height: 20px;
    accent-color: #10b981;
    cursor: pointer;
  }
</style>
