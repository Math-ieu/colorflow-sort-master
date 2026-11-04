import { Tube, LiquidColor } from '../types/game';

export const MAX_TUBE_CAPACITY = 4;

/**
 * Deep clones the tubes array to preserve immutable history for undo
 */
export function cloneTubes(tubes: Tube[]): Tube[] {
  return tubes.map((t) => ({
    ...t,
    colors: [...t.colors],
  }));
}

/**
 * Checks if a single tube is completely filled with a single uniform color (sealed)
 */
export function isTubeCompleted(tube: Tube): boolean {
  if (!tube || tube.colors.length !== tube.maxCapacity) return false;
  const first = tube.colors[0];
  return tube.colors.every((c) => c === first);
}

/**
 * Checks whether liquid can be poured from source tube to target tube
 */
export function canPour(source: Tube, target: Tube): boolean {
  if (!source || !target) return false;
  if (source.id === target.id) return false;
  if (source.colors.length === 0) return false;
  if (isTubeCompleted(source)) return false;
  if (target.colors.length >= target.maxCapacity) return false;

  // Empty target tube can always receive liquid
  if (target.colors.length === 0) return true;

  const sourceTop = source.colors[source.colors.length - 1];
  const targetTop = target.colors[target.colors.length - 1];

  return sourceTop === targetTop;
}

/**
 * Executes a pour move between source and target tubes.
 * Moves contiguous units of the matching top color up to the available capacity.
 * Returns the modified tubes array, or null if pour is not allowed.
 */
export function executePour(
  tubes: Tube[],
  sourceIndex: number,
  targetIndex: number
): { newTubes: Tube[]; pouredCount: number; colorPoured: LiquidColor } | null {
  const source = tubes[sourceIndex];
  const target = tubes[targetIndex];

  if (!canPour(source, target)) {
    return null;
  }

  const nextTubes = cloneTubes(tubes);
  const nextSource = nextTubes[sourceIndex];
  const nextTarget = nextTubes[targetIndex];

  const colorToPour = nextSource.colors[nextSource.colors.length - 1];
  const availableSpace = nextTarget.maxCapacity - nextTarget.colors.length;

  // Count how many consecutive items of colorToPour exist at the top of source
  let consecutiveCount = 0;
  for (let i = nextSource.colors.length - 1; i >= 0; i--) {
    if (nextSource.colors[i] === colorToPour) {
      consecutiveCount++;
    } else {
      break;
    }
  }

  const amountToPour = Math.min(consecutiveCount, availableSpace);

  for (let i = 0; i < amountToPour; i++) {
    nextSource.colors.pop();
    nextTarget.colors.push(colorToPour);
  }

  return {
    newTubes: nextTubes,
    pouredCount: amountToPour,
    colorPoured: colorToPour,
  };
}

/**
 * Checks if all tubes are either completely empty or completely filled with a single color
 */
export function isLevelComplete(tubes: Tube[]): boolean {
  if (tubes.length === 0) return false;

  let filledTubesCount = 0;

  for (const tube of tubes) {
    if (tube.colors.length === 0) {
      // Empty tube is valid
      continue;
    }

    // A filled tube must have reached maximum capacity
    if (tube.colors.length !== tube.maxCapacity) {
      return false;
    }

    // All colors inside the tube must be the exact same color
    const firstColor = tube.colors[0];
    const isSingleColor = tube.colors.every((c) => c === firstColor);
    if (!isSingleColor) {
      return false;
    }

    filledTubesCount++;
  }

  return filledTubesCount > 0;
}

/**
 * Checks if the player has at least one meaningful valid move left
 */
export function hasValidMoves(tubes: Tube[]): boolean {
  if (isLevelComplete(tubes)) return false;

  for (let i = 0; i < tubes.length; i++) {
    const src = tubes[i];
    if (src.colors.length === 0 || isTubeCompleted(src)) continue;

    const isSrcMonochrome = src.colors.every((c) => c === src.colors[0]);

    for (let j = 0; j < tubes.length; j++) {
      if (i === j) continue;
      const dst = tubes[j];
      if (!canPour(src, dst)) continue;

      // Pouring a monochromatic partial tube into an empty tube is a redundant no-op
      if (isSrcMonochrome && dst.colors.length === 0) {
        continue;
      }

      return true;
    }
  }

  return false;
}

/**
 * AI Hint Solver: Finds the highest-value next move on the board
 */
export function findBestHintMove(
  tubes: Tube[]
): { sourceIndex: number; targetIndex: number; reason: string } | null {
  let bestMove: {
    sourceIndex: number;
    targetIndex: number;
    score: number;
    reason: string;
  } | null = null;

  for (let i = 0; i < tubes.length; i++) {
    const src = tubes[i];
    if (src.colors.length === 0 || isTubeCompleted(src)) continue;

    const topColor = src.colors[src.colors.length - 1];
    let topGroupCount = 0;
    for (let k = src.colors.length - 1; k >= 0; k--) {
      if (src.colors[k] === topColor) topGroupCount++;
      else break;
    }

    const isSrcMonochrome = topGroupCount === src.colors.length;

    for (let j = 0; j < tubes.length; j++) {
      if (i === j) continue;
      const dst = tubes[j];
      if (!canPour(src, dst)) continue;

      // Avoid pointless move of single-color stack into empty tube
      if (isSrcMonochrome && dst.colors.length === 0) continue;

      const availableSpace = dst.maxCapacity - dst.colors.length;
      let score = 10;
      let reason = `Pour Tube #${i + 1} into Tube #${j + 1}`;

      // Does this move complete the destination tube?
      if (
        dst.colors.length > 0 &&
        dst.colors.every((c) => c === topColor) &&
        dst.colors.length + Math.min(topGroupCount, availableSpace) === dst.maxCapacity
      ) {
        score = 100;
        reason = `Seal Tube #${j + 1} by pouring from Tube #${i + 1}!`;
      } else if (dst.colors.length > 0 && availableSpace >= topGroupCount) {
        // Moves entire top group onto matching color, uncovering next layer
        score = 80 + topGroupCount * 3;
        reason = `Uncover new color in Tube #${i + 1} → Tube #${j + 1}`;
      } else if (dst.colors.length === 0 && !isSrcMonochrome && availableSpace >= topGroupCount) {
        // Uses empty tube to free up buried color
        score = 50 + topGroupCount * 2;
        reason = `Move ${topColor.toUpperCase()} from Tube #${i + 1} to empty Tube #${j + 1}`;
      } else if (dst.colors.length > 0) {
        score = 35;
      }

      if (!bestMove || score > bestMove.score) {
        bestMove = { sourceIndex: i, targetIndex: j, score, reason };
      }
    }
  }

  return bestMove
    ? {
        sourceIndex: bestMove.sourceIndex,
        targetIndex: bestMove.targetIndex,
        reason: bestMove.reason,
      }
    : null;
}

/**
 * Calculates 1, 2, or 3 stars earned based on move count vs level par
 */
export function calculateStars(moves: number, parMoves: number = 10): 1 | 2 | 3 {
  if (moves <= parMoves) return 3;
  if (moves <= Math.ceil(parMoves * 1.45)) return 2;
  return 1;
}

/**
 * Formats seconds into MM:SS string
 */
export function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  const mm = mins < 10 ? `0${mins}` : `${mins}`;
  const ss = secs < 10 ? `0${secs}` : `${secs}`;
  return `${mm}:${ss}`;
}
