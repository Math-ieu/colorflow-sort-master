export type LiquidColor = 'coral' | 'mint' | 'yellow' | 'violet' | 'emerald' | 'gold';

export type VesselSkinId = 'tube-classic' | 'tube-crystal' | 'tube-gold' | 'tube-cyber';

export type FluidPaletteId = 'palette-classic' | 'theme-neon' | 'palette-ocean';

export interface Tube {
  id: string;
  colors: LiquidColor[];
  maxCapacity: number;
}

export interface LevelData {
  levelNumber: number;
  difficulty: 'Easy' | 'Normal' | 'Hard';
  tubes: LiquidColor[][];
  milestoneText: string;
  parMoves?: number;
}

export interface PlayerSettings {
  soundEnabled: boolean;
  hapticsEnabled: boolean;
  colorBlindMode: boolean;
}

export interface PlayerProfile {
  name: string;
  avatarIcon: string;
  levelsCompleted: number;
  flawlessWins: number;
}

export interface SavedProgress {
  currentLevel: number;
  maxUnlockedLevel: number;
  levelStars: Record<number, number>;
  coins: number;
  undoCount: number;
  purchasedItems: string[];
  equippedVesselSkin: VesselSkinId;
  equippedPalette: FluidPaletteId;
  settings: PlayerSettings;
  profile: PlayerProfile;
}

export type RewardedAdTrigger =
  | 'extra_tube'
  | 'refill_undo'
  | 'claim_3x'
  | 'free_coins'
  | null;

export interface GameState {
  currentLevel: number;
  tubes: Tube[];
  selectedTubeIndex: number | null;
  moves: number;
  timeSeconds: number;
  undoCount: number;
  coins: number;
  isCompleted: boolean;
  isSoundEnabled: boolean;
  history: Tube[][];
}

export type ActiveTab = 'play' | 'levels' | 'shop' | 'ranks';
