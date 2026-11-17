import 'package:flutter/material.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

/// Interactive hint & deadlock status banner beneath the booster deck.
class HintBanner extends StatelessWidget {
  final String message;
  final bool isDeadlocked;
  final VoidCallback? onRequestHint;

  const HintBanner({
    super.key,
    this.message = 'Tap any tube to lift and pour matching color!',
    this.isDeadlocked = false,
    this.onRequestHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onRequestHint == null
            ? null
            : () {
                AudioService.maybeOf(context)?.playClick();
                onRequestHint!();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDeadlocked
                ? const Color(0xFFFEF3C7)
                : Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDeadlocked
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFFECE7FB),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDeadlocked
                    ? Icons.warning_amber_rounded
                    : Icons.lightbulb_outline,
                size: 16,
                color:
                    isDeadlocked ? const Color(0xFFB45309) : AppColors.mintDeep,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isDeadlocked ? FontWeight.w800 : FontWeight.w700,
                    color: isDeadlocked
                        ? const Color(0xFF92400E)
                        : const Color(0xFF37324B),
                  ),
                ),
              ),
              if (!isDeadlocked && onRequestHint != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'HINT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mintDeep,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
              if (isDeadlocked) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.restore,
                  size: 16,
                  color: Color(0xFFB45309),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
