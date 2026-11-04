import test from 'node:test';
import assert from 'node:assert/strict';
import {
  canPour,
  executePour,
  isLevelComplete,
  hasValidMoves,
  findBestHintMove,
  calculateStars,
  formatTime,
  cloneTubes,
} from '../src/logic/gameEngine.ts';
import { getLevelData, buildInitialTubes } from '../src/logic/levels.ts';
import { Tube } from '../src/types/game.ts';

test('canPour correctly validates allowed and forbidden moves (including sealed tubes)', () => {
  const tubeFullCoral: Tube = {
    id: '1',
    colors: ['coral', 'coral', 'coral', 'coral'],
    maxCapacity: 4,
  };
  const tubeMixedTopCoral: Tube = {
    id: '1b',
    colors: ['mint', 'coral', 'coral'],
    maxCapacity: 4,
  };
  const tubeWithMint: Tube = { id: '2', colors: ['mint'], maxCapacity: 4 };
  const tubeWithCoralSpace: Tube = {
    id: '3',
    colors: ['coral', 'coral'],
    maxCapacity: 4,
  };
  const tubeEmpty: Tube = { id: '4', colors: [], maxCapacity: 4 };

  // Can pour into empty tube
  assert.equal(canPour(tubeWithMint, tubeEmpty), true);

  // Can pour mixed tube with top coral into matching coral tube with space
  assert.equal(canPour(tubeMixedTopCoral, tubeWithCoralSpace), true);

  // Cannot pour FROM an already completed (4/4) sealed tube
  assert.equal(canPour(tubeFullCoral, tubeEmpty), false);

  // Cannot pour into full tube
  assert.equal(canPour(tubeWithMint, tubeFullCoral), false);

  // Cannot pour mismatched color
  assert.equal(canPour(tubeWithMint, tubeWithCoralSpace), false);

  // Cannot pour from empty tube
  assert.equal(canPour(tubeEmpty, tubeWithCoralSpace), false);

  // Cannot pour into itself
  assert.equal(canPour(tubeWithMint, tubeWithMint), false);
});

test('executePour transfers consecutive matching segments up to capacity', () => {
  const tubes: Tube[] = [
    { id: '1', colors: ['yellow', 'coral', 'coral'], maxCapacity: 4 },
    { id: '2', colors: ['coral'], maxCapacity: 4 },
  ];

  const result = executePour(tubes, 0, 1);
  assert.notEqual(result, null);
  assert.equal(result!.pouredCount, 2);
  assert.equal(result!.colorPoured, 'coral');
  assert.deepEqual(result!.newTubes[0].colors, ['yellow']);
  assert.deepEqual(result!.newTubes[1].colors, ['coral', 'coral', 'coral']);
});

test('isLevelComplete detects completed and incomplete levels', () => {
  const incompleteTubes: Tube[] = [
    { id: '1', colors: ['coral', 'mint', 'coral', 'mint'], maxCapacity: 4 },
    { id: '2', colors: ['mint', 'coral', 'mint', 'coral'], maxCapacity: 4 },
    { id: '3', colors: [], maxCapacity: 4 },
  ];
  assert.equal(isLevelComplete(incompleteTubes), false);

  const completedTubes: Tube[] = [
    { id: '1', colors: ['coral', 'coral', 'coral', 'coral'], maxCapacity: 4 },
    { id: '2', colors: ['mint', 'mint', 'mint', 'mint'], maxCapacity: 4 },
    { id: '3', colors: [], maxCapacity: 4 },
  ];
  assert.equal(isLevelComplete(completedTubes), true);
});

test('hasValidMoves and findBestHintMove detect deadlocks and optimal moves', () => {
  const deadlockedBoard: Tube[] = [
    { id: '1', colors: ['coral', 'mint', 'yellow', 'violet'], maxCapacity: 4 },
    { id: '2', colors: ['mint', 'yellow', 'violet', 'coral'], maxCapacity: 4 },
  ];
  assert.equal(hasValidMoves(deadlockedBoard), false);
  assert.equal(findBestHintMove(deadlockedBoard), null);

  const playableBoard: Tube[] = [
    { id: '1', colors: ['mint', 'coral'], maxCapacity: 4 },
    { id: '2', colors: ['coral', 'coral', 'coral'], maxCapacity: 4 },
    { id: '3', colors: [], maxCapacity: 4 },
  ];
  assert.equal(hasValidMoves(playableBoard), true);
  const hint = findBestHintMove(playableBoard);
  assert.notEqual(hint, null);
  assert.equal(hint!.sourceIndex, 0);
  assert.equal(hint!.targetIndex, 1);
});

test('calculateStars computes 1, 2, or 3 stars accurately', () => {
  assert.equal(calculateStars(8, 10), 3);
  assert.equal(calculateStars(13, 10), 2);
  assert.equal(calculateStars(20, 10), 1);
});

test('getLevelData generates valid non-completed puzzles for levels 1..50', () => {
  for (let lvl = 1; lvl <= 50; lvl++) {
    const data = getLevelData(lvl);
    const tubes = buildInitialTubes(data);
    assert.equal(isLevelComplete(tubes), false, `Level ${lvl} should not start completed`);
    assert.equal(hasValidMoves(tubes), true, `Level ${lvl} must have valid opening moves`);
  }
});

test('cloneTubes creates a deep copy for immutable history', () => {
  const tubes: Tube[] = [{ id: '1', colors: ['coral', 'mint'], maxCapacity: 4 }];
  const cloned = cloneTubes(tubes);
  cloned[0].colors.push('yellow');
  assert.equal(tubes[0].colors.length, 2);
  assert.equal(cloned[0].colors.length, 3);
});

test('formatTime formats seconds into MM:SS', () => {
  assert.equal(formatTime(0), '00:00');
  assert.equal(formatTime(84), '01:24');
  assert.equal(formatTime(359), '05:59');
});
