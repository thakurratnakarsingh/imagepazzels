import './styles.css';

const COMPILED_API_BASE_URL = typeof __API_BASE_URL__ !== 'undefined' ? __API_BASE_URL__ : 'https://api.actressgamingserver.online/api/v1';
const API_BASE_URL = (import.meta.env.DEV ? '/api/v1' : COMPILED_API_BASE_URL).replace(/\/$/, '');
const APK_DOWNLOAD_URL = typeof __APK_DOWNLOAD_URL__ !== 'undefined' ? __APK_DOWNLOAD_URL__ : '/downloads/actress-puzzle-game.apk';
const PLAY_STORE_URL = typeof __PLAY_STORE_URL__ !== 'undefined' ? __PLAY_STORE_URL__ : '';
const IOS_APP_URL = typeof __IOS_APP_URL__ !== 'undefined' ? __IOS_APP_URL__ : '';
const API_ASSET_ORIGIN = COMPILED_API_BASE_URL.replace(/\/api\/v1\/?$/, '').replace(/\/$/, '');
const ASSET_BASE_URL = import.meta.env.DEV ? '' : API_ASSET_ORIGIN;
const BOARD_ASPECT_RATIO = 0.70;
const MAX_SELECTED_MODELS = 10;
const FREE_HINTS_PER_LEVEL = 3;
const REWARDED_HINT_AD_SECONDS = 5;
const STORAGE_KEYS = {
  deviceId: 'apg_web_device_id',
  token: 'apg_web_access_token',
  refreshToken: 'apg_web_refresh_token',
  selectedIds: 'apg_web_selected_model_ids',
  currentLevel: 'apg_web_current_level',
  androidPromptDismissed: 'apg_android_prompt_dismissed',
};

const app = document.querySelector('#app');
const state = {
  auth: null,
  actresses: [],
  selectedIds: loadSelectedIds(),
  levelNumber: Number(localStorage.getItem(STORAGE_KEYS.currentLevel)) || 1,
  levelData: null,
  arrangement: [],
  imageAspectRatio: BOARD_ASPECT_RATIO,
  selectedPosition: null,
  dragSourcePosition: null,
  moveCount: 0,
  elapsedBaseSeconds: 0,
  startedAt: null,
  timerId: null,
  hintsRemaining: FREE_HINTS_PER_LEVEL,
  showHintImage: false,
  showHintAd: false,
  hintAdSeconds: 0,
  hintAdTimerId: null,
  completed: false,
  completion: null,
  loading: true,
  loadingGame: false,
  error: '',
  notice: '',
  demoMode: false,
};

init();

async function init() {
  render();
  showAndroidPromptIfNeeded();

  try {
    await ensureGuestSession();
    await loadActresses();
  } catch (error) {
    state.demoMode = true;
    state.error = 'The game server is not reachable, so the web client is showing demo mode.';
    state.actresses = [{
      id: 1,
      name: 'Demo Puzzle',
      thumbnail_image: '/demo/puzzle-demo.svg',
      is_active: true,
    }];
    state.selectedIds = [1];
  } finally {
    state.loading = false;
    render();
  }
}

async function ensureGuestSession(force = false) {
  const cachedToken = localStorage.getItem(STORAGE_KEYS.token);
  if (cachedToken && !force) {
    state.auth = {
      accessToken: cachedToken,
      refreshToken: localStorage.getItem(STORAGE_KEYS.refreshToken) || '',
    };
    return state.auth;
  }

  const deviceId = getDeviceId();
  const response = await apiFetch('/mobile/auth/guest', {
    method: 'POST',
    body: { deviceId },
    skipAuth: true,
  });
  const auth = response.data || {};
  state.auth = {
    accessToken: auth.accessToken,
    refreshToken: auth.refreshToken,
    user: auth.user,
  };
  if (auth.accessToken) localStorage.setItem(STORAGE_KEYS.token, auth.accessToken);
  if (auth.refreshToken) localStorage.setItem(STORAGE_KEYS.refreshToken, auth.refreshToken);
  if (auth.user?.current_level && !localStorage.getItem(STORAGE_KEYS.currentLevel)) {
    state.levelNumber = auth.user.current_level;
  }
  return state.auth;
}

async function loadActresses() {
  const response = await apiFetch('/mobile/actresses', { skipAuth: true });
  state.actresses = (response.data || []).filter((actress) => parseBoolean(actress.is_active));

  const activeIds = new Set(state.actresses.map((actress) => actress.id));
  state.selectedIds = state.selectedIds.filter((id) => activeIds.has(id)).slice(0, MAX_SELECTED_MODELS);
  if (!state.selectedIds.length && state.actresses.length) {
    state.selectedIds = state.actresses.slice(0, Math.min(3, MAX_SELECTED_MODELS)).map((actress) => actress.id);
  }
  persistSelectedIds();
}

async function startGame() {
  if (!state.selectedIds.length) {
    state.notice = 'Select at least one model to start the puzzle.';
    render();
    return;
  }

  state.loadingGame = true;
  state.error = '';
  state.notice = '';
  state.completed = false;
  state.completion = null;
  state.selectedPosition = null;
  state.hintsRemaining = FREE_HINTS_PER_LEVEL;
  state.showHintImage = false;
  state.showHintAd = false;
  state.hintAdSeconds = 0;
  stopHintAd();
  stopTimer();
  render();

  try {
    let data;
    if (state.demoMode) {
      data = createDemoLevelData();
    } else {
      await ensureGuestSession();
      data = await apiFetch('/mobile/game/level-image', {
        method: 'POST',
        body: {
          level: state.levelNumber,
          actress_ids: state.selectedIds,
        },
      });
    }
    const imageUrl = normalizeAssetUrl(data.image?.image_url || '/demo/puzzle-demo.svg');
    state.imageAspectRatio = await getImageAspectRatio(imageUrl);
    const rows = Number(data.rows) || gridSizeForLevel(state.levelNumber);
    const columns = Number(data.columns) || rows;
    const totalTiles = rows * columns;
    const saved = data.saved_progress;
    const savedArrangement = Array.isArray(saved?.tile_arrangement)
      && saved.tile_arrangement.length === totalTiles
      && new Set(saved.tile_arrangement).size === totalTiles
      ? saved.tile_arrangement
      : null;

    state.levelData = {
      level: Number(data.level) || state.levelNumber,
      level_id: data.level_id || state.levelNumber,
      rows,
      columns,
      shuffle_moves: Number(data.shuffle_moves) || totalTiles * 8,
      reward_points: Number(data.reward_points) || 0,
      session_id: data.session_id || `demo-${Date.now()}`,
      image: {
        id: data.image?.id || 1,
        image_url: imageUrl,
      },
    };
    state.arrangement = savedArrangement || createSwapShuffle(totalTiles, state.levelData.shuffle_moves);
    state.moveCount = Number(saved?.move_count) || 0;
    state.elapsedBaseSeconds = Number(saved?.elapsed_time_seconds) || 0;
    state.completed = isSolved();
    startTimer();
  } catch (error) {
    if (!state.demoMode && /token|expired|forbidden|unauthorized/i.test(error.message)) {
      localStorage.removeItem(STORAGE_KEYS.token);
      await ensureGuestSession(true);
      return startGame();
    }
    state.error = error.message || 'Could not start this level.';
  } finally {
    state.loadingGame = false;
    render();
  }
}

function render() {
  app.innerHTML = `
    <main class="shell">
      <header class="topbar">
        <a class="brand" href="#" data-action="home" aria-label="Actress Puzzle Game home">
          <span class="brand-mark" aria-hidden="true">AP</span>
          <span>
            <strong>Actress Puzzle Game</strong>
            <small>play in browser or install the app</small>
          </span>
        </a>
        <nav class="nav-actions" aria-label="App links">
          <a class="icon-button" href="${APK_DOWNLOAD_URL}" download title="Download Android APK" aria-label="Download Android APK">APK</a>
          ${PLAY_STORE_URL ? `<a class="ghost-button" href="${PLAY_STORE_URL}" target="_blank" rel="noreferrer">Play Store</a>` : ''}
          ${IOS_APP_URL ? `<a class="ghost-button" href="${IOS_APP_URL}" target="_blank" rel="noreferrer">iOS</a>` : ''}
        </nav>
      </header>

      <section class="game-layout" aria-live="polite">
        <aside class="panel setup-panel">
          <div class="section-heading">
            <p class="eyebrow">Model collection</p>
            <h1>Choose, shuffle, solve.</h1>
          </div>
          ${renderModelPicker()}
          ${renderDownloads()}
        </aside>

        <section class="play-panel">
          ${renderStatus()}
          ${renderGameArea()}
        </section>
      </section>
    </main>
    <div id="modal-root">${renderActiveModal()}</div>
  `;
  bindEvents();
  if (state.levelData && !state.completed && !state.loadingGame) startTimer();
}

function renderModelPicker() {
  if (state.loading) {
    return `
      <div class="loading-block">
        <span class="loader" aria-hidden="true"></span>
        <span>Loading models...</span>
      </div>
    `;
  }

  const cards = state.actresses.map((actress) => {
    const isSelected = state.selectedIds.includes(actress.id);
    const thumb = thumbnailUrl(actress.thumbnail_image);
    return `
      <button class="model-row ${isSelected ? 'is-selected' : ''}" data-action="toggle-model" data-id="${actress.id}" type="button">
        <span class="avatar">
          <img src="${thumb}" alt="" loading="lazy" />
        </span>
        <span class="model-copy">
          <strong>${escapeHtml(actress.name)}</strong>
          <small>${isSelected ? 'Added to game' : 'Tap to select'}</small>
        </span>
        <span class="select-indicator" aria-hidden="true">${isSelected ? 'OK' : '+'}</span>
      </button>
    `;
  }).join('');

  return `
    <div class="selection-summary">
      <span>${state.selectedIds.length}/${MAX_SELECTED_MODELS} selected</span>
      <button class="text-button" data-action="clear-models" type="button">Clear</button>
    </div>
    <div class="model-list">
      ${cards || '<p class="empty-copy">No models are available yet.</p>'}
    </div>
    <div class="level-control" aria-label="Level selector">
      <button class="square-button" data-action="level-down" type="button" aria-label="Previous level">-</button>
      <label>
        <span>Level</span>
        <input type="number" min="1" max="1000" value="${state.levelNumber}" data-action="level-input" />
      </label>
      <button class="square-button" data-action="level-up" type="button" aria-label="Next level">+</button>
    </div>
    <button class="primary-button" data-action="start-game" type="button" ${state.selectedIds.length ? '' : 'disabled'}>
      ${state.levelData ? 'Load level' : 'Start playing'}
    </button>
  `;
}

function renderDownloads() {
  return `
    <div class="downloads-panel">
      <p class="eyebrow">App downloads</p>
      <a class="download-row" href="${APK_DOWNLOAD_URL}" download>
        <span>
          <strong>Android APK</strong>
          <small>Direct install file</small>
        </span>
        <b>Download</b>
      </a>
      <a class="download-row ${PLAY_STORE_URL ? '' : 'is-disabled'}" href="${PLAY_STORE_URL || '#'}" ${PLAY_STORE_URL ? 'target="_blank" rel="noreferrer"' : 'aria-disabled="true"'}>
        <span>
          <strong>Google Play</strong>
          <small>${PLAY_STORE_URL ? 'Store listing' : 'Place your store link here'}</small>
        </span>
        <b>${PLAY_STORE_URL ? 'Open' : 'Slot'}</b>
      </a>
      <a class="download-row ${IOS_APP_URL ? '' : 'is-disabled'}" href="${IOS_APP_URL || '#'}" ${IOS_APP_URL ? 'target="_blank" rel="noreferrer"' : 'aria-disabled="true"'}>
        <span>
          <strong>iOS app</strong>
          <small>${IOS_APP_URL ? 'App Store listing' : 'Place your iOS link here'}</small>
        </span>
        <b>${IOS_APP_URL ? 'Open' : 'Slot'}</b>
      </a>
    </div>
  `;
}

function renderStatus() {
  const rows = state.levelData?.rows || gridSizeForLevel(state.levelNumber);
  const points = state.levelData?.reward_points || 0;
  const elapsed = formatTime(currentElapsedSeconds());
  return `
    <div class="status-strip">
      <div>
        <small>Level</small>
        <strong>${state.levelNumber}</strong>
      </div>
      <div>
        <small>Grid</small>
        <strong>${rows} x ${rows}</strong>
      </div>
      <div>
        <small>Moves</small>
        <strong>${state.moveCount}</strong>
      </div>
      <div>
        <small>Time</small>
        <strong data-role="timer">${elapsed}</strong>
      </div>
      <div>
        <small>Reward</small>
        <strong>${points}</strong>
      </div>
    </div>
  `;
}

function renderGameArea() {
  const message = state.error
    ? `<div class="message error">${escapeHtml(state.error)}</div>`
    : state.notice
      ? `<div class="message notice">${escapeHtml(state.notice)}</div>`
      : '';
  if (state.loadingGame) {
    return `
      ${message}
      <div class="game-placeholder">
        <span class="loader large" aria-hidden="true"></span>
        <h2>Preparing the puzzle</h2>
        <p>Finding an image and restoring your saved progress.</p>
      </div>
    `;
  }
  if (!state.levelData) {
    return `${message}${renderStartState()}`;
  }

  return `
    ${message}
    <div class="board-wrap">
      <div class="board-toolbar">
        <div>
          <h2>Level ${state.levelNumber}</h2>
          <p>Tap two tiles, or drag a tile onto another tile, to swap them.</p>
        </div>
        <div class="toolbar-actions">
          <button class="ghost-button hint-button" data-action="hint" type="button">
            ${state.hintsRemaining > 0 ? `Hint (${state.hintsRemaining})` : 'Hint ad'}
          </button>
          <button class="ghost-button" data-action="reshuffle" type="button">Shuffle</button>
          <button class="ghost-button" data-action="reset" type="button">Reset</button>
        </div>
      </div>
      ${renderBoard()}
      ${state.completed ? renderCompletion() : ''}
    </div>
  `;
}

function renderStartState() {
  return `
    <div class="game-placeholder">
      <img src="/demo/puzzle-demo.svg" alt="" />
      <h2>Play the puzzle on the web</h2>
      <p>Select up to ${MAX_SELECTED_MODELS} models, pick a level, and start solving. Android users will also see the APK download prompt.</p>
      <button class="primary-button compact" data-action="start-game" type="button" ${state.selectedIds.length ? '' : 'disabled'}>Start level ${state.levelNumber}</button>
    </div>
  `;
}

function renderBoard() {
  const { rows, columns, image } = state.levelData;
  const cover = getCoverGeometry(state.imageAspectRatio, rows, columns);
  const tiles = state.arrangement.map((tileId, position) => {
    const sourceRow = Math.floor(tileId / columns);
    const sourceColumn = tileId % columns;
    const isSelected = state.selectedPosition === position;
    const style = [
      `--img-width:${cover.widthPercent}%`,
      `--img-height:${cover.heightPercent}%`,
      `--img-left:${(cover.leftTileUnits - sourceColumn) * 100}%`,
      `--img-top:${(cover.topTileUnits - sourceRow) * 100}%`,
    ].join(';');
    return `
      <button
        class="tile ${isSelected ? 'is-active' : ''}"
        data-action="tile"
        data-position="${position}"
        draggable="true"
        style="${style}"
        type="button"
        aria-label="Tile ${tileId + 1}, position ${position + 1}"
      >
        <img src="${image.image_url}" alt="" draggable="false" />
      </button>
    `;
  }).join('');

  return `
    <div class="board" style="--rows:${rows};--columns:${columns}" role="grid" aria-label="Puzzle board">
      ${tiles}
    </div>
  `;
}

function renderCompletion() {
  const stars = state.completion?.stars || 1;
  const reward = state.completion?.rewardPointsEarned ?? state.levelData.reward_points;
  return `
    <div class="completion-panel">
      <div>
        <p class="eyebrow">Level complete</p>
        <h2>${stars} star${stars === 1 ? '' : 's'} earned</h2>
        <p>${reward} reward points, ${state.moveCount} moves, ${formatTime(currentElapsedSeconds())}.</p>
      </div>
      <button class="primary-button compact" data-action="next-level" type="button">Next level</button>
    </div>
  `;
}

function renderActiveModal() {
  if (state.showHintImage && state.levelData?.image?.image_url) {
    return `
      <div class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="hint-title">
        <div class="modal wide">
          <p class="eyebrow">Puzzle hint</p>
          <h2 id="hint-title">Original image</h2>
          <img class="hint-image" src="${state.levelData.image.image_url}" alt="Original puzzle image" />
          <p>Use this preview to remember where the tiles belong.</p>
          <div class="modal-actions">
            <button class="primary-button compact" data-action="close-hint" type="button">Back to puzzle</button>
          </div>
        </div>
      </div>
    `;
  }

  if (state.showHintAd) {
    return `
      <div class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="hint-ad-title">
        <div class="modal">
          <p class="eyebrow">Rewarded hint</p>
          <h2 id="hint-ad-title">Watch ad for hint</h2>
          <div class="ad-countdown" aria-live="polite">
            <span class="loader large" aria-hidden="true"></span>
            <strong>${state.hintAdSeconds}s</strong>
          </div>
          <p>Your free hints are finished. The original image will open after the ad.</p>
          <div class="modal-actions">
            <button class="ghost-button dark" data-action="cancel-hint-ad" type="button">Cancel</button>
          </div>
        </div>
      </div>
    `;
  }

  return '';
}

function bindEvents() {
  app.querySelectorAll('[data-action]').forEach((element) => {
    const action = element.dataset.action;
    if (action === 'toggle-model') element.addEventListener('click', () => toggleModel(Number(element.dataset.id)));
    if (action === 'clear-models') element.addEventListener('click', clearModels);
    if (action === 'start-game') element.addEventListener('click', startGame);
    if (action === 'level-down') element.addEventListener('click', () => setLevel(state.levelNumber - 1));
    if (action === 'level-up') element.addEventListener('click', () => setLevel(state.levelNumber + 1));
    if (action === 'level-input') element.addEventListener('change', (event) => setLevel(Number(event.target.value)));
    if (action === 'tile') bindTileEvents(element);
    if (action === 'hint') element.addEventListener('click', requestHint);
    if (action === 'close-hint') element.addEventListener('click', () => {
      state.showHintImage = false;
      render();
    });
    if (action === 'cancel-hint-ad') element.addEventListener('click', cancelHintAd);
    if (action === 'reshuffle') element.addEventListener('click', reshuffle);
    if (action === 'reset') element.addEventListener('click', resetPuzzle);
    if (action === 'next-level') element.addEventListener('click', nextLevel);
    if (action === 'home') element.addEventListener('click', (event) => event.preventDefault());
  });
}

function requestHint() {
  if (!state.levelData || state.completed || state.loadingGame) return;
  if (state.hintsRemaining > 0) {
    state.hintsRemaining -= 1;
    state.showHintImage = true;
    render();
    return;
  }
  startHintAd();
}

function startHintAd() {
  stopHintAd();
  state.showHintAd = true;
  state.showHintImage = false;
  state.hintAdSeconds = REWARDED_HINT_AD_SECONDS;
  render();
  state.hintAdTimerId = window.setInterval(() => {
    state.hintAdSeconds -= 1;
    if (state.hintAdSeconds <= 0) {
      finishHintAd();
    } else {
      render();
    }
  }, 1000);
}

function finishHintAd() {
  stopHintAd();
  state.showHintAd = false;
  state.showHintImage = true;
  state.hintAdSeconds = 0;
  render();
}

function cancelHintAd() {
  stopHintAd();
  state.showHintAd = false;
  state.hintAdSeconds = 0;
  render();
}

function stopHintAd() {
  if (state.hintAdTimerId) {
    window.clearInterval(state.hintAdTimerId);
    state.hintAdTimerId = null;
  }
}

function bindTileEvents(tile) {
  tile.addEventListener('click', () => handleTileTap(Number(tile.dataset.position)));
  tile.addEventListener('dragstart', (event) => {
    state.dragSourcePosition = Number(tile.dataset.position);
    event.dataTransfer.effectAllowed = 'move';
  });
  tile.addEventListener('dragover', (event) => {
    event.preventDefault();
    event.dataTransfer.dropEffect = 'move';
  });
  tile.addEventListener('drop', (event) => {
    event.preventDefault();
    const targetPosition = Number(tile.dataset.position);
    if (state.dragSourcePosition !== null) {
      swapTiles(state.dragSourcePosition, targetPosition);
    }
    state.dragSourcePosition = null;
  });
  tile.addEventListener('dragend', () => {
    state.dragSourcePosition = null;
  });
}

function toggleModel(id) {
  if (state.selectedIds.includes(id)) {
    state.selectedIds = state.selectedIds.filter((selectedId) => selectedId !== id);
  } else if (state.selectedIds.length < MAX_SELECTED_MODELS) {
    state.selectedIds = [...state.selectedIds, id];
  } else {
    state.notice = `You can select a maximum of ${MAX_SELECTED_MODELS} models.`;
  }
  persistSelectedIds();
  render();
}

function clearModels() {
  state.selectedIds = [];
  state.notice = '';
  persistSelectedIds();
  render();
}

function setLevel(levelNumber) {
  state.levelNumber = Math.min(1000, Math.max(1, Number.isFinite(levelNumber) ? Math.round(levelNumber) : 1));
  localStorage.setItem(STORAGE_KEYS.currentLevel, String(state.levelNumber));
  state.levelData = null;
  state.completed = false;
  state.completion = null;
  state.showHintImage = false;
  state.showHintAd = false;
  state.hintsRemaining = FREE_HINTS_PER_LEVEL;
  stopHintAd();
  stopTimer();
  render();
}

function handleTileTap(position) {
  if (state.completed) return;
  if (state.selectedPosition === null) {
    state.selectedPosition = position;
    render();
    return;
  }
  if (state.selectedPosition === position) {
    state.selectedPosition = null;
    render();
    return;
  }
  swapTiles(state.selectedPosition, position);
  state.selectedPosition = null;
}

async function swapTiles(sourcePosition, targetPosition) {
  if (state.completed || sourcePosition === targetPosition) return;
  if (!state.arrangement[sourcePosition] && state.arrangement[sourcePosition] !== 0) return;
  if (!state.arrangement[targetPosition] && state.arrangement[targetPosition] !== 0) return;

  const next = [...state.arrangement];
  [next[sourcePosition], next[targetPosition]] = [next[targetPosition], next[sourcePosition]];
  state.arrangement = next;
  state.moveCount += 1;
  state.completed = isSolved();
  render();

  if (state.completed) {
    stopTimer();
    await completeLevel();
  } else {
    saveProgressDebounced();
  }
}

function reshuffle() {
  if (!state.levelData) return;
  const totalTiles = state.levelData.rows * state.levelData.columns;
  state.arrangement = createSwapShuffle(totalTiles, state.levelData.shuffle_moves);
  state.moveCount = 0;
  state.elapsedBaseSeconds = 0;
  state.completed = false;
  state.completion = null;
  state.selectedPosition = null;
  startTimer(true);
  saveProgressDebounced();
  render();
}

function resetPuzzle() {
  if (!state.levelData) return;
  const totalTiles = state.levelData.rows * state.levelData.columns;
  state.arrangement = Array.from({ length: totalTiles }, (_, index) => index);
  state.completed = true;
  state.completion = { stars: 3, rewardPointsEarned: 0 };
  stopTimer();
  render();
}

async function nextLevel() {
  setLevel(state.levelNumber + 1);
  await startGame();
}

const saveProgressDebounced = debounce(saveProgress, 450);

async function saveProgress() {
  if (state.demoMode || !state.levelData || state.completed) return;
  const totalTiles = state.arrangement.length;
  const emptyTileIndex = state.arrangement.indexOf(totalTiles - 1);
  try {
    await apiFetch('/mobile/game/progress', {
      method: 'POST',
      body: {
        levelId: state.levelData.level_id,
        sessionId: state.levelData.session_id,
        tileArrangement: state.arrangement,
        emptyTileIndex,
        moveCount: state.moveCount,
        elapsedTimeSeconds: currentElapsedSeconds(),
      },
    });
  } catch (error) {
    state.notice = error.message || 'Progress could not be saved.';
  }
}

async function completeLevel() {
  if (!state.levelData) return;
  if (state.demoMode) {
    state.completion = { stars: 3, rewardPointsEarned: state.levelData.reward_points };
    render();
    return;
  }
  try {
    const response = await apiFetch('/mobile/game/complete', {
      method: 'POST',
      body: {
        levelId: state.levelData.level_id,
        imageId: state.levelData.image.id,
        moves: state.moveCount,
        timeTakenSeconds: currentElapsedSeconds(),
        puzzleSessionId: state.levelData.session_id,
      },
    });
    state.completion = response.data || { stars: 1, rewardPointsEarned: 0 };
    localStorage.setItem(STORAGE_KEYS.currentLevel, String(Math.max(state.levelNumber + 1, state.levelNumber)));
  } catch (error) {
    state.notice = error.message || 'The puzzle is solved, but completion could not be sent to the server.';
  } finally {
    render();
  }
}

async function apiFetch(path, options = {}) {
  const headers = {
    Accept: 'application/json',
    ...(options.body ? { 'Content-Type': 'application/json' } : {}),
  };
  if (!options.skipAuth) {
    const token = state.auth?.accessToken || localStorage.getItem(STORAGE_KEYS.token);
    if (token) headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: options.method || 'GET',
    headers,
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok || data.success === false) {
    throw new Error(data.message || `Request failed (${response.status})`);
  }
  return data;
}

function getDeviceId() {
  let deviceId = localStorage.getItem(STORAGE_KEYS.deviceId);
  if (!deviceId) {
    deviceId = crypto.randomUUID ? crypto.randomUUID() : `web-${Date.now()}-${Math.random().toString(16).slice(2)}`;
    localStorage.setItem(STORAGE_KEYS.deviceId, deviceId);
  }
  return deviceId;
}

function loadSelectedIds() {
  try {
    const parsed = JSON.parse(localStorage.getItem(STORAGE_KEYS.selectedIds) || '[]');
    return Array.isArray(parsed) ? parsed.filter(Number.isInteger).slice(0, MAX_SELECTED_MODELS) : [];
  } catch {
    return [];
  }
}

function persistSelectedIds() {
  localStorage.setItem(STORAGE_KEYS.selectedIds, JSON.stringify(state.selectedIds.slice(0, MAX_SELECTED_MODELS)));
}

function thumbnailUrl(thumbnail) {
  if (!thumbnail) return '/demo/puzzle-demo.svg';
  if (thumbnail.startsWith('/demo/')) return thumbnail;
  return normalizeAssetUrl(thumbnail.includes('/') ? thumbnail : `actresses/thumbnails/${thumbnail}`);
}

function normalizeAssetUrl(value) {
  if (!value) return '';
  if (value.startsWith('/demo/')) return value;

  try {
    const parsed = new URL(value);
    if (parsed.pathname.startsWith('/uploads/')) {
      return `${ASSET_BASE_URL}${parsed.pathname}${parsed.search}`;
    }
    return value;
  } catch {
    const normalized = value.replace(/^\/+/, '');
    if (normalized.startsWith('uploads/')) {
      return `${ASSET_BASE_URL}/${normalized}`;
    }
    return `${ASSET_BASE_URL}/uploads/${normalized}`;
  }
}

function parseBoolean(value) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') return value !== 0;
  if (typeof value === 'string') return value === '1' || value.toLowerCase() === 'true';
  return true;
}

function gridSizeForLevel(levelNumber) {
  if (levelNumber <= 25) return 3;
  if (levelNumber <= 50) return 4;
  return 5;
}

function createSwapShuffle(totalTiles, moves) {
  const arrangement = Array.from({ length: totalTiles }, (_, index) => index);
  const moveCount = Math.max(moves || totalTiles * 8, totalTiles * 2);
  for (let index = 0; index < moveCount; index += 1) {
    const first = randomIndex(totalTiles);
    let second = randomIndex(totalTiles);
    while (second === first) second = randomIndex(totalTiles);
    [arrangement[first], arrangement[second]] = [arrangement[second], arrangement[first]];
  }
  if (arrangement.every((tileId, index) => tileId === index)) {
    [arrangement[0], arrangement[1]] = [arrangement[1], arrangement[0]];
  }
  return arrangement;
}

function randomIndex(max) {
  return Math.floor(Math.random() * max);
}

function isSolved() {
  return state.arrangement.length > 0 && state.arrangement.every((tileId, index) => tileId === index);
}

function getCoverGeometry(imageAspectRatio, rows, columns) {
  let imageWidthRatio = 1;
  let imageHeightRatio = 1;
  let leftBoardUnits = 0;
  let topBoardUnits = 0;

  if (imageAspectRatio > BOARD_ASPECT_RATIO) {
    imageWidthRatio = imageAspectRatio / BOARD_ASPECT_RATIO;
    leftBoardUnits = -(imageWidthRatio - 1) / 2;
  } else {
    imageHeightRatio = BOARD_ASPECT_RATIO / imageAspectRatio;
    topBoardUnits = -(imageHeightRatio - 1) / 2;
  }

  return {
    widthPercent: imageWidthRatio * columns * 100,
    heightPercent: imageHeightRatio * rows * 100,
    leftTileUnits: leftBoardUnits * columns,
    topTileUnits: topBoardUnits * rows,
  };
}

function getImageAspectRatio(url) {
  return new Promise((resolve) => {
    const image = new Image();
    image.crossOrigin = 'anonymous';
    image.onload = () => resolve(image.naturalWidth && image.naturalHeight
      ? image.naturalWidth / image.naturalHeight
      : BOARD_ASPECT_RATIO);
    image.onerror = () => resolve(BOARD_ASPECT_RATIO);
    image.src = url;
  });
}

function createDemoLevelData() {
  const size = gridSizeForLevel(state.levelNumber);
  return {
    level: state.levelNumber,
    level_id: state.levelNumber,
    rows: size,
    columns: size,
    shuffle_moves: size * size * 8,
    reward_points: 50,
    session_id: `demo-${Date.now()}`,
    saved_progress: null,
    image: {
      id: 1,
      actress_id: 1,
      image_url: '/demo/puzzle-demo.svg',
      width: 700,
      height: 1000,
    },
  };
}

function startTimer(reset = false) {
  if (reset) {
    state.elapsedBaseSeconds = 0;
  }
  if (!state.startedAt || reset) state.startedAt = Date.now();
  if (state.timerId) return;
  state.timerId = window.setInterval(() => {
    const timer = app.querySelector('[data-role="timer"]');
    if (timer) timer.textContent = formatTime(currentElapsedSeconds());
  }, 1000);
}

function stopTimer() {
  if (state.timerId) {
    window.clearInterval(state.timerId);
    state.timerId = null;
  }
  state.elapsedBaseSeconds = currentElapsedSeconds();
  state.startedAt = null;
}

function currentElapsedSeconds() {
  if (!state.startedAt) return state.elapsedBaseSeconds;
  return state.elapsedBaseSeconds + Math.floor((Date.now() - state.startedAt) / 1000);
}

function formatTime(totalSeconds) {
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}

function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    window.clearTimeout(timeoutId);
    timeoutId = window.setTimeout(() => fn(...args), delay);
  };
}

function showAndroidPromptIfNeeded() {
  const isAndroid = /Android/i.test(navigator.userAgent);
  if (!isAndroid || localStorage.getItem(STORAGE_KEYS.androidPromptDismissed) === 'true') return;

  window.setTimeout(() => {
    const modalRoot = document.querySelector('#modal-root');
    if (!modalRoot) return;
    modalRoot.innerHTML = `
      <div class="modal-backdrop" role="dialog" aria-modal="true" aria-labelledby="android-title">
        <div class="modal">
          <p class="eyebrow">Android app available</p>
          <h2 id="android-title">Download the APK for a full-screen game.</h2>
          <p>The browser version is ready to play, and the Android app is available as a direct APK download.</p>
          <div class="modal-actions">
            <a class="primary-button compact" href="${APK_DOWNLOAD_URL}" download>Download APK</a>
            <button class="ghost-button dark" data-modal-close type="button">Play in browser</button>
          </div>
          <button class="text-button modal-dismiss" data-modal-dismiss type="button">Do not show again</button>
        </div>
      </div>
    `;
    modalRoot.querySelector('[data-modal-close]')?.addEventListener('click', () => {
      modalRoot.innerHTML = '';
    });
    modalRoot.querySelector('[data-modal-dismiss]')?.addEventListener('click', () => {
      localStorage.setItem(STORAGE_KEYS.androidPromptDismissed, 'true');
      modalRoot.innerHTML = '';
    });
  }, 650);
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
