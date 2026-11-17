import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';

/// Tactile pill badge displaying the player's current coin balance with a 3D coin icon.
class CoinBadge extends StatelessWidget {
  final int amount;

  const CoinBadge({
    super.key,
    required this.amount,
  });

  String _formatAmount(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return value < 0 ? '-${buffer.toString()}' : buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: const Color(0xFFEFEAFC),
          width: 1,
        ),
        boxShadow: AppShadows.pillBadge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 6),
            decoration: const BoxDecoration(
              color: AppColors.goldShade,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                '\$',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF78350F),
                  height: 1.0,
                ),
              ),
            ),
          ),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
