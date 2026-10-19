import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';

// Run the actual pure puzzle functions without booting the network/UI client.
const source = readFileSync(new URL('../src/main.js', import.meta.url), 'utf8');
const core = source.slice(source.indexOf('function gridSizeForLevel('), source.indexOf('function getImageAspectRatio('));
const context = { BOARD_ASPECT_RATIO: 0.7, state: { arrangement: [] } };
vm.runInNewContext(core + '\nObject.assign(globalThis, { gridSizeForLevel, createSwapShuffle, isSolved, getCoverGeometry, isValidTileArrangement });', context);

test('saved boards require every tile exactly once and within the board range', () => {
  assert.equal(context.isValidTileArrangement([2, 0, 1], 3), true);
  for (const invalid of [null, [0, 1], [0, 0, 2], [-1, 0, 1], [0, 1, 3], [0, 1, 1.5], ['0', 1, 2]]) {
    assert.equal(context.isValidTileArrangement(invalid, 3), false);
  }
});

test('puzzle difficulty changes at levels 26 and 51', () => {
  for (const [level, size] of [[1, 3], [25, 3], [26, 4], [50, 4], [51, 5], [1000, 5]]) {
    assert.equal(context.gridSizeForLevel(level), size);
  }
});

test('shuffling preserves every tile and never starts solved', () => {
  for (const size of [9, 16, 25]) {
    for (let repeat = 0; repeat < 30; repeat++) {
      const tiles = Array.from(context.createSwapShuffle(size, size * 8));
      assert.deepEqual([...tiles].sort((a, b) => a - b), Array.from({ length: size }, (_, i) => i));
      assert.ok(tiles.some((id, position) => id !== position));
    }
  }
});

test('solved detection handles an empty, mixed, and completed board', () => {
  for (const [tiles, solved] of [[[], false], [[0, 2, 1], false], [[0, 1, 2], true]]) {
    context.state.arrangement = tiles;
    assert.equal(context.isSolved(), solved);
  }
});

test('image cropping covers the board for portrait and landscape images', () => {
  for (const ratio of [0.35, 0.7, 1, 2]) {
    const crop = context.getCoverGeometry(ratio, 3, 3);
    assert.ok(crop.widthPercent >= 300);
    assert.ok(crop.heightPercent >= 300);
    assert.ok(crop.leftTileUnits <= 0);
    assert.ok(crop.topTileUnits <= 0);
  }
});
