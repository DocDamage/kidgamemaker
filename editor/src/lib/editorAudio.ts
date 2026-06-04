import { createAudioContext } from './webAudio';

export type UiSound = 'pop' | 'squeak' | 'chime';
export type BeatSequence = number[][];

let audioCtx: AudioContext | null = null;

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
  frequency: number,
  duration: number,
  volume: number,
  type: OscillatorType = 'sine'
) {
  const now = ctx.currentTime;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = type;
  osc.frequency.setValueAtTime(frequency, now);
  gain.gain.setValueAtTime(volume, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + duration);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(now);
  osc.stop(now + duration);
}

function playKick(ctx: AudioContext, duration = 0.1) {
  const now = ctx.currentTime;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = 'sine';
  osc.frequency.setValueAtTime(150, now);
  osc.frequency.exponentialRampToValueAtTime(45, now + duration);
  gain.gain.setValueAtTime(0.2, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + duration);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(now);
  osc.stop(now + duration);
}

function playSnare(ctx: AudioContext) {
  const now = ctx.currentTime;
  const bufferSize = ctx.sampleRate * 0.12;
  const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
  const data = buffer.getChannelData(0);
  for (let i = 0; i < bufferSize; i += 1) {
    data[i] = Math.random() * 2 - 1;
  }

  const noise = ctx.createBufferSource();
  noise.buffer = buffer;
  const filter = ctx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.setValueAtTime(1000, now);
  filter.frequency.exponentialRampToValueAtTime(100, now + 0.12);

  const gain = ctx.createGain();
  gain.gain.setValueAtTime(0.12, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);

  noise.connect(filter);
  filter.connect(gain);
  gain.connect(ctx.destination);
  noise.start(now);
  noise.stop(now + 0.12);
}

function playBass(ctx: AudioContext, step: number, type: OscillatorType = 'sawtooth') {
  const notes = [130.81, 155.56, 196.0, 233.08, 261.63, 196.0, 155.56, 130.81];
  const now = ctx.currentTime;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  const filter = ctx.createBiquadFilter();
  osc.type = type;
  osc.frequency.setValueAtTime(notes[step % notes.length], now);
  filter.type = 'lowpass';
  filter.frequency.setValueAtTime(400, now);
  gain.gain.setValueAtTime(0.07, now);
  gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
  osc.connect(filter);
  filter.connect(gain);
  gain.connect(ctx.destination);
  osc.start(now);
  osc.stop(now + 0.15);
}

export function playUiSound(type: UiSound) {
  try {
    const ctx = getAudioContext();
    const now = ctx.currentTime;
    if (type === 'pop') {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(440, now);
      osc.frequency.exponentialRampToValueAtTime(880, now + 0.08);
      gain.gain.setValueAtTime(0.08, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.12);
    } else if (type === 'squeak') {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(800, now);
      osc.frequency.exponentialRampToValueAtTime(300, now + 0.15);
      gain.gain.setValueAtTime(0.06, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.15);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.15);
    } else {
      [600, 900, 1200, 1500].forEach((note, idx) => {
        const time = now + idx * 0.04;
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(note, time);
        gain.gain.setValueAtTime(0.04, time);
        gain.gain.exponentialRampToValueAtTime(0.001, time + 0.08);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(time);
        osc.stop(time + 0.08);
      });
    }
  } catch (_) {
    // Browsers can block AudioContext creation before a user gesture.
  }
}

export function tickBeatPreview(sequence: BeatSequence, currentStep: number, instruments?: string[]): number {
  try {
    const ctx = getAudioContext();
    const insts = instruments || ['sine', 'triangle', 'triangle', 'sawtooth'];
    if (sequence[0]?.[currentStep]) {
      if (insts[0] === 'sine') {
        playKick(ctx);
      } else {
        playTone(ctx, 80, 0.12, 0.25, insts[0] as OscillatorType);
      }
    }
    if (sequence[1]?.[currentStep]) {
      if (insts[1] === 'triangle') {
        playSnare(ctx);
      } else {
        playTone(ctx, 220, 0.1, 0.15, insts[1] as OscillatorType);
      }
    }
    if (sequence[2]?.[currentStep]) {
      playTone(ctx, 1200, 0.05, 0.05, insts[2] as OscillatorType);
    }
    if (sequence[3]?.[currentStep]) {
      playBass(ctx, currentStep, insts[3] as OscillatorType);
    }
  } catch (_) {
    // Preview audio is optional; leave the composer usable if audio is unavailable.
  }

  return (currentStep + 1) % 8;
}

export function playBeatCellPreview(row: number, type: OscillatorType = 'sine') {
  try {
    const ctx = getAudioContext();
    if (row === 0) {
      if (type === 'sine') {
        playKick(ctx, 0.15);
      } else {
        playTone(ctx, 80, 0.15, 0.25, type);
      }
    } else if (row === 1) {
      if (type === 'triangle') {
        playTone(ctx, 350, 0.12, 0.12, 'triangle');
      } else {
        playTone(ctx, 220, 0.12, 0.15, type);
      }
    } else if (row === 2) {
      playTone(ctx, 1200, 0.05, 0.05, type);
    } else {
      playTone(ctx, 130.81, 0.15, 0.07, type);
    }
  } catch (_) {
    // Cell toggles should remain responsive even without audio output.
  }
}
