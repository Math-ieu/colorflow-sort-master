import { LevelData, LiquidColor, Tube } from '../types/game';
import { MAX_TUBE_CAPACITY } from './gameEngine';

export const PRESET_LEVELS: LevelData[] = [
  {
    levelNumber: 1,
    difficulty: 'Easy',
    tubes: [
      ['coral', 'mint', 'coral', 'mint'],
      ['mint', 'coral', 'mint', 'coral'],
      [],
    ],
    milestoneText: '1 / 5 Sorts',
    parMoves: 5,
  },
  {
    levelNumber: 2,
    difficulty: 'Easy',
    tubes: [
      ['coral', 'yellow', 'coral', 'yellow'],
      ['yellow', 'mint', 'yellow', 'mint'],
      ['mint', 'coral', 'mint', 'coral'],
      [],
    ],
    milestoneText: '2 / 5 Sorts',
    parMoves: 7,
  },
  {
    levelNumber: 3,
    difficulty: 'Easy',
    tubes: [
      ['violet', 'coral', 'mint', 'yellow'],
      ['yellow', 'violet', 'coral', 'mint'],
      ['mint', 'yellow', 'violet', 'coral'],
      ['coral', 'mint', 'yellow', 'violet'],
      [],
      [],
    ],
    milestoneText: '3 / 5 Sorts',
    parMoves: 9,
  },
  {
    // Exact Stitch Reference Level 42
    levelNumber: 42,
    difficulty: 'Normal',
    tubes: [
      ['violet', 'yellow', 'mint', 'coral'],
      ['mint', 'coral', 'yellow', 'mint'],
      ['violet', 'yellow', 'coral', 'violet'],
      ['yellow', 'mint', 'coral', 'violet'],
      [],
    ],
    milestoneText: '3 / 5 Sorts',
    parMoves: 9,
  },
  {
    levelNumber: 43,
    difficulty: 'Normal',
    tubes: [
      ['emerald', 'coral', 'yellow', 'mint'],
      ['mint', 'emerald', 'coral', 'violet'],
      ['violet', 'yellow', 'emerald', 'coral'],
      ['coral', 'mint', 'violet', 'yellow'],
      ['yellow', 'violet', 'mint', 'emerald'],
      [],
      [],
    ],
    milestoneText: '4 / 5 Sorts',
    parMoves: 12,
  },
  {
    levelNumber: 44,
    difficulty: 'Hard',
    tubes: [
      ['violet', 'gold', 'coral', 'mint'],
      ['mint', 'yellow', 'violet', 'emerald'],
      ['emerald', 'coral', 'yellow', 'gold'],
      ['gold', 'violet', 'mint', 'coral'],
      ['coral', 'emerald', 'gold', 'yellow'],
      ['yellow', 'emerald', 'violet', 'mint'],
      [],
      [],
    ],
    milestoneText: '5 / 5 Sorts',
    parMoves: 15,
  },
];

/**
 * Loads a level by number, or generates a solvable level procedurally
 * guaranteed to have 2 empty buffer tubes (for >=4 colors) and zero pre-completed tubes.
 */
export function getLevelData(levelNum: number): LevelData {
  const found = PRESET_LEVELS.find((l) => l.levelNumber === levelNum);
  if (found) {
    return found;
  }

  const availableColors: LiquidColor[] = [
    'coral',
    'mint',
    'yellow',
    'violet',
    'emerald',
    'gold',
  ];
  const numColors =
    levelNum <= 5
      ? 3
      : levelNum <= 18
      ? 4
      : levelNum <= 35
      ? 5
      : 6;
  const activeColors = availableColors.slice(0, numColors);

  // Build deterministic non-monochrome tubes using cyclic Latin-square style permutation
  // + seeded swaps so every color has 4 segments and no tube starts already completed.
  const pool: LiquidColor[] = [];
  for (let layer = 0; layer < MAX_TUBE_CAPACITY; layer++) {
    for (let cIdx = 0; cIdx < numColors; cIdx++) {
      const shiftedIdx = (cIdx + layer + (levelNum % Math.max(1, numColors - 1))) % numColors;
      pool.push(activeColors[shiftedIdx]);
    }
  }

  // Deterministic pseudo-random swaps that preserve non-monochrome guarantee
  for (let step = 0; step < numColors * 3; step++) {
    const a = Math.floor(Math.abs(Math.sin(levelNum * 313 + step * 17)) * pool.length);
    const b = Math.floor(Math.abs(Math.cos(levelNum * 719 + step * 29)) * pool.length);
    const tmp = pool[a];
    pool[a] = pool[b];
    pool[b] = tmp;
  }

  const tubes: LiquidColor[][] = [];
  for (let i = 0; i < numColors; i++) {
    const slice = pool.slice(i * MAX_TUBE_CAPACITY, (i + 1) * MAX_TUBE_CAPACITY);
    tubes.push(slice);
  }

  // Ensure no tube starts with 4 identical colors
  for (let i = 0; i < numColors; i++) {
    const t = tubes[i];
    if (t.every((c) => c === t[0])) {
      const nextTubeIdx = (i + 1) % numColors;
      const swapColor = tubes[nextTubeIdx][0];
      tubes[nextTubeIdx][0] = t[t.length - 1];
      t[t.length - 1] = swapColor;
    }
  }

  // Add 2 empty tubes for guaranteed solvability (or 1 for 2-color tutorial)
  tubes.push([]);
  if (numColors >= 3) {
    tubes.push([]);
  }

  return {
    levelNumber: levelNum,
    difficulty: levelNum > 35 ? 'Hard' : levelNum > 15 ? 'Normal' : 'Easy',
    tubes,
    milestoneText: `${((levelNum - 1) % 5) + 1} / 5 Sorts`,
    parMoves: numColors * 2 + 2,
  };
}

/**
 * Builds initial Tube objects from level data
 */
export function buildInitialTubes(levelData: LevelData): Tube[] {
  return levelData.tubes.map((colors, index) => ({
    id: `tube-${levelData.levelNumber}-${index}-${Date.now()}`,
    colors: [...colors],
    maxCapacity: MAX_TUBE_CAPACITY,
  }));
}
