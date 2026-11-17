import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common/coin_badge.dart';
import '../widgets/navigation/bottom_nav_bar.dart';

/// 50-level progression grid showing earned stars and unlocked stages.
class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final int currentLevel = provider.currentLevel;
    final int maxUnlockedLevel = provider.maxUnlockedLevel;
    final Map<int, int> levelStars = provider.levelStars;
    final int totalStars = provider.totalStars;

    return Container(
      color: AppColors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            // Top Header
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
                          'Select Level',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$totalStars / 150 Stars Earned • Max Lvl $maxUnlockedLevel',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  CoinBadge(amount: provider.coins),
                ],
              ),
            ),

            // Levels 1..50 Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(50, (index) {
                      final int lvl = index + 1;
                      final bool isUnlocked = lvl <= maxUnlockedLevel;
                      final bool isCurrent = lvl == currentLevel;
                      final int stars = levelStars[lvl] ?? 0;

                      return _LevelTile(
                        levelNumber: lvl,
                        isUnlocked: isUnlocked,
                        isCurrent: isCurrent,
                        stars: stars,
                        onTap: isUnlocked
                            ? () {
                                AudioService.maybeOf(context)?.playClick();
                                provider.selectLevel(lvl);
                              }
                            : null,
                      );
                    }),
                  ),
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

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCurrent,
    required this.stars,
    this.onTap,
  });

  final int levelNumber;
  final bool isUnlocked;
  final bool isCurrent;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isCurrent
        ? AppColors.coralDeep
        : !isUnlocked
            ? const Color(0xFFF3F4F6)
            : Colors.white;
    final Color borderColor = isCurrent
        ? AppColors.coralDeep
        : !isUnlocked
            ? const Color(0xFFE5E7EB)
            : const Color(0xFFECE7FB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isUnlocked
                ? const [
                    BoxShadow(
                      color: Color(0x0D1E1E32),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isUnlocked
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$levelNumber',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: isCurrent ? Colors.white : AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final int starIdx = i + 1;
                        final bool earned = stars >= starIdx;
                        final Color starColor = earned
                            ? (isCurrent
                                ? const Color(0xFFFFE66D)
                                : const Color(0xFFF59E0B))
                            : (isCurrent
                                ? Colors.white.withOpacity(0.45)
                                : const Color(0xFFD1D5DB));
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.5),
                          child: Icon(
                            earned ? Icons.star : Icons.star_border,
                            size: 11,
                            color: starColor,
                          ),
                        );
                      }),
                    ),
                  ],
                )
              : const Icon(
                  Icons.lock,
                  size: 20,
                  color: Color(0xFF9CA3AF),
                ),
        ),
      ),
    );
  }
}
