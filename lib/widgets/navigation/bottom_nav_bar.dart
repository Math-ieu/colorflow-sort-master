import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

/// Bottom tab bar linking Play, Levels, Shop, and Ranks screens.
class BottomNavBar extends StatelessWidget {
  final ActiveTab activeTab;
  final ValueChanged<ActiveTab> onSelectTab;

  const BottomNavBar({
    super.key,
    required this.activeTab,
    required this.onSelectTab,
  });

  static const List<
      ({
        ActiveTab tab,
        String label,
        IconData icon,
        IconData iconFilled,
      })> _tabs = [
    (
      tab: ActiveTab.play,
      label: 'Play',
      icon: Icons.sports_esports_outlined,
      iconFilled: Icons.sports_esports,
    ),
    (
      tab: ActiveTab.levels,
      label: 'Levels',
      icon: Icons.map_outlined,
      iconFilled: Icons.map,
    ),
    (
      tab: ActiveTab.shop,
      label: 'Shop',
      icon: Icons.storefront_outlined,
      iconFilled: Icons.storefront,
    ),
    (
      tab: ActiveTab.ranks,
      label: 'Ranks',
      icon: Icons.leaderboard_outlined,
      iconFilled: Icons.leaderboard,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFECE9F7),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 14),
          child: Row(
            children: _tabs.map((item) {
              final isActive = activeTab == item.tab;
              final color =
                  isActive ? AppColors.coralDeep : const Color(0xFF584140);

              return Expanded(
                child: InkWell(
                  onTap: () {
                    AudioService.maybeOf(context)?.playClick();
                    onSelectTab(item.tab);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.iconFilled : item.icon,
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
