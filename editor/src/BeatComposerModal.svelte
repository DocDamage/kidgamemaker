<script lang="ts">
  import { createEventDispatcher, onDestroy } from 'svelte';
  import { playBeatCellPreview, tickBeatPreview } from './lib/editorAudio';

  type BeatSequence = number[][];

  export let isVisible = false;
  export let initialSequence: BeatSequence | undefined = undefined;
  export let initialInstruments: string[] | undefined = undefined;

  const dispatch = createEventDispatcher<{
    save: { sequence: BeatSequence; instruments: string[] };
    close: void;
    previewStart: void;
  }>();

  const DEFAULT_SEQUENCE: BeatSequence = [
    [1, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 1, 1, 1, 1, 1, 1],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ];

  const INSTRUMENTS = ['🥁 Kick', '🥁 Snare', '🔔 Hi-Hat', '🎵 Bass'];
  const ACTIVE_COLORS = ['#ef4444', '#3b82f6', '#eab308', '#a855f7'];

  let sequence: BeatSequence = cloneSequence(DEFAULT_SEQUENCE);
  let instruments: string[] = ['sine', 'triangle', 'triangle', 'sawtooth'];
  let previewing = false;
  let currentPreviewStep = 0;
  let previewIntervalId: ReturnType<typeof setInterval> | null = null;
  let wasVisible = false;

  $: if (isVisible && !wasVisible) {
    sequence = cloneSequence(initialSequence && initialSequence.length > 0 ? initialSequence : DEFAULT_SEQUENCE);
    instruments = initialInstruments && initialInstruments.length === 4 ? [...initialInstruments] : ['sine', 'triangle', 'triangle', 'sawtooth'];
    previewing = false;
    currentPreviewStep = 0;
  }

  $: if (!isVisible && wasVisible) {
    stopPreview();
  }

  $: wasVisible = isVisible;

  function cloneSequence(source: BeatSequence): BeatSequence {
    return source.map((row) => [...row]);
  }

  function togglePreview() {
    previewing = !previewing;
    if (previewing) {
      currentPreviewStep = 0;
      previewIntervalId = setInterval(tickPreview, 150);
      dispatch('previewStart');
    } else {
      stopPreview();
    }
  }

  function tickPreview() {
    currentPreviewStep = tickBeatPreview(sequence, currentPreviewStep, instruments);
  }

  function toggleBeatCell(row: number, col: number) {
    sequence[row][col] = sequence[row][col] ? 0 : 1;
    sequence = cloneSequence(sequence);
    playBeatCellPreview(row, instruments[row] as OscillatorType);
  }

  function stopPreview() {
    if (previewIntervalId) {
      clearInterval(previewIntervalId);
      previewIntervalId = null;
    }
    previewing = false;
  }

  function close() {
    stopPreview();
    dispatch('close');
  }

  function save() {
    stopPreview();
    dispatch('save', { sequence: cloneSequence(sequence), instruments: [...instruments] });
  }

  onDestroy(stopPreview);
</script>

{#if isVisible}
  <div class="backdrop" role="button" tabindex="-1" on:click={close}>
    <div class="modal composer-modal" role="dialog" tabindex="0" on:click|stopPropagation>
      <h2>🎹 Chiptune Beat Composer 🎹</h2>
      <p>
        Click the boxes to compose your own chiptune loop! Hit play to listen.
      </p>

      <div class="sequencer-grid">
        {#each INSTRUMENTS as instName, rIndex}
          <div class="seq-row">
            <div class="instrument-selector-box">
              <span class="inst-label">{instName}</span>
              <select class="synth-select" bind:value={instruments[rIndex]} on:change={() => playBeatCellPreview(rIndex, instruments[rIndex] as OscillatorType)}>
                <option value="sine">〰️ Sine</option>
                <option value="square">🔳 Square</option>
                <option value="triangle">🔺 Triangle</option>
                <option value="sawtooth">🪚 Sawtooth</option>
              </select>
            </div>
            {#each Array(8) as _, cIndex}
              {@const isActive = sequence[rIndex][cIndex] === 1}
              <button
                class="seq-cell"
                aria-label="Instrument {rIndex} Step {cIndex + 1}"
                style:background={isActive ? ACTIVE_COLORS[rIndex] : '#334155'}
                style:border-color={previewing && currentPreviewStep === cIndex ? '#ffffff' : 'transparent'}
                on:click={() => toggleBeatCell(rIndex, cIndex)}
              ></button>
            {/each}
          </div>
        {/each}
      </div>

      <div class="composer-actions">
        <button
          class="preview-button"
          class:previewing
          on:click={togglePreview}
        >
          {previewing ? '⏹️ STOP' : '▶️ PLAY PREVIEW'}
        </button>
        <button class="save-button" on:click={save}>
          💾 SAVE BEAT
        </button>
        <button class="close-button" on:click={close}>
          ✕
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
    background: #1e293b;
    border: 6px solid #fbbf24;
    border-radius: 40px;
    padding: 20px;
    color: white;
    box-shadow: 0 30px 70px rgba(0, 0, 0, 0.6);
    display: flex;
    flex-direction: column;
    gap: 20px;
    max-width: 530px;
    width: 90vw;
  }

  h2 {
    margin: 0;
    text-align: center;
  }

  p {
    font-size: 0.9rem;
    color: #94a3b8;
    text-align: center;
    margin: 0 0 16px;
  }

  .sequencer-grid {
    display: grid;
    gap: 8px;
    margin-bottom: 20px;
  }

  .seq-row {
    display: grid;
    grid-template-columns: 120px repeat(8, 1fr);
    align-items: center;
    gap: 6px;
  }

  .instrument-selector-box {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: flex-start;
  }

  .inst-label {
    font-size: 0.8rem;
    font-weight: bold;
    color: white;
  }

  .synth-select {
    background: #0f172a;
    color: #fbbf24;
    border: 2px solid #fbbf24;
    border-radius: 8px;
    padding: 3px 6px;
    font-size: 0.7rem;
    cursor: pointer;
    width: 100%;
    outline: none;
    font-weight: bold;
  }

  .synth-select:hover {
    background: #1e293b;
  }

  .seq-cell {
    aspect-ratio: 1;
    border-radius: 6px;
    cursor: pointer;
    transition: transform 0.1s;
    width: 100%;
    border: 2px solid transparent;
  }

  .composer-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    width: 100%;
  }

  .composer-actions button {
    padding: 10px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 1rem;
    border: none;
    cursor: pointer;
    color: white;
  }

  .preview-button,
  .save-button {
    flex: 1;
  }

  .preview-button {
    background: #10b981;
  }

  .preview-button.previewing {
    background: #ef4444;
  }

  .save-button {
    background: #6366f1;
  }

  .close-button {
    padding: 10px 16px;
    background: #475569;
  }
</style>
