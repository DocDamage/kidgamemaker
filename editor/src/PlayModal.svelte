<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { pauseGameIframe, restartGameIframe } from './lib/playbackControls';

  export let isVisible = false;
  export let isMuted = false;

  const dispatch = createEventDispatcher<{
    close: void;
    status: string;
    toggleMute: void;
    restartSound: void;
    launchWindow: void;
  }>();

  let isPaused = false;
  let wasVisible = false;

  $: if (isVisible && !wasVisible) {
    isPaused = false;
  }

  $: wasVisible = isVisible;

  function togglePauseGame() {
    const nextPaused = !isPaused;
    const result = pauseGameIframe(nextPaused);
    if (result.ok) {
      isPaused = nextPaused;
      if (result.status) {
        dispatch('status', result.status);
      }
    } else if (result.error !== 'Game iframe is not available.') {
      console.error('Failed to pause game:', result.error);
    }
  }

  function restartGame() {
    const result = restartGameIframe();
    if (result.ok) {
      isPaused = false;
      if (result.status) {
        dispatch('status', result.status);
      }
      dispatch('restartSound');
    } else if (result.error !== 'Game iframe is not available.') {
      console.error('Failed to restart game:', result.error);
    }
  }

  function close() {
    isPaused = false;
    dispatch('close');
  }

  function launchWindow() {
    isPaused = false;
    dispatch('launchWindow');
  }
</script>

{#if isVisible}
  <div class="backdrop" role="button" tabindex="-1" on:click={close}>
    <div class="modal play-modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <header class="play-header">
        <h2>🎮 Playing Game! 🎮</h2>
        <div class="play-controls-overlay">
          <button class="play-control-btn mute-btn-overlay" on:click={() => dispatch('toggleMute')} title="Toggle Sound">
            {isMuted ? '🔇' : '🔊'}
          </button>
          <button class="play-control-btn pause-btn" on:click={togglePauseGame} title={isPaused ? 'Resume' : 'Pause'}>
            {isPaused ? '▶ Resume' : '⏸ Pause'}
          </button>
          <button class="play-control-btn restart-btn" on:click={restartGame} title="Restart level">
            🔄 Restart
          </button>
          <button class="play-control-btn stop-btn" on:click={close} title="Exit game">
            🛑 Exit
          </button>
        </div>
      </header>
      <div class="game-container">
        <iframe src="/game/index.html" title="KidGameMaker Embedded Play View" class="game-iframe"></iframe>
      </div>
      <div class="play-options">
        <button class="window-btn" on:click={launchWindow}>📺 Run in Large Window</button>
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

  .play-modal {
    width: min(850px, 90vw);
    max-height: 90vh;
  }

  .play-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
  }

  h2 {
    margin: 0;
    font-size: 1.8rem;
    color: #22c55e;
  }

  .play-controls-overlay {
    display: flex;
    gap: 12px;
  }

  .play-control-btn {
    border: 0;
    border-radius: 20px;
    padding: 10px 20px;
    font-size: 1.1rem;
    font-weight: 900;
    cursor: pointer;
    color: white;
    transition: transform 0.1s, box-shadow 0.1s;
  }

  .play-control-btn:active {
    transform: translateY(3px);
  }

  .mute-btn-overlay {
    background: #374151;
    box-shadow: 0 5px 0 #1f2937;
  }

  .pause-btn {
    background: #eab308;
    box-shadow: 0 5px 0 #ca8a04;
  }

  .pause-btn:active {
    box-shadow: 0 2px 0 #ca8a04;
  }

  .restart-btn {
    background: #3b82f6;
    box-shadow: 0 5px 0 #1d4ed8;
  }

  .restart-btn:active {
    box-shadow: 0 2px 0 #1d4ed8;
  }

  .stop-btn {
    background: #ef4444;
    box-shadow: 0 5px 0 #b91c1c;
  }

  .stop-btn:active {
    box-shadow: 0 2px 0 #b91c1c;
  }

  .game-container {
    width: 100%;
    aspect-ratio: 16 / 9;
    background: black;
    border-radius: 20px;
    overflow: hidden;
    border: 4px solid #4b5563;
  }

  .game-iframe {
    width: 100%;
    height: 100%;
    border: 0;
  }

  .play-options {
    display: flex;
    justify-content: center;
    margin-top: 10px;
  }

  .window-btn {
    border: 0;
    border-radius: 18px;
    padding: 12px 24px;
    font-weight: 900;
    cursor: pointer;
    background: #3b82f6;
    color: white;
    box-shadow: 0 4px 0 #1d4ed8;
  }

  .window-btn:active {
    transform: translateY(2px);
    box-shadow: 0 1px 0 #1d4ed8;
  }
</style>
