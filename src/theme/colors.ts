// Design tokens extracted from Stitch project: ColorFlow Mobile Game UI
export const Colors = {
  // Sorting liquid tokens
  coral: '#FF6B6B',
  coralShade: '#E04848',
  coralDeep: '#AE2F34',
  
  mint: '#4ECDC4',
  mintShade: '#36B1A8',
  mintDeep: '#006A65',
  
  sunnyYellow: '#FFE66D',
  yellowShade: '#E6CE52',
  yellowDeep: '#6D5E00',
  
  deepViolet: '#9B5DE5',
  violetShade: '#8243CB',
  lavenderLight: '#DCD8F8',

  // Progress & Rewards
  emerald: '#10B981',
  emeraldShade: '#059669',
  emeraldLight: '#D1FAE5',

  gold: '#F59E0B',
  goldShade: '#D97706',
  goldLight: '#FEF3C7',
  goldDark: '#B45309',

  // Canvas & Surfaces
  canvas: '#F5F3FC',
  canvasGlow: '#FCF8FF',
  surfaceCard: 'rgba(255, 255, 255, 0.88)',
  surfaceCardPure: '#FFFFFF',
  surfaceContainer: '#EFECFF',
  surfaceContainerHigh: '#E8E6FC',
  surfaceContainerLow: '#F8F6FF',
  
  // HUD & Text
  darkText: '#1A1A2A',
  mutedText: '#6B7280',
  lightText: '#FFFFFF',
  borderLight: 'rgba(255, 255, 255, 0.85)',
  borderOutline: '#E2E0F2',
  borderGlass: 'rgba(255, 255, 255, 0.6)',
  
  // Glass Vessel styling
  glassBg: 'rgba(255, 255, 255, 0.45)',
  glassBorder: 'rgba(255, 255, 255, 0.85)',
  glassShine: 'rgba(255, 255, 255, 0.4)',
  glassShelf: '#E3E0F4',
  selectedAura: 'rgba(78, 205, 196, 0.55)',

  // Ad Banner & Tag
  adBg: '#F0EEFA',
  adTagBg: '#D8D4EC',
  adTagText: '#4A4668',
} as const;

export type ColorToken = keyof typeof Colors;
