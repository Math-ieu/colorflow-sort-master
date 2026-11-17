import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';
import '../common/tactile_3d_button.dart';

/// Booster deck below the arena containing Undo (+3 Undos ad refill when 0),
/// +1 Extra Tube (Rewarded Ad), and Restart controls.
class BoosterDeck extends StatelessWidget {
  final int undoCount;
  final bool extraTubeUsed;
  final VoidCallback onUndo;
  final VoidCallback? onRefillUndoAd;
  final VoidCallback onAddTube;
  final VoidCallback onRestart;

  const BoosterDeck({
    super.key,
    required this.undoCount,
    this.extraTubeUsed = false,
    required this.onUndo,
    this.onRefillUndoAd,
    required this.onAddTube,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUndos = undoCount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Undo Booster (or Watch Ad for +3 Undos when empty)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundBoosterButton(
                  icon: Icons.undo,
                  iconSize: 24,
                  iconColor:
                      hasUndos ? AppColors.mintDeep : const Color(0xFFB45309),
                  backgroundColor:
                      hasUndos ? Colors.white : const Color(0xFFFFFBEB),
                  borderColor: hasUndos
                      ? const Color(0xFFECE7FA)
                      : const Color(0xFFF59E0B),
                  onTap: () {
                    AudioService.maybeOf(context)?.playClick();
                    if (hasUndos) {
                      onUndo();
                    } else {
                      onRefillUndoAd?.call();
                    }
                  },
                  badge: hasUndos
                      ? Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.mintDeep,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$undoCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        )
                      : Positioned(
                          top: -4,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'AD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasUndos ? 'Undo' : '+3 Undos',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4B3F3E),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // 2. +1 Tube (AD) Tactile 3D Button (Max 1 per level)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tactile3DButton(
                  onPressed: () {
                    if (!extraTubeUsed) {
                      onAddTube();
                    }
                  },
                  disabled: extraTubeUsed,
                  color: extraTubeUsed
                      ? const Color(0xFFD1D5DB)
                      : const Color(0xFFC6A728),
                  shadeColor: extraTubeUsed
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF8A7214),
                  width: 156,
                  height: 58,
                  extrusionDepth: extraTubeUsed ? 3 : 6,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          extraTubeUsed
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          size: 22,
                          color: extraTubeUsed
                              ? const Color(0xFF4B5563)
                              : const Color(0xFF211B00),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tube',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: extraTubeUsed
                                ? const Color(0xFF4B5563)
                                : const Color(0xFF211B00),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: extraTubeUsed
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF382E00),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            extraTubeUsed ? '1/1' : 'AD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: extraTubeUsed
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFFFFE36A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  extraTubeUsed ? 'Max 1 / Level' : '+1 Slot',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6D5E00),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            // 3. Restart Booster
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundBoosterButton(
                  icon: Icons.refresh,
                  iconSize: 22,
                  iconColor: AppColors.darkText,
                  backgroundColor: Colors.white,
                  borderColor: const Color(0xFFECE7FA),
                  onTap: () {
                    AudioService.maybeOf(context)?.playClick();
                    onRestart();
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4B3F3E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundBoosterButton extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final Widget? badge;

  const _RoundBoosterButton({
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    this.badge,
  });

  @override
  State<_RoundBoosterButton> createState() => _RoundBoosterButtonState();
}

class _RoundBoosterButtonState extends State<_RoundBoosterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Opacity(
          opacity: _pressed ? 0.8 : 1.0,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A1E1E2E),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: widget.iconColor,
                  ),
                ),
                if (widget.badge != null) widget.badge!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
