import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

function loadModule(name, context, exports) {
  const source = readFileSync(new URL(`../src/${name}.js`, import.meta.url), 'utf8');
  vm.runInNewContext(source.replaceAll('export function', 'function')
    + `\nObject.assign(globalThis, { ${exports.join(',')} });`, context);
  return context;
}

test('completion ads load once per result, stay hidden during play, and fit screen widths', () => {
  for (const [width, zone] of [[1000, 1129382], [700, 1129383], [390, 1129384], [280, 1129384]]) {
    const section = { hidden: true };
    const slot = {
      clientWidth: width, style: {}, children: [],
      closest: () => section,
      append(ad) { this.children.push(ad); },
      replaceChildren() { this.children = []; },
    };
    let loaders = 0;
    const context = loadModule('advertising', {
      window: {},
      document: {
        querySelector: (selector) => selector === '#juicy-ad-slot' ? slot : null,
        createElement: () => ({ style: {}, dataset: {} }),
        head: { append() { loaders++; } },
      },
      ResizeObserver: class { observe() {} disconnect() {} },
    }, ['syncCompletionAd']);
    context.syncCompletionAd(null);
    assert.equal(loaders, 0);
    assert.equal(section.hidden, true);
    context.syncCompletionAd('session:1');
    assert.equal(section.hidden, false);
    assert.equal(context.window.adsbyjuicy[0].adzone, zone);
    assert.ok(parseFloat(slot.style.height) > 0);
    context.syncCompletionAd('session:1');
    assert.equal(context.window.adsbyjuicy.length, 1);
    context.syncCompletionAd(null);
    assert.equal(section.hidden, true);
    assert.equal(slot.children.length, 0);
    context.syncCompletionAd('session:2');
    assert.equal(context.window.adsbyjuicy.length, 2);
    assert.equal(loaders, 1);
  }
});

function dragHarness() {
  const board = {};
  let target = null;
  let preview = null;
  const swaps = [], taps = [];
  function tile(position) {
    const listeners = {};
    let captured = false;
    return {
      dataset: { position: String(position) }, style: {},
      classList: { add() {}, remove() {} },
      addEventListener: (name, fn) => { listeners[name] = fn; },
      emit(name, overrides = {}) {
        listeners[name]?.({ pointerId: 1, isPrimary: true, button: 0,
          clientX: 20, clientY: 30, preventDefault() {}, ...overrides });
      },
      focus() {},
      setPointerCapture() { captured = true; },
      hasPointerCapture() { return captured; },
      releasePointerCapture() { captured = false; },
      closest: () => board,
      getBoundingClientRect: () => ({ left: 10, top: 20, width: 80, height: 100 }),
      cloneNode: () => ({ style: {}, classList: { add() {} },
        removeAttribute() {}, setAttribute() {}, remove() { preview = null; } }),
    };
  }
  const context = loadModule('tile-drag', {
    document: {
      body: { append(node) { preview = node; } },
      elementFromPoint: () => target && { closest: () => target },
    },
  }, ['bindPuzzleTile', 'cancelTileDrag']);
  const first = tile(0), second = tile(1);
  for (const tile of [first, second]) context.bindPuzzleTile(tile, {
    onTap: (position) => taps.push(position),
    onSwap: (...positions) => swaps.push(positions),
    canPlay: () => true,
  });
  return { first, second, swaps, taps, context,
    get preview() { return preview; },
    setTarget(value) { target = value; },
  };
}

test('drag preview is exactly one tile; a second pointer cannot take ownership', () => {
  const h = dragHarness();
  h.first.emit('pointerdown');
  h.second.emit('pointerdown', { pointerId: 2, isPrimary: false });
  h.first.emit('pointermove', { clientX: 60 });
  assert.equal(h.preview.style.width, '80px');
  assert.equal(h.preview.style.height, '100px');
  h.setTarget(h.second);
  h.second.emit('pointerup', { pointerId: 2 });
  assert.equal(h.swaps.length, 0);
  h.first.emit('pointerup', { clientX: 60 });
  assert.deepEqual(h.swaps, [[0, 1]]);
  assert.equal(h.preview, null);
  assert.deepEqual(h.taps, []);
});

test('taps and keyboard activation work; cancelled or outside drops do not swap', () => {
  const h = dragHarness();
  h.first.emit('pointerdown');
  h.first.emit('pointerup');
  h.first.emit('click', { detail: 1 });
  h.second.emit('click', { detail: 0 });
  assert.deepEqual(h.taps, [0, 1]);
  for (const end of ['pointerup', 'pointercancel', 'lostpointercapture']) {
    h.first.emit('pointerdown');
    h.first.emit('pointermove', { clientX: 70 });
    h.first.emit(end);
    assert.equal(h.preview, null);
  }
  assert.deepEqual(h.swaps, []);
});
