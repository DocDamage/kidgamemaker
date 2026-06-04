import { createAudioContext } from './webAudio';

export type SfxWaveType = 'sine' | 'square' | 'triangle' | 'sawtooth' | 'noise';
export type SfxPresetName = 'jump' | 'laser' | 'chime' | 'explosion' | 'hurt';

export type SfxParams = {
  waveType: SfxWaveType;
  startFreq: number;
  endFreq: number;
  duration: number;
};

export const SFX_PRESETS: Record<SfxPresetName, SfxParams> = {
  jump: { waveType: 'square', startFreq: 150, endFreq: 800, duration: 0.15 },
  laser: { waveType: 'sawtooth', startFreq: 1200, endFreq: 100, duration: 0.2 },
  chime: { waveType: 'sine', startFreq: 600, endFreq: 1200, duration: 0.3 },
  explosion: { waveType: 'noise', startFreq: 400, endFreq: 50, duration: 0.4 },
  hurt: { waveType: 'triangle', startFreq: 180, endFreq: 60, duration: 0.18 }
};

let audioCtx: AudioContext | null = null;

export function previewSfx(params: SfxParams, isMuted: boolean): void {
  if (isMuted) return;
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;

    if (params.waveType === 'noise') {
      const bufferSize = Math.max(1, Math.round(ctx.sampleRate * params.duration));
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        const t = i / ctx.sampleRate;
        const env = 1.0 - t / params.duration;
        data[i] = (Math.random() * 2 - 1) * env * 0.25;
      }
      const noiseNode = ctx.createBufferSource();
      noiseNode.buffer = buffer;
      noiseNode.connect(ctx.destination);
      noiseNode.start(now);
      return;
    }

    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = params.waveType;
    osc.frequency.setValueAtTime(params.startFreq, now);
    osc.frequency.exponentialRampToValueAtTime(Math.max(10, params.endFreq), now + params.duration);
    gain.gain.setValueAtTime(0.08, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + params.duration);
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.start(now);
    osc.stop(now + params.duration);
  } catch (_) {
    // Audio preview is non-critical and may be unavailable in some webviews.
  }
}

export function synthesizeSfxBase64(params: SfxParams, sampleRate = 22050): string {
  const totalSamples = Math.max(1, Math.round(params.duration * sampleRate));
  const samples = new Int16Array(totalSamples);
  let phase = 0;

  for (let i = 0; i < totalSamples; i++) {
    const t = i / sampleRate;
    const ratio = t / params.duration;
    const freq = params.startFreq + (params.endFreq - params.startFreq) * ratio;
    phase += (2 * Math.PI * freq) / sampleRate;

    let val = 0;
    if (params.waveType === 'sine') {
      val = Math.sin(phase);
    } else if (params.waveType === 'square') {
      val = Math.sin(phase) >= 0 ? 1 : -1;
    } else if (params.waveType === 'triangle') {
      val = Math.abs((phase % (2 * Math.PI)) / Math.PI - 1) * 2 - 1;
    } else if (params.waveType === 'sawtooth') {
      val = (phase % (2 * Math.PI)) / Math.PI - 1;
    } else if (params.waveType === 'noise') {
      val = Math.random() * 2 - 1;
    }

    const env = 1.0 - ratio;
    const sampleVal = val * env * 0.3;
    samples[i] = Math.max(-32768, Math.min(32767, Math.round(sampleVal * 32767)));
  }

  return arrayBufferToBase64(buildWav(samples, sampleRate));
}

export function playSpriteEditorSound(type: 'draw' | 'clear' | 'chime', isMuted: boolean): void {
  if (isMuted) return;
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;

    if (type === 'draw') {
      playTone(ctx, now, 520, 0.03, 0.025);
    } else if (type === 'clear') {
      playTone(ctx, now, 160, 0.12, 0.04, 'sawtooth');
    } else {
      [600, 800, 1000, 1200].forEach((freq, i) => {
        playTone(ctx, now + i * 0.04, freq, 0.08, 0.035);
      });
    }
  } catch (_) {
    // Drawing sounds are decorative.
  }
}

function getAudioContext(): AudioContext {
  if (!audioCtx) {
    audioCtx = createAudioContext();
  }
  if (audioCtx.state === 'suspended') {
    audioCtx.resume();
  }
  return audioCtx;
}

function playTone(
  ctx: AudioContext,
  startTime: number,
  frequency: number,
  duration: number,
  gainValue: number,
  type: OscillatorType = 'sine'
): void {
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(frequency, startTime);
  gain.gain.setValueAtTime(gainValue, startTime);
  gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(startTime);
  osc.stop(startTime + duration);
}

function buildWav(samples: Int16Array, sampleRate: number): ArrayBuffer {
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

function writeString(view: DataView, offset: number, string: string): void {
  for (let i = 0; i < string.length; i++) {
    view.setUint8(offset + i, string.charCodeAt(i));
  }
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  let binary = '';
  const bytes = new Uint8Array(buffer);
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}
