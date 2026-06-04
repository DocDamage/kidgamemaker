type BrowserAudioWindow = Window & {
  AudioContext?: typeof AudioContext;
  webkitAudioContext?: typeof AudioContext;
};

export function createAudioContext(win: Window = window): AudioContext {
  const audioWindow = win as BrowserAudioWindow;
  const AudioContextCtor = audioWindow.AudioContext ?? audioWindow.webkitAudioContext;
  if (!AudioContextCtor) {
    throw new Error('Web Audio is not available in this browser.');
  }
  return new AudioContextCtor();
}
