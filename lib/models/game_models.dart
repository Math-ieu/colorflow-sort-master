import 'package:flutter/material.dart';

/// Liquid colors supported inside puzzle tubes.
enum LiquidColor {
  coral,
  mint,
  yellow,
  violet,
  emerald,
  gold;

  String get key => name;

  static LiquidColor fromKey(String k) {
    return LiquidColor.values.firstWhere(
      (e) => e.name == k,
      orElse: () => LiquidColor.coral,
    );
  }
}

/// Customizable glass vessel skins available in the shop.
enum VesselSkinId {
  tubeClassic('tube-classic'),
  tubeCrystal('tube-crystal'),
  tubeGold('tube-gold'),
  tubeCyber('tube-cyber');

  final String id;
  const VesselSkinId(this.id);

  static VesselSkinId fromId(String id) {
    return VesselSkinId.values.firstWhere(
      (e) => e.id == id,
      orElse: () => VesselSkinId.tubeClassic,
    );
  }
}

/// Customizable liquid color palettes available in the shop.
enum FluidPaletteId {
  paletteClassic('palette-classic'),
  themeNeon('theme-neon'),
  paletteOcean('palette-ocean');

  final String id;
  const FluidPaletteId(this.id);

  static FluidPaletteId fromId(String id) {
    return FluidPaletteId.values.firstWhere(
      (e) => e.id == id,
      orElse: () => FluidPaletteId.paletteClassic,
    );
  }
}

/// Level difficulty classification.
enum Difficulty {
  easy('Easy'),
  normal('Normal'),
  hard('Hard');

  final String label;
  const Difficulty(this.label);
}

/// Bottom navigation bar tabs.
enum ActiveTab { play, levels, shop }

/// Rewarded ad placements across gameplay, victory modal, and shop.
enum RewardedAdTrigger {
  extraTube('extra_tube'),
  refillUndo('refill_undo'),
  claim3x('claim_3x'),
  freeCoins('free_coins');

  final String key;
  const RewardedAdTrigger(this.key);
}

/// Shop catalog item categories.
enum ShopItemKind { vessel, palette, consumable }

/// Represents a single glass test tube holding stacked liquid layers.
/// Index `0` is the bottom layer and `colors.last` is the top layer.
class Tube {
  final String id;
  final List<LiquidColor> colors;
  final int maxCapacity;

  const Tube({
    required this.id,
    required this.colors,
    this.maxCapacity = 4,
  });

  Tube clone() => Tube(
        id: id,
        colors: List<LiquidColor>.from(colors),
        maxCapacity: maxCapacity,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'colors': colors.map((c) => c.key).toList(),
        'maxCapacity': maxCapacity,
      };

  factory Tube.fromJson(Map<String, dynamic> json) {
    final rawColors = json['colors'] as List<dynamic>? ?? const [];
    return Tube(
      id: json['id'] as String? ?? 'tube-0',
      colors: rawColors.map((e) => LiquidColor.fromKey(e.toString())).toList(),
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 4,
    );
  }
}

/// Static definition of a puzzle level.
class LevelData {
  final int levelNumber;
  final Difficulty difficulty;
  final List<List<LiquidColor>> tubes;
  final String milestoneText;
  final int parMoves;

  const LevelData({
    required this.levelNumber,
    required this.difficulty,
    required this.tubes,
    required this.milestoneText,
    this.parMoves = 10,
  });
}

/// Persistent audio, haptics, and accessibility preferences.
class PlayerSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool colorBlindMode;

  const PlayerSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.colorBlindMode = false,
  });

  PlayerSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? colorBlindMode,
  }) {
    return PlayerSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'colorBlindMode': colorBlindMode,
      };

  factory PlayerSettings.fromJson(Map<String, dynamic> json) {
    return PlayerSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      colorBlindMode: json['colorBlindMode'] as bool? ?? false,
    );
  }
}

/// Persistent player identity and career statistics.
class PlayerProfile {
  final String name;
  final String avatarIcon;
  final int levelsCompleted;
  final int flawlessWins;

  const PlayerProfile({
    this.name = 'FlowMaster',
    this.avatarIcon = 'ColorWand',
    this.levelsCompleted = 0,
    this.flawlessWins = 0,
  });

  PlayerProfile copyWith({
    String? name,
    String? avatarIcon,
    int? levelsCompleted,
    int? flawlessWins,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      flawlessWins: flawlessWins ?? this.flawlessWins,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarIcon': avatarIcon,
        'levelsCompleted': levelsCompleted,
        'flawlessWins': flawlessWins,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      name: json['name'] as String? ?? 'FlowMaster',
      avatarIcon: json['avatarIcon'] as String? ?? 'ColorWand',
      levelsCompleted: (json['levelsCompleted'] as num?)?.toInt() ?? 0,
      flawlessWins: (json['flawlessWins'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Complete saved player state stored in SharedPreferences.
class SavedProgress {
  final int currentLevel;
  final int maxUnlockedLevel;
  final Map<int, int> levelStars;
  final int coins;
  final int undoCount;
  final List<String> purchasedItems;
  final VesselSkinId equippedVesselSkin;
  final FluidPaletteId equippedPalette;
  final PlayerSettings settings;
  final PlayerProfile profile;

  const SavedProgress({
    required this.currentLevel,
    required this.maxUnlockedLevel,
    required this.levelStars,
    required this.coins,
    required this.undoCount,
    required this.purchasedItems,
    required this.equippedVesselSkin,
    required this.equippedPalette,
    required this.settings,
    required this.profile,
  });

  int get totalStars => levelStars.values.fold(0, (s, v) => s + v);

  /// Clean Level 1 starting defaults for fresh players and progress resets.
  factory SavedProgress.initial() => const SavedProgress(
        currentLevel: 1,
        maxUnlockedLevel: 1,
        levelStars: {},
        coins: 250,
        undoCount: 3,
        purchasedItems: ['tube-classic', 'palette-classic'],
        equippedVesselSkin: VesselSkinId.tubeClassic,
        equippedPalette: FluidPaletteId.paletteClassic,
        settings: PlayerSettings(),
        profile: PlayerProfile(
          name: 'FlowMaster',
          avatarIcon: 'ColorWand',
          levelsCompleted: 0,
          flawlessWins: 0,
        ),
      );

  SavedProgress copyWith({
    int? currentLevel,
    int? maxUnlockedLevel,
    Map<int, int>? levelStars,
    int? coins,
    int? undoCount,
    List<String>? purchasedItems,
    VesselSkinId? equippedVesselSkin,
    FluidPaletteId? equippedPalette,
    PlayerSettings? settings,
    PlayerProfile? profile,
  }) {
    return SavedProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      maxUnlockedLevel: maxUnlockedLevel ?? this.maxUnlockedLevel,
      levelStars: levelStars ?? this.levelStars,
      coins: coins ?? this.coins,
      undoCount: undoCount ?? this.undoCount,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      equippedVesselSkin: equippedVesselSkin ?? this.equippedVesselSkin,
      equippedPalette: equippedPalette ?? this.equippedPalette,
      settings: settings ?? this.settings,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentLevel': currentLevel,
        'maxUnlockedLevel': maxUnlockedLevel,
        'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
        'coins': coins,
        'undoCount': undoCount,
        'purchasedItems': purchasedItems,
        'equippedVesselSkin': equippedVesselSkin.id,
        'equippedPalette': equippedPalette.id,
        'settings': settings.toJson(),
        'profile': profile.toJson(),
      };

  factory SavedProgress.fromJson(Map<String, dynamic> json) {
    final defaults = SavedProgress.initial();

    final rawStars = json['levelStars'];
    final parsedStars = <int, int>{};
    if (rawStars is Map) {
      rawStars.forEach((key, value) {
        final lvl = int.tryParse(key.toString());
        if (lvl != null && value is num) {
          parsedStars[lvl] = value.toInt();
        }
      });
    }

    final rawPurchased = json['purchasedItems'];
    final parsedPurchased = rawPurchased is List
        ? rawPurchased.map((e) => e.toString()).toList()
        : List<String>.from(defaults.purchasedItems);

    final rawSettings = json['settings'];
    final parsedSettings = rawSettings is Map
        ? PlayerSettings.fromJson(Map<String, dynamic>.from(rawSettings))
        : defaults.settings;

    final rawProfile = json['profile'];
    final parsedProfile = rawProfile is Map
        ? PlayerProfile.fromJson(Map<String, dynamic>.from(rawProfile))
        : defaults.profile;

    return SavedProgress(
      currentLevel:
          (json['currentLevel'] as num?)?.toInt() ?? defaults.currentLevel,
      maxUnlockedLevel: (json['maxUnlockedLevel'] as num?)?.toInt() ??
          defaults.maxUnlockedLevel,
      levelStars: parsedStars,
      coins: (json['coins'] as num?)?.toInt() ?? defaults.coins,
      undoCount: (json['undoCount'] as num?)?.toInt() ?? defaults.undoCount,
      purchasedItems: parsedPurchased,
      equippedVesselSkin: json['equippedVesselSkin'] is String
          ? VesselSkinId.fromId(json['equippedVesselSkin'] as String)
          : defaults.equippedVesselSkin,
      equippedPalette: json['equippedPalette'] is String
          ? FluidPaletteId.fromId(json['equippedPalette'] as String)
          : defaults.equippedPalette,
      settings: parsedSettings,
      profile: parsedProfile,
    );
  }
}

/// Output of a valid pour operation between two tubes.
class PourResult {
  final List<Tube> newTubes;
  final int pouredCount;
  final LiquidColor colorPoured;

  const PourResult({
    required this.newTubes,
    required this.pouredCount,
    required this.colorPoured,
  });
}

/// Suggested move produced by the AI hint solver.
class HintMove {
  final int sourceIndex;
  final int targetIndex;
  final String reason;

  const HintMove({
    required this.sourceIndex,
    required this.targetIndex,
    required this.reason,
  });
}

/// Planned pour returned to the UI so animation runs before state commit.
class PourPlan {
  final int sourceIndex;
  final int targetIndex;
  final PourResult preview;

  const PourPlan({
    required this.sourceIndex,
    required this.targetIndex,
    required this.preview,
  });
}

/// Outcome of tapping a tube on the board.
enum TapOutcome { selected, deselected, invalid, readyToPour, ignored }

/// Result returned by `GameProvider.handleTubeTap`.
class TapResult {
  final TapOutcome outcome;
  final PourPlan? pourPlan;
  final String? message;

  const TapResult(
    this.outcome, {
    this.pourPlan,
    this.message,
  });
}

/// Shop catalog item definition.
class ShopCatalogItem {
  final String id;
  final String name;
  final String category;
  final ShopItemKind kind;
  final int price;
  final String iconKey;
  final Color color;
  final String description;

  const ShopCatalogItem({
    required this.id,
    required this.name,
    required this.category,
    required this.kind,
    required this.price,
    required this.iconKey,
    required this.color,
    required this.description,
  });
}

/// Exact 8 shop catalog items matching the React Native shop screen.
const List<ShopCatalogItem> shopCatalogItems = [
  ShopCatalogItem(
    id: 'tube-classic',
    name: 'Classic Lab Vials',
    category: 'Vessel Skin',
    kind: ShopItemKind.vessel,
    price: 0,
    iconKey: 'flask-outline',
    color: Color(0xFF6366F1),
    description: 'Standard rounded borosilicate laboratory tubes',
  ),
  ShopCatalogItem(
    id: 'tube-crystal',
    name: 'Crystal Flacons',
    category: 'Vessel Skin',
    kind: ShopItemKind.vessel,
    price: 250,
    iconKey: 'diamond-outline',
    color: Color(0xFF0EA5E9),
    description: 'Beveled diamond edges with icy cyan refraction',
  ),
  ShopCatalogItem(
    id: 'tube-gold',
    name: 'Royal Golden Tubes',
    category: 'Vessel Skin',
    kind: ShopItemKind.vessel,
    price: 800,
    iconKey: 'sparkles',
    color: Color(0xFFD97706),
    description: '24k gold rimmed flasks with warm amber sheen',
  ),
  ShopCatalogItem(
    id: 'tube-cyber',
    name: 'Cyber Prism Vials',
    category: 'Vessel Skin',
    kind: ShopItemKind.vessel,
    price: 550,
    iconKey: 'cube-outline',
    color: Color(0xFF9333EA),
    description: 'Futuristic sharp-cut vials with neon violet border',
  ),
  ShopCatalogItem(
    id: 'palette-classic',
    name: 'Vibrant Pastel Fluids',
    category: 'Liquid Palette',
    kind: ShopItemKind.palette,
    price: 0,
    iconKey: 'water-outline',
    color: Color(0xFF4ECDC4),
    description: 'Original tactile pastel liquid colors',
  ),
  ShopCatalogItem(
    id: 'theme-neon',
    name: 'Neon Glow Fluids',
    category: 'Liquid Palette',
    kind: ShopItemKind.palette,
    price: 400,
    iconKey: 'color-palette-outline',
    color: Color(0xFFFF6B6B),
    description: 'High-contrast cyber-luminescent liquid pigments',
  ),
  ShopCatalogItem(
    id: 'palette-ocean',
    name: 'Ocean & Gems Palette',
    category: 'Liquid Palette',
    kind: ShopItemKind.palette,
    price: 450,
    iconKey: 'planet-outline',
    color: Color(0xFF0284C7),
    description: 'Deep ruby, sapphire, jade & amethyst tones',
  ),
  ShopCatalogItem(
    id: 'booster-pack',
    name: 'Undo Master (+10)',
    category: 'Power-up Pack',
    kind: ShopItemKind.consumable,
    price: 150,
    iconKey: 'arrow-undo',
    color: Color(0xFFF59E0B),
    description: 'Instantly adds +10 Undo moves to your inventory',
  ),
];

/// Player avatar badge metadata shared between ProfileModal and TopHUD.
class AvatarOption {
  final String id;
  final IconData icon;
  final Color color;

  const AvatarOption({
    required this.id,
    required this.icon,
    required this.color,
  });
}

const List<AvatarOption> playerAvatarOptions = [
  AvatarOption(
    id: 'ColorWand',
    icon: Icons.auto_fix_high,
    color: Color(0xFFAE2F34),
  ),
  AvatarOption(
    id: 'Diamond',
    icon: Icons.diamond,
    color: Color(0xFF006A65),
  ),
  AvatarOption(
    id: 'Trophy',
    icon: Icons.emoji_events,
    color: Color(0xFFD97706),
  ),
  AvatarOption(
    id: 'Flash',
    icon: Icons.bolt,
    color: Color(0xFF7C3AED),
  ),
  AvatarOption(
    id: 'Rocket',
    icon: Icons.rocket_launch,
    color: Color(0xFF059669),
  ),
  AvatarOption(
    id: 'Sparkles',
    icon: Icons.auto_awesome,
    color: Color(0xFF9333EA),
  ),
];

AvatarOption avatarOptionFor(String id) {
  return playerAvatarOptions.firstWhere(
    (option) => option.id == id,
    orElse: () => playerAvatarOptions.first,
  );
}
