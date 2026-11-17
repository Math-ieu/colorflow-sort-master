import 'package:flutter/material.dart';
import '../models/game_models.dart';

/// Color tokens for ColorFlow: Sort Master.
class AppColors {
  AppColors._();

  // Liquids & Rewards
  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralShade = Color(0xFFE04848);
  static const Color coralDeep = Color(0xFFAE2F34);

  static const Color mint = Color(0xFF4ECDC4);
  static const Color mintShade = Color(0xFF36B1A8);
  static const Color mintDeep = Color(0xFF006A65);

  static const Color sunnyYellow = Color(0xFFFFE66D);
  static const Color yellowShade = Color(0xFFE6CE52);
  static const Color yellowDeep = Color(0xFF6D5E00);

  static const Color deepViolet = Color(0xFF9B5DE5);
  static const Color violetShade = Color(0xFF8243CB);
  static const Color lavenderLight = Color(0xFFDCD8F8);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldShade = Color(0xFF059669);
  static const Color emeraldLight = Color(0xFFD1FAE5);

  static const Color gold = Color(0xFFF59E0B);
  static const Color goldShade = Color(0xFFD97706);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color goldDark = Color(0xFFB45309);

  // Canvas, Surfaces, HUD & Glass
  static const Color appRootBg = Color(0xFFEBE7F7);
  static const Color canvas = Color(0xFFF5F3FC);
  static const Color canvasGlow = Color(0xFFFCF8FF);
  static const Color surfaceCard = Color(0xE0FFFFFF);
  static const Color surfaceCardPure = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEFECFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E6FC);
  static const Color surfaceContainerLow = Color(0xFFF8F6FF);

  static const Color darkText = Color(0xFF1A1A2A);
  static const Color mutedText = Color(0xFF6B7280);
  static const Color lightText = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xD9FFFFFF);
  static const Color borderOutline = Color(0xFFE2E0F2);
  static const Color borderGlass = Color(0x99FFFFFF);

  static const Color glassBg = Color(0x73FFFFFF);
  static const Color glassBorder = Color(0xD9FFFFFF);
  static const Color glassShine = Color(0x66FFFFFF);
  static const Color glassShelf = Color(0xFFE3E0F4);
  static const Color selectedAura = Color(0x8C4ECDC4);

  static const Color adBg = Color(0xFFF0EEFA);
  static const Color adTagBg = Color(0xFFD8D4EC);
  static const Color adTagText = Color(0xFF4A4668);
}

/// Visual styling for a liquid segment within a fluid palette.
class LiquidColorScheme {
  final Color bg;
  final Color shine;
  final Color shade;
  final Color meniscus;
  final String symbol;

  const LiquidColorScheme({
    required this.bg,
    required this.shine,
    required this.shade,
    required this.meniscus,
    required this.symbol,
  });
}

/// Palette definitions mapped by [FluidPaletteId] and [LiquidColor].
const Map<FluidPaletteId, Map<LiquidColor, LiquidColorScheme>> paletteSchemes = {
  FluidPaletteId.paletteClassic: {
    LiquidColor.coral: LiquidColorScheme(
      bg: AppColors.coral,
      shine: Color(0xFFFF9E9E),
      shade: AppColors.coralShade,
      meniscus: Color(0xFFFFB8B8),
      symbol: '●',
    ),
    LiquidColor.mint: LiquidColorScheme(
      bg: AppColors.mint,
      shine: Color(0xFF88F2EA),
      shade: AppColors.mintShade,
      meniscus: Color(0xFFB0FAF4),
      symbol: '▲',
    ),
    LiquidColor.yellow: LiquidColorScheme(
      bg: AppColors.sunnyYellow,
      shine: Color(0xFFFFF5AD),
      shade: AppColors.yellowShade,
      meniscus: Color(0xFFFFF9C8),
      symbol: '★',
    ),
    LiquidColor.violet: LiquidColorScheme(
      bg: Color(0xFFB8AFF2),
      shine: Color(0xFFDDD8FF),
      shade: Color(0xFF9A8EE3),
      meniscus: Color(0xFFEAE6FF),
      symbol: '◆',
    ),
    LiquidColor.emerald: LiquidColorScheme(
      bg: AppColors.emerald,
      shine: Color(0xFF6EE7B7),
      shade: AppColors.emeraldShade,
      meniscus: Color(0xFFA7F3D0),
      symbol: '■',
    ),
    LiquidColor.gold: LiquidColorScheme(
      bg: AppColors.gold,
      shine: Color(0xFFFCD34D),
      shade: AppColors.goldShade,
      meniscus: Color(0xFFFDE68A),
      symbol: '♥',
    ),
  },
  FluidPaletteId.themeNeon: {
    LiquidColor.coral: LiquidColorScheme(
      bg: Color(0xFFFF2A85),
      shine: Color(0xFFFF7EB6),
      shade: Color(0xFFD60059),
      meniscus: Color(0xFFFF9EC7),
      symbol: '●',
    ),
    LiquidColor.mint: LiquidColorScheme(
      bg: Color(0xFF00F5D4),
      shine: Color(0xFF80FFED),
      shade: Color(0xFF00C2A8),
      meniscus: Color(0xFFB8FFF5),
      symbol: '▲',
    ),
    LiquidColor.yellow: LiquidColorScheme(
      bg: Color(0xFFFEE440),
      shine: Color(0xFFFFF29C),
      shade: Color(0xFFD9BC00),
      meniscus: Color(0xFFFFF8C4),
      symbol: '★',
    ),
    LiquidColor.violet: LiquidColorScheme(
      bg: Color(0xFF9B5DE5),
      shine: Color(0xFFC69FF5),
      shade: Color(0xFF7635C7),
      meniscus: Color(0xFFDEC4FA),
      symbol: '◆',
    ),
    LiquidColor.emerald: LiquidColorScheme(
      bg: Color(0xFF00BBF9),
      shine: Color(0xFF8AE2FF),
      shade: Color(0xFF008EC2),
      meniscus: Color(0xFFBAEFFF),
      symbol: '■',
    ),
    LiquidColor.gold: LiquidColorScheme(
      bg: Color(0xFFFF9F1C),
      shine: Color(0xFFFFCA80),
      shade: Color(0xFFD47A00),
      meniscus: Color(0xFFFFE0B5),
      symbol: '♥',
    ),
  },
  FluidPaletteId.paletteOcean: {
    LiquidColor.coral: LiquidColorScheme(
      bg: Color(0xFFE11D48),
      shine: Color(0xFFFB7185),
      shade: Color(0xFFBE123C),
      meniscus: Color(0xFFFDA4AF),
      symbol: '●',
    ),
    LiquidColor.mint: LiquidColorScheme(
      bg: Color(0xFF0EA5E9),
      shine: Color(0xFF7DD3FC),
      shade: Color(0xFF0284C7),
      meniscus: Color(0xFFBAE6FD),
      symbol: '▲',
    ),
    LiquidColor.yellow: LiquidColorScheme(
      bg: Color(0xFFFACC15),
      shine: Color(0xFFFEF08A),
      shade: Color(0xFFCA8A04),
      meniscus: Color(0xFFFEF9C3),
      symbol: '★',
    ),
    LiquidColor.violet: LiquidColorScheme(
      bg: Color(0xFF6366F1),
      shine: Color(0xFFA5B4FC),
      shade: Color(0xFF4338CA),
      meniscus: Color(0xFFC7D2FE),
      symbol: '◆',
    ),
    LiquidColor.emerald: LiquidColorScheme(
      bg: Color(0xFF14B8A6),
      shine: Color(0xFF5EEAD4),
      shade: Color(0xFF0F766E),
      meniscus: Color(0xFF99F6E4),
      symbol: '■',
    ),
    LiquidColor.gold: LiquidColorScheme(
      bg: Color(0xFFD97706),
      shine: Color(0xFFFBBF24),
      shade: Color(0xFF92400E),
      meniscus: Color(0xFFFDE68A),
      symbol: '♥',
    ),
  },
};

/// Visual properties for each test tube vessel skin.
class VesselSkinStyle {
  final Color lipBg;
  final Color lipBorder;
  final Color glassBg;
  final Color glassBorder;
  final Color shineColor;
  final double bottomRadius;

  const VesselSkinStyle({
    required this.lipBg,
    required this.lipBorder,
    required this.glassBg,
    required this.glassBorder,
    required this.shineColor,
    required this.bottomRadius,
  });
}

/// Vessel skin style presets mapped by [VesselSkinId].
const Map<VesselSkinId, VesselSkinStyle> vesselSkinStyles = {
  VesselSkinId.tubeClassic: VesselSkinStyle(
    lipBg: Color(0xF2FFFFFF),
    lipBorder: Color(0xE6E6E1F5),
    glassBg: Color(0x85FFFFFF),
    glassBorder: Color(0xF2FFFFFF),
    bottomRadius: 27,
    shineColor: Color(0xADFFFFFF),
  ),
  VesselSkinId.tubeCrystal: VesselSkinStyle(
    lipBg: Color(0xFFE0F2FE),
    lipBorder: Color(0xFF38BDF8),
    glassBg: Color(0x73E0F2FE),
    glassBorder: Color(0xFF7DD3FC),
    bottomRadius: 14,
    shineColor: Color(0xE0FFFFFF),
  ),
  VesselSkinId.tubeGold: VesselSkinStyle(
    lipBg: Color(0xFFFEF3C7),
    lipBorder: Color(0xFFF59E0B),
    glassBg: Color(0x80FFFBEB),
    glassBorder: Color(0xFFFBBF24),
    bottomRadius: 27,
    shineColor: Color(0xCCFEF3C7),
  ),
  VesselSkinId.tubeCyber: VesselSkinStyle(
    lipBg: Color(0xFFF3E8FF),
    lipBorder: Color(0xFFA855F7),
    glassBg: Color(0x73F3E8FF),
    glassBorder: Color(0xFFC084FC),
    bottomRadius: 10,
    shineColor: Color(0xC7E9D5FF),
  ),
};
