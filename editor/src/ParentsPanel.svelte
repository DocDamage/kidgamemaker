<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import type { ToyboxAsset, WorldSettings } from './lib/canvasState';
  import type { DifficultyMode } from './lib/roomPersistence';
  import AgeModeSelector from './AgeModeSelector.svelte';

  export let rooms: string[] = [];
  export let activeRoomId = '';
  export let activeAsset: ToyboxAsset;
  export let difficultyMode: DifficultyMode = 'normal';
  export let calmMode = false;
  export let worldSettings: WorldSettings;
  export let placedCount = 0;
  export let sessionStampsCount = 0;
  export let creationDurationSeconds = 0;
  export let cloudSyncPending = false;
  export let cloudSyncStatus = 'Not synced';

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
    healthStyleChange: 'hearts' | 'diegetic';
    peerBlockingChange: boolean;
    cloudSync: void;
  }>();

  // Math challenge gate state
  let isGated = true;
  let numA = 0;
  let numB = 0;
  let userAnswer = '';
  let mathError = '';

  function generateMathProblem() {
    numA = Math.floor(Math.random() * 8) + 3; // 3 to 10
    numB = Math.floor(Math.random() * 8) + 3;
    userAnswer = '';
    mathError = '';
  }

  onMount(() => {
    generateMathProblem();
  });

  function verifyGate() {
    const ans = parseInt(userAnswer);
    if (ans === numA + numB) {
      isGated = false;
      mathError = '';
    } else {
      mathError = '🔒 Math puzzle incorrect! Try again.';
      userAnswer = '';
    }
  }

  // Screen time & peer blocking state
  let screenTimeLimit = Number(localStorage.getItem('parent_screen_time_limit') || '30');
  let peerBlockingEnabled = localStorage.getItem('parent_peer_blocking') === 'true';

  function handleTimeLimitChange(e: Event) {
    const target = e.target as HTMLInputElement;
    screenTimeLimit = Number(target.value);
    localStorage.setItem('parent_screen_time_limit', String(screenTimeLimit));
  }

  function handlePeerBlockingChange(e: Event) {
    const target = e.target as HTMLInputElement;
    peerBlockingEnabled = target.checked;
    localStorage.setItem('parent_peer_blocking', String(peerBlockingEnabled));
    dispatch('peerBlockingChange', peerBlockingEnabled);
  }

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

  function formatDuration(seconds: number) {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  }
</script>

<div class="parents-panel-container">
  {#if isGated}
    <div class="gate-overlay">
      <div class="gate-box">
        <h3>🔒 Parent Verification Gate</h3>
        <p class="gate-desc">Please solve this simple math puzzle to verify you are a parent or supervisor.</p>
        <div class="math-question">
          <span>{numA} + {numB} = </span>
          <input 
            type="number" 
            bind:value={userAnswer} 
            placeholder="?" 
            on:keydown={(e) => e.key === 'Enter' && verifyGate()}
          />
        </div>
        {#if mathError}
          <p class="math-error">{mathError}</p>
        {/if}
        <div class="gate-buttons">
          <button class="verify-btn" on:click={verifyGate}>Unlock Panel</button>
          <button class="reset-gate-btn" on:click={generateMathProblem}>🔄 Refresh</button>
        </div>
      </div>
    </div>
  {/if}

  <div class="parents-panel-header">
    <h3>⚙️ Parents & Developers Settings</h3>
  </div>

  <div class="parents-panel-body" class:blur-gated={isGated}>
    <div class="left-settings-column">
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
        <h4>Actions & Cloud</h4>
        <div class="panel-row">
          <button id="btn-save" class="save" on:click={(event) => dispatchClick(event, 'saveRoom')}>💾 SAVE</button>
          <button id="btn-export" class="export" on:click={(event) => dispatchClick(event, 'exportGame')}>📦 EXPORT</button>
          <button id="btn-share" class="share" on:click={(event) => dispatchClick(event, 'shareGame')} disabled={peerBlockingEnabled}>
            {peerBlockingEnabled ? '🔏 SHARING DISABLED' : '✨ SHARE TOYBOX (.ktoy)'}
          </button>
          <button id="btn-refresh-toybox" class="icon-btn refresh-btn" on:click={(event) => dispatchClick(event, 'refreshInventory')} title="Refresh Toybox from disk">🔄 RELOAD</button>
        </div>
        <div class="panel-row" style="margin-top: 8px;">
          <button id="btn-cloud-sync" class="cloud-sync-btn" on:click={(event) => { animateClick(event); dispatch('cloudSync'); }} disabled={cloudSyncPending}>
            {cloudSyncPending ? '⏳ SYNCING...' : '☁️ CLOUD BACKUP SYNC'}
          </button>
          <span class="cloud-status-text" class:syncing={cloudSyncPending}>{cloudSyncStatus}</span>
        </div>
      </div>

      <div class="panel-section">
        <h4>🎮 Game Mode Accessibility</h4>
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

      <div class="panel-section">
        <h4>❤️ Character Health Style</h4>
        <div class="panel-row">
          <select 
            id="health-style-selector" 
            value={worldSettings.health_style || 'hearts'} 
            on:change={(event) => dispatch('healthStyleChange', event.currentTarget.value as 'hearts' | 'diegetic')}
          >
            <option value="hearts">❤️ Hearts HUD (Classic hearts on screen)</option>
            <option value="diegetic">💥 Diegetic Health (Scratches, cracks, and flashing overlay!)</option>
          </select>
        </div>
      </div>
    </div>

    <div class="right-parental-column">
      <div class="panel-section dashboard-metrics">
        <h4>📊 Child Activity Metrics</h4>
        <div class="metrics-grid">
          <div class="metric-card">
            <span class="metric-val">{placedCount}</span>
            <span class="metric-lbl">Current Room Objects</span>
          </div>
          <div class="metric-card">
            <span class="metric-val">{sessionStampsCount}</span>
            <span class="metric-lbl">Stamps Placed This Session</span>
          </div>
          <div class="metric-card">
            <span class="metric-val">{formatDuration(creationDurationSeconds)}</span>
            <span class="metric-lbl">Time Creating</span>
          </div>
        </div>
      </div>

      <div class="panel-section parental-controls">
        <h4>⏳ Screen Time Limit</h4>
        <div class="control-box">
          <div class="slider-row">
            <input 
              type="range" 
              min="5" 
              max="120" 
              step="5" 
              value={screenTimeLimit} 
              on:input={handleTimeLimitChange}
            />
            <span class="limit-value">{screenTimeLimit} minutes</span>
          </div>
          <p class="parent-hint">Alerts are shown when the playtime matches this duration.</p>
        </div>
      </div>

      <div class="panel-section safety-controls">
        <h4>🔒 Sharing & Safety</h4>
        <div class="control-box">
          <label class="toggle-label">
            <input 
              type="checkbox" 
              checked={peerBlockingEnabled} 
              on:change={handlePeerBlockingChange}
            />
            🛡️ Block Local Network Sharing
          </label>
          <p class="parent-hint">Turning this on disables LAN sharing of game packages (.ktoy) with peers.</p>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  .parents-panel-container {
    background: #0f172a;
    border-bottom: 4px solid #374151;
    padding: 16px 24px;
    position: relative;
    color: white;
  }

  .gate-overlay {
    position: absolute;
    inset: 0;
    background: rgba(15, 23, 42, 0.95);
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
  }

  .gate-box {
    background: #1e293b;
    border: 3px solid #f59e0b;
    border-radius: 16px;
    padding: 24px;
    max-width: 420px;
    width: 90%;
    text-align: center;
    box-shadow: 0 10px 25px rgba(0,0,0,0.5);
  }

  .gate-box h3 {
    margin-top: 0;
    color: #fbbf24;
  }

  .gate-desc {
    font-size: 0.9rem;
    color: #94a3b8;
    margin-bottom: 16px;
  }

  .math-question {
    font-size: 1.6rem;
    font-weight: 800;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    margin-bottom: 12px;
  }

  .math-question input {
    width: 80px;
    background: #0f172a;
    border: 2px solid #4b5563;
    border-radius: 8px;
    color: white;
    font-size: 1.4rem;
    padding: 4px;
    text-align: center;
  }

  .math-error {
    color: #ef4444;
    font-weight: bold;
    font-size: 0.9rem;
    margin-top: 8px;
  }

  .gate-buttons {
    display: flex;
    gap: 12px;
    justify-content: center;
    margin-top: 16px;
  }

  .verify-btn {
    background: #10b981;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 8px 16px;
    font-weight: bold;
    cursor: pointer;
  }

  .verify-btn:hover {
    background: #059669;
  }

  .reset-gate-btn {
    background: #4b5563;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 8px 16px;
    cursor: pointer;
  }

  .parents-panel-header h3 {
    margin: 0 0 12px 0;
    font-size: 1.1rem;
    color: #fbbf24;
  }

  .parents-panel-body {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 32px;
    transition: filter 0.3s;
  }

  .parents-panel-body.blur-gated {
    filter: blur(5px);
    pointer-events: none;
    user-select: none;
  }

  .left-settings-column, .right-parental-column {
    display: flex;
    flex-direction: column;
    gap: 16px;
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
    flex-wrap: wrap;
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

  /* Action buttons base style */
  .save,
  .export,
  .share,
  .icon-btn,
  .bookshelf-btn {
    border: none;
    border-radius: 10px;
    padding: 8px 14px;
    font-size: 0.85rem;
    font-weight: 800;
    cursor: pointer;
    letter-spacing: 0.4px;
    transition: transform 0.1s, box-shadow 0.1s, background 0.15s;
    box-shadow: 0 4px 0 rgba(0,0,0,0.35);
  }

  .save,
  .export,
  .share,
  .icon-btn,
  .bookshelf-btn {
    color: white;
  }

  .save:hover,
  .export:hover,
  .share:hover:not(:disabled),
  .icon-btn:hover,
  .bookshelf-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 0 rgba(0,0,0,0.35);
  }

  .save:active,
  .export:active,
  .share:active:not(:disabled),
  .icon-btn:active,
  .bookshelf-btn:active {
    transform: translateY(2px);
    box-shadow: 0 2px 0 rgba(0,0,0,0.25);
  }

  .save {
    background: #f59e0b;
    box-shadow: 0 4px 0 #b45309;
  }

  .save:hover {
    background: #d97706;
    box-shadow: 0 6px 0 #92400e;
  }

  .export {
    background: #10b981;
    box-shadow: 0 4px 0 #065f46;
  }

  .export:hover {
    background: #059669;
  }

  .share {
    background: #a855f7;
    box-shadow: 0 4px 0 #6b21a8;
  }

  .share:disabled {
    background: #374151;
    color: #9ca3af;
    cursor: not-allowed;
    box-shadow: none;
    transform: none;
  }

  .icon-btn {
    background: #334155;
    box-shadow: 0 4px 0 #1e293b;
    padding: 8px 12px;
    font-size: 0.8rem;
  }

  .icon-btn:hover {
    background: #475569;
  }

  .bookshelf-btn {
    background: #1d4ed8;
    box-shadow: 0 4px 0 #1e3a8a;
  }

  .bookshelf-btn:hover {
    background: #1e40af;
  }

  .refresh-btn {
    background: #0f766e;
    box-shadow: 0 4px 0 #134e4a;
  }

  .refresh-btn:hover {
    background: #0d9488;
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

  /* Right column / metrics styles */
  .metrics-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
  }

  .metric-card {
    background: #1e293b;
    border: 1px solid #334155;
    border-radius: 10px;
    padding: 12px;
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
  }

  .metric-val {
    font-size: 1.3rem;
    font-weight: 800;
    color: #fbbf24;
  }

  .metric-lbl {
    font-size: 0.7rem;
    color: #94a3b8;
    margin-top: 4px;
    line-height: 1.1;
  }

  .control-box {
    background: #1e293b;
    border-radius: 10px;
    padding: 12px 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .slider-row {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .slider-row input[type="range"] {
    flex: 1;
    accent-color: #fbbf24;
  }

  .limit-value {
    font-weight: bold;
    color: #fbbf24;
    white-space: nowrap;
  }

  .parent-hint {
    font-size: 0.75rem;
    color: #94a3b8;
    margin: 0;
  }

  .toggle-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: bold;
    cursor: pointer;
  }

  .toggle-label input {
    width: 18px;
    height: 18px;
    accent-color: #fbbf24;
  }

  .cloud-sync-btn {
    background: #0284c7;
    color: white;
    box-shadow: 0 4px 0 #0369a1;
  }

  .cloud-sync-btn:hover:not(:disabled) {
    background: #0369a1;
  }

  .cloud-sync-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .cloud-status-text {
    font-size: 0.8rem;
    font-weight: bold;
    color: #38bdf8;
    max-width: 320px;
    word-break: break-all;
    line-height: 1.2;
  }

  .cloud-status-text.syncing {
    color: #fbbf24;
  }
</style>

