import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/common/coin_badge.dart';
import '../widgets/navigation/bottom_nav_bar.dart';

/// Top-3 podium and dynamic leaderboard showing the player's global ranking.
class RanksScreen extends StatelessWidget {
  const RanksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final List<RankCompetitor> sortedPlayers = provider.rankedLeaderboard;
    final RankCompetitor? first =
        sortedPlayers.isNotEmpty ? sortedPlayers[0] : null;
    final RankCompetitor? second =
        sortedPlayers.length > 1 ? sortedPlayers[1] : null;
    final RankCompetitor? third =
        sortedPlayers.length > 2 ? sortedPlayers[2] : null;

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
                          'Global Ranks',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Top ColorFlow Masters • Your Stars: ${provider.totalStars} ⭐',
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
                  CoinBadge(amount: provider.coins),
                ],
              ),
            ),

            // Podium Top 3
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (second != null)
                    _PodiumColumn(
                      medal: '🥈',
                      name: second.name,
                      rankText: '2',
                      avatarBorder: const Color(0xFF94A3B8),
                      avatarIcon: Icons.person,
                      avatarIconColor: const Color(0xFF64748B),
                      avatarIconSize: 24,
                      blockHeight: 75,
                      blockColor: const Color(0xFFE2E8F0),
                      rankTextColor: const Color(0xFF475569),
                    ),
                  const SizedBox(width: 12),
                  if (first != null)
                    _PodiumColumn(
                      medal: '🥇',
                      name: first.name,
                      rankText: '1',
                      avatarBorder: const Color(0xFFF59E0B),
                      avatarIcon: Icons.emoji_events,
                      avatarIconColor: const Color(0xFFD97706),
                      avatarIconSize: 26,
                      blockHeight: 100,
                      blockColor: const Color(0xFFFEF3C7),
                      rankTextColor: const Color(0xFFB45309),
                    ),
                  const SizedBox(width: 12),
                  if (third != null)
                    _PodiumColumn(
                      medal: '🥉',
                      name: third.name,
                      rankText: '3',
                      avatarBorder: const Color(0xFFD97706),
                      avatarIcon: Icons.person,
                      avatarIconColor: const Color(0xFF92400E),
                      avatarIconSize: 24,
                      blockHeight: 60,
                      blockColor: const Color(0xFFFED7AA),
                      rankTextColor: const Color(0xFF475569),
                    ),
                ],
              ),
            ),

            // Leaderboard List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sortedPlayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final p = sortedPlayers[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: p.isUser ? const Color(0xFFEEF2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: p.isUser
                            ? const Color(0xFFC7D2FE)
                            : const Color(0xFFECE7FB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            p.medal,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: p.isUser
                                      ? const Color(0xFF3730A3)
                                      : AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Level ${p.level} Reached',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${p.stars}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.medal,
    required this.name,
    required this.rankText,
    required this.avatarBorder,
    required this.avatarIcon,
    required this.avatarIconColor,
    required this.avatarIconSize,
    required this.blockHeight,
    required this.blockColor,
    required this.rankTextColor,
  });

  final String medal;
  final String name;
  final String rankText;
  final Color avatarBorder;
  final IconData avatarIcon;
  final Color avatarIconColor;
  final double avatarIconSize;
  final double blockHeight;
  final Color blockColor;
  final Color rankTextColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            medal,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: avatarBorder, width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(
              avatarIcon,
              size: avatarIconSize,
              color: avatarIconColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: blockHeight,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              rankText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: rankTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
