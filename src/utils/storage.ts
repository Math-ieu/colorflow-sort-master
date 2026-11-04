import { SavedProgress } from '../types/game';

const STORAGE_KEY = 'colorflow_saved_progress_v1';

function buildDefaultLevelStars(): Record<number, number> {
  const stars: Record<number, number> = {};
  for (let i = 1; i < 42; i++) {
    // Realistic star distribution across completed levels 1..41
    stars[i] = i % 7 === 0 ? 2 : 3;
  }
  return stars;
}

export function getDefaultProgress(): SavedProgress {
  return {
    currentLevel: 42,
    maxUnlockedLevel: 42,
    levelStars: buildDefaultLevelStars(),
    coins: 1250,
    undoCount: 3,
    purchasedItems: ['tube-classic', 'palette-classic'],
    equippedVesselSkin: 'tube-classic',
    equippedPalette: 'palette-classic',
    settings: {
      soundEnabled: true,
      hapticsEnabled: true,
      colorBlindMode: false,
    },
    profile: {
      name: 'FlowMaster_42',
      avatarIcon: 'ColorWand',
      levelsCompleted: 41,
      flawlessWins: 35,
    },
  };
}

let memoryStore: SavedProgress | null = null;

export function loadProgress(): SavedProgress {
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      const raw = window.localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        const defaults = getDefaultProgress();
        return {
          ...defaults,
          ...parsed,
          settings: { ...defaults.settings, ...(parsed.settings || {}) },
          profile: { ...defaults.profile, ...(parsed.profile || {}) },
          levelStars: { ...defaults.levelStars, ...(parsed.levelStars || {}) },
        };
      }
    }
  } catch {
    // Fallback to memory or defaults
  }
  if (memoryStore) return memoryStore;
  const initial = getDefaultProgress();
  memoryStore = initial;
  return initial;
}

export function saveProgress(progress: SavedProgress): void {
  memoryStore = progress;
  try {
    if (typeof window !== 'undefined' && window.localStorage) {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
    }
  } catch {
    // Ignore quota / private browsing errors
  }
}

export function resetProgress(): SavedProgress {
  const fresh: SavedProgress = {
    currentLevel: 1,
    maxUnlockedLevel: 1,
    levelStars: {},
    coins: 250,
    undoCount: 3,
    purchasedItems: ['tube-classic', 'palette-classic'],
    equippedVesselSkin: 'tube-classic',
    equippedPalette: 'palette-classic',
    settings: {
      soundEnabled: true,
      hapticsEnabled: true,
      colorBlindMode: false,
    },
    profile: {
      name: 'FlowMaster',
      avatarIcon: 'ColorWand',
      levelsCompleted: 0,
      flawlessWins: 0,
    },
  };
  saveProgress(fresh);
  return fresh;
}
