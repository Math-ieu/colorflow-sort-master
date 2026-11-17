import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

/// Modal allowing players to toggle sounds, haptics, color-blind symbols, or reset progress.
class SettingsModal extends StatelessWidget {
  const SettingsModal({
    super.key,
    required this.visible,
    required this.settings,
    required this.onUpdateSettings,
    required this.onResetProgress,
    required this.onClose,
  });

  final bool visible;
  final PlayerSettings settings;
  final ValueChanged<PlayerSettings> onUpdateSettings;
  final VoidCallback onResetProgress;
  final VoidCallback onClose;

  void _toggleSound(BuildContext context) {
    final audio = AudioService.maybeOf(context);
    final bool nextVal = !settings.soundEnabled;
    audio?.setSoundEnabled(nextVal);
    audio?.playClick();
    onUpdateSettings(settings.copyWith(soundEnabled: nextVal));
  }

  void _toggleHaptics(BuildContext context) {
    final audio = AudioService.maybeOf(context);
    final bool nextVal = !settings.hapticsEnabled;
    audio?.setHapticsEnabled(nextVal);
    audio?.playClick();
    onUpdateSettings(settings.copyWith(hapticsEnabled: nextVal));
  }

  void _toggleColorBlind(BuildContext context) {
    AudioService.maybeOf(context)?.playClick();
    onUpdateSettings(
      settings.copyWith(colorBlindMode: !settings.colorBlindMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: const Color(0x8C19142D),
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFFECE7FB),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEE2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.settings,
                                    size: 20,
                                    color: AppColors.coralDeep,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Game Settings',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(17),
                              onTap: () {
                                AudioService.maybeOf(context)?.playClick();
                                onClose();
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Toggles List
                      _SettingsOptionRow(
                        iconBg: const Color(0xFFCCFBF1),
                        icon: settings.soundEnabled
                            ? Icons.volume_up
                            : Icons.volume_off,
                        iconColor: AppColors.mintDeep,
                        title: 'ASMR Fluid Sounds',
                        subtitle: 'Harmonic liquid pouring & crystal chimes',
                        value: settings.soundEnabled,
                        onToggle: () => _toggleSound(context),
                      ),
                      const SizedBox(height: 12),
                      _SettingsOptionRow(
                        iconBg: const Color(0xFFEDE9FE),
                        icon: Icons.vibration,
                        iconColor: const Color(0xFF6D28D9),
                        title: 'Tactile Haptics',
                        subtitle: 'Subtle feedback on tube lift & seal',
                        value: settings.hapticsEnabled,
                        onToggle: () => _toggleHaptics(context),
                      ),
                      const SizedBox(height: 12),
                      _SettingsOptionRow(
                        iconBg: const Color(0xFFFEF3C7),
                        icon: Icons.visibility_outlined,
                        iconColor: const Color(0xFFB45309),
                        title: 'Color-Blind Symbols',
                        subtitle:
                            'Display geometric shapes (● ▲ ★ ◆) on liquids',
                        value: settings.colorBlindMode,
                        onToggle: () => _toggleColorBlind(context),
                      ),

                      const SizedBox(height: 18),

                      // Reset Progress Action
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            AudioService.maybeOf(context)?.playClick();
                            onResetProgress();
                            onClose();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Color(0xFFDC2626),
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Reset Saved Progress (Start Level 1)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Save & Resume Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () {
                            AudioService.maybeOf(context)?.playClick();
                            onClose();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.coralDeep,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Save & Resume',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsOptionRow extends StatelessWidget {
  const _SettingsOptionRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onToggle,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFECE8FB),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                activeColor: AppColors.mintDeep,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
