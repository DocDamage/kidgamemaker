export type GameIframeResult = {
  ok: boolean;
  status?: string;
  error?: unknown;
};

function gameIframe(doc: Document = document): HTMLIFrameElement | null {
  return doc.querySelector('.game-iframe') as HTMLIFrameElement | null;
}

export function setGlobalGameMuted(muted: boolean, win: Window = window): void {
  (win as Window & { currentGameMuted?: boolean }).currentGameMuted = muted;
}

export function setGlobalGameLevel(levelJson: string, win: Window = window): void {
  (win as Window & { currentGameLevel?: string }).currentGameLevel = levelJson;
}

export function pauseGameIframe(paused: boolean, doc: Document = document): GameIframeResult {
  const iframe = gameIframe(doc);
  if (!iframe?.contentWindow) {
    return { ok: false, error: 'Game iframe is not available.' };
  }

  try {
    const pauseGame = (iframe.contentWindow as Window & { godotPauseGame?: (paused: boolean) => void }).godotPauseGame;
    if (typeof pauseGame !== 'function') {
      return { ok: false, error: 'godotPauseGame is not available.' };
    }
    pauseGame(paused);
    return { ok: true, status: paused ? 'Game Paused ⏸' : 'Game Resumed ▶' };
  } catch (error) {
    return { ok: false, error };
  }
}

export function restartGameIframe(doc: Document = document): GameIframeResult {
  const iframe = gameIframe(doc);
  if (!iframe?.contentWindow) {
    return { ok: false, error: 'Game iframe is not available.' };
  }

  try {
    iframe.src = iframe.src;
    return { ok: true, status: 'Game Restarted 🔄' };
  } catch (error) {
    return { ok: false, error };
  }
}

export function muteGameIframe(muted: boolean, doc: Document = document): GameIframeResult {
  const iframe = gameIframe(doc);
  if (!iframe?.contentWindow) {
    return { ok: false, error: 'Game iframe is not available.' };
  }

  try {
    const muteGame = (iframe.contentWindow as Window & { godotMuteGame?: (muted: boolean) => void }).godotMuteGame;
    if (typeof muteGame !== 'function') {
      return { ok: false, error: 'godotMuteGame is not available.' };
    }
    muteGame(muted);
    return { ok: true };
  } catch (error) {
    return { ok: false, error };
  }
}
