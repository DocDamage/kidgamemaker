<script lang="ts">
  import { onDestroy } from 'svelte';
  import { invoke } from '@tauri-apps/api/core';
  import {
    SFX_PRESETS,
    playSpriteEditorSound,
    previewSfx,
    synthesizeSfxBase64,
    type SfxPresetName,
    type SfxWaveType
  } from './lib/spriteEditorAudio';
  import { formatUnknownError } from './lib/spriteEditorConfig';

  export let targetAssetId = '';
  export let category = 'decorations';
  export let isMuted = false;

  // Synthesizer parameters
  let sfxWaveType: SfxWaveType = 'square';
  let sfxStartFreq = 440;
  let sfxEndFreq = 440;
  let sfxDuration = 0.25;
  let sfxSweep = 0; // custom sweep frequency change

  function currentSfxParams() {
    return {
      waveType: sfxWaveType,
      startFreq: sfxStartFreq,
      endFreq: sfxEndFreq,
      duration: sfxDuration
    };
  }

  function applyPreset(name: SfxPresetName) {
    const p = SFX_PRESETS[name];
    sfxWaveType = p.waveType;
    sfxStartFreq = p.startFreq;
    sfxEndFreq = p.endFreq;
    sfxDuration = p.duration;
    sfxSweep = p.endFreq - p.startFreq;
    playSynthesizedPreview();
  }

  function playSynthesizedPreview() {
    previewSfx(currentSfxParams(), isMuted);
  }

  let isSavingAudio = false;
  let audioStatus = '';
  let audioStatusTimeoutId: ReturnType<typeof setTimeout> | null = null;

  async function saveCustomAudio() {
    if (!targetAssetId) {
      audioStatus = 'Please draw and save a sprite first!';
      return;
    }
    
    isSavingAudio = true;
    audioStatus = 'Creating sound file...';

    try {
      const base64Data = synthesizeSfxBase64(currentSfxParams());
      
      audioStatus = 'Saving...';
      await invoke<string>('save_custom_audio', {
        assetId: targetAssetId,
        category,
        base64Data
      });
      
      audioStatus = 'Saved successfully! 🎉';
      playSpriteEditorSound('chime', isMuted);
      clearAudioStatusTimeout();
      audioStatusTimeoutId = setTimeout(() => {
        audioStatus = '';
        audioStatusTimeoutId = null;
      }, 3000);
    } catch (err: unknown) {
      console.error(err);
      audioStatus = `Failed to save: ${formatUnknownError(err)}`;
    } finally {
      isSavingAudio = false;
    }
  }

  function clearAudioStatusTimeout() {
    if (audioStatusTimeoutId) {
      clearTimeout(audioStatusTimeoutId);
      audioStatusTimeoutId = null;
    }
  }

  onDestroy(() => {
    clearAudioStatusTimeout();
  });
</script>

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

<style>
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
</style>
