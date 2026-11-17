import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

/// Modal displaying player avatar picker, editable nickname, and lifetime stats.
class ProfileModal extends StatefulWidget {
  const ProfileModal({
    super.key,
    required this.visible,
    required this.profile,
    required this.maxLevel,
    required this.totalStars,
    required this.coins,
    required this.onUpdateProfile,
    required this.onClose,
  });

  final bool visible;
  final PlayerProfile profile;
  final int maxLevel;
  final int totalStars;
  final int coins;
  final ValueChanged<PlayerProfile> onUpdateProfile;
  final VoidCallback onClose;

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late final TextEditingController _nameController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _selectedAvatar = widget.profile.avatarIcon;
  }

  @override
  void didUpdateWidget(covariant ProfileModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((!oldWidget.visible && widget.visible) ||
        oldWidget.profile != widget.profile) {
      _nameController.text = widget.profile.name;
      _selectedAvatar = widget.profile.avatarIcon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    AudioService.maybeOf(context)?.playClick();
    final String trimmed = _nameController.text.trim();
    widget.onUpdateProfile(
      widget.profile.copyWith(
        name: trimmed.isEmpty ? 'FlowMaster' : trimmed,
        avatarIcon: _selectedAvatar,
      ),
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final AvatarOption activeAvatar = avatarOptionFor(_selectedAvatar);

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
                          const Expanded(
                            child: Text(
                              'Player Profile',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(17),
                              onTap: () {
                                AudioService.maybeOf(context)?.playClick();
                                widget.onClose();
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

                      const SizedBox(height: 12),

                      // Avatar Showcase
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeAvatar.color.withOpacity(0.1),
                          border: Border.all(
                            color: activeAvatar.color,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          activeAvatar.icon,
                          size: 36,
                          color: activeAvatar.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'LEVEL ${widget.maxLevel} • ${widget.totalStars} ★ FLOW MASTER',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.mintDeep,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Avatar Picker (6 options)
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: playerAvatarOptions.map((av) {
                          final bool isSel = av.id == _selectedAvatar;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                AudioService.maybeOf(context)?.playClick();
                                setState(() {
                                  _selectedAvatar = av.id;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSel
                                      ? av.color.withOpacity(0.1)
                                      : const Color(0xFFF8F7FC),
                                  border: Border.all(
                                    color: isSel
                                        ? av.color
                                        : const Color(0xFFE5E7EB),
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  av.icon,
                                  size: 18,
                                  color: av.color,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Editable Player Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DISPLAY NAME',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _nameController,
                            maxLength: 18,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'Enter nickname',
                              filled: true,
                              fillColor: const Color(0xFFF8F7FC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E0F2),
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.mintDeep,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Live 2x2 Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.water_drop,
                              iconColor: AppColors.coralDeep,
                              value: '${widget.maxLevel}',
                              label: 'Max Level',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.star,
                              iconColor: const Color(0xFFF59E0B),
                              value: '${widget.totalStars}',
                              label: 'Total Stars',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.emoji_events,
                              iconColor: AppColors.mintDeep,
                              value: '${widget.profile.flawlessWins}',
                              label: '3★ Clears',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.monetization_on,
                              iconColor: const Color(0xFFD97706),
                              value: '${widget.coins}',
                              label: 'Coins',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Save Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: _handleSave,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.mintDeep,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Save Profile',
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFECE8FB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
