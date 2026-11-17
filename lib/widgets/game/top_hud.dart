import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';
import '../common/coin_badge.dart';

/// Top game HUD showing brand pill, coin balance, action buttons,
/// level pill, difficulty badge, and live sort milestone progress.
class TopHUD extends StatelessWidget {
  final int levelNumber;
  final String difficulty;
  final String milestoneText;
  final int coins;
  final bool isSoundEnabled;
  final String avatarId;
  final VoidCallback onToggleSound;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenProfile;

  const TopHUD({
    super.key,
    required this.levelNumber,
    required this.difficulty,
    required this.milestoneText,
    required this.coins,
    required this.isSoundEnabled,
    this.avatarId = 'ColorWand',
    required this.onToggleSound,
    this.onOpenSettings,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final AvatarOption activeAvatar = avatarOptionFor(avatarId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Brand / Play Pill, Coins Counter, Action Circle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: const Color(0xFFECE8FB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          child: Text(
                            'ColorFlow',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3B82F6),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wine_bar_outlined,
                                size: 13,
                                color: AppColors.coralDeep,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'PLAY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.coralDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CoinBadge(amount: coins),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleHudButton(
                    icon: isSoundEnabled
                        ? Icons.volume_up_outlined
                        : Icons.volume_off_outlined,
                    iconColor: AppColors.darkText,
                    iconSize: 18,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFEAE6FA),
                    onTap: () {
                      AudioService.maybeOf(context)?.playClick();
                      onToggleSound();
                    },
                  ),
                  const SizedBox(width: 6),
                  _CircleHudButton(
                    icon: Icons.settings_outlined,
                    iconColor: AppColors.darkText,
                    iconSize: 18,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFEAE6FA),
                    onTap: () {
                      AudioService.maybeOf(context)?.playClick();
                      onOpenSettings?.call();
                    },
                  ),
                  const SizedBox(width: 6),
                  _CircleHudButton(
                    key: const Key('profile_hud_button'),
                    icon: activeAvatar.icon,
                    iconColor: activeAvatar.color,
                    iconSize: 18,
                    backgroundColor: activeAvatar.color.withOpacity(0.12),
                    borderColor: activeAvatar.color,
                    borderWidth: 2,
                    onTap: () {
                      AudioService.maybeOf(context)?.playClick();
                      onOpenProfile?.call();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Level Badge, Difficulty Chip, Milestone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.coralDeep,
                      borderRadius: BorderRadius.circular(9999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coralDeep.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.water_drop,
                          size: 15,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level $levelNumber',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_outline,
                          size: 12,
                          color: Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          difficulty,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF5B21B6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Milestone',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            milestoneText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.mintDeep,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCCFBF1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              size: 12,
                              color: AppColors.mintDeep,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleHudButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback onTap;

  const _CircleHudButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 1,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1E1E2E),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
