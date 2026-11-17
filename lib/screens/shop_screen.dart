import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common/coin_badge.dart';
import '../widgets/navigation/bottom_nav_bar.dart';

/// Vessel skins, fluid palettes, power-up packs, and free rewarded coin chest.
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  IconData _iconForKey(String key) {
    switch (key) {
      case 'flask-outline':
        return Icons.science_outlined;
      case 'diamond-outline':
        return Icons.diamond_outlined;
      case 'sparkles':
        return Icons.auto_awesome;
      case 'cube-outline':
        return Icons.view_in_ar;
      case 'water-outline':
        return Icons.water_drop_outlined;
      case 'color-palette-outline':
        return Icons.palette_outlined;
      case 'planet-outline':
        return Icons.public;
      case 'arrow-undo':
        return Icons.undo;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final int coins = provider.coins;
    final int undoCount = provider.undoCount;
    final List<String> purchasedItems = provider.purchasedItems;
    final VesselSkinId equippedVesselSkin = provider.equippedVesselSkin;
    final FluidPaletteId equippedPalette = provider.equippedPalette;

    return Container(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFECE7FA), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vessel & Liquid Shop',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Customize tubes, palettes & power-ups (Undos: $undoCount)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CoinBadge(amount: coins),
                ],
              ),
            ),

            // Catalog Scroll List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    // Free Coin Chest Banner
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFF59E0B),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE68A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.card_giftcard,
                              size: 24,
                              color: Color(0xFF78350F),
                            ),
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Free Coin Chest',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    'Watch a short video to claim +100 Coins',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                AudioService.maybeOf(context)?.playClick();
                                provider.requestRewardedAd(
                                  RewardedAdTrigger.freeCoins,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_circle_filled,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '+100',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 8 Catalog Items
                    ...shopCatalogItems.map((item) {
                      final bool isOwned =
                          item.kind != ShopItemKind.consumable &&
                              purchasedItems.contains(item.id);
                      final bool isEquipped =
                          (item.kind == ShopItemKind.vessel &&
                                  equippedVesselSkin.id == item.id) ||
                              (item.kind == ShopItemKind.palette &&
                                  equippedPalette.id == item.id);
                      final bool canAfford = coins >= item.price;
                      final bool isDisabled =
                          isEquipped || (!isOwned && !canAfford);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? const Color(0xFFF0FDFA)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isEquipped
                                ? AppColors.mint
                                : const Color(0xFFECE7FB),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D1E1E32),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              margin: const EdgeInsets.only(right: 14),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _iconForKey(item.iconKey),
                                size: 26,
                                color: item.color,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.category.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF9CA3AF),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (item.kind == ShopItemKind.palette)
                                      _PaletteSwatchPreview(
                                        paletteId:
                                            FluidPaletteId.fromId(item.id),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(9999),
                                onTap: isDisabled
                                    ? null
                                    : () {
                                        AudioService.maybeOf(context)
                                            ?.playClick();
                                        provider.buyOrEquipShopItem(
                                          item.id,
                                          item.kind,
                                          item.price,
                                        );
                                      },
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 82),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isEquipped
                                        ? const Color(0xFFCCFBF1)
                                        : isOwned
                                            ? const Color(0xFF4F46E5)
                                            : canAfford
                                                ? AppColors.mintDeep
                                                : const Color(0xFFD1D5DB),
                                    borderRadius: BorderRadius.circular(9999),
                                    border: isEquipped
                                        ? Border.all(
                                            color: AppColors.mint,
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: isEquipped
                                      ? const Text(
                                          'EQUIPPED',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.mintDeep,
                                          ),
                                        )
                                      : isOwned
                                          ? const Text(
                                              'EQUIP',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  '\$',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${item.price}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNavBar(
              activeTab: provider.activeTab,
              onSelectTab: provider.selectTab,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaletteSwatchPreview extends StatelessWidget {
  const _PaletteSwatchPreview({required this.paletteId});

  final FluidPaletteId paletteId;

  @override
  Widget build(BuildContext context) {
    final schemeMap = paletteSchemes[paletteId];
    if (schemeMap == null) return const SizedBox.shrink();

    const previewColors = [
      LiquidColor.coral,
      LiquidColor.mint,
      LiquidColor.yellow,
      LiquidColor.violet,
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: previewColors.map((lc) {
          final color = schemeMap[lc]?.bg ?? AppColors.coral;
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 0.8,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
