import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';
import '../common/tactile_3d_button.dart';

class _ConfettiPiece {
  const _ConfettiPiece({
    required this.leftFraction,
    required this.color,
    required this.delayMs,
    required this.size,
  });

  final double leftFraction;
  final Color color;
  final int delayMs;
  final double size;
}

const List<_ConfettiPiece> _confettiPieces = [
  _ConfettiPiece(
      leftFraction: 0.08, color: Color(0xFFFF6B6B), delayMs: 0, size: 9),
  _ConfettiPiece(
      leftFraction: 0.18, color: Color(0xFF4ECDC4), delayMs: 120, size: 7),
  _ConfettiPiece(
      leftFraction: 0.28, color: Color(0xFFFFE66D), delayMs: 60, size: 10),
  _ConfettiPiece(
      leftFraction: 0.40, color: Color(0xFF9B5DE5), delayMs: 180, size: 8),
  _ConfettiPiece(
      leftFraction: 0.52, color: Color(0xFF10B981), delayMs: 40, size: 9),
  _ConfettiPiece(
      leftFraction: 0.64, color: Color(0xFFF59E0B), delayMs: 150, size: 8),
  _ConfettiPiece(
      leftFraction: 0.76, color: Color(0xFFFF6B6B), delayMs: 90, size: 10),
  _ConfettiPiece(
      leftFraction: 0.88, color: Color(0xFF4ECDC4), delayMs: 30, size: 7),
];

/// Victory modal displayed when all tubes in a level are sorted.
class LevelCompletedModal extends StatefulWidget {
  const LevelCompletedModal({
    super.key,
    required this.visible,
    required this.levelNumber,
    required this.moves,
    required this.timeFormatted,
    this.starsEarned = 3,
    this.coinsEarned = 50,
    required this.onClaim3x,
    required this.onNextLevel,
  });

  final bool visible;
  final int levelNumber;
  final int moves;
  final String timeFormatted;
  final int starsEarned;
  final int coinsEarned;
  final VoidCallback onClaim3x;
  final VoidCallback onNextLevel;

  @override
  State<LevelCompletedModal> createState() => _LevelCompletedModalState();
}

class _LevelCompletedModalState extends State<LevelCompletedModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.visible) {
      _confettiController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LevelCompletedModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _confettiController
        ..reset()
        ..repeat();
    } else if (!widget.visible && oldWidget.visible) {
      _confettiController.stop();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox.shrink();
    }

    final int stars = widget.starsEarned;
    final String centerBadge = stars == 3
        ? 'PERFECT!'
        : stars == 2
            ? 'GREAT!'
            : 'CLEARED!';

    return Positioned.fill(
      child: Stack(
        children: [
          // Blurred translucent lavender backdrop
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: const Color(0xB8EBE9F8),
                ),
              ),
            ),
          ),

          // Celebratory Animated Confetti Rain
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, _) {
                      return Stack(
                        children: [
                          for (int idx = 0; idx < _confettiPieces.length; idx++)
                            _buildConfettiItem(
                              idx: idx,
                              piece: _confettiPieces[idx],
                              maxWidth: constraints.maxWidth,
                              maxHeight: constraints.maxHeight,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Centered Modal Card + Tip
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 64, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 390),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.95),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x2E1E1E2E),
                                blurRadius: 28,
                                offset: Offset(0, 16),
                              ),
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              const Text(
                                'STAGE CLEARED',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.mintDeep,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'LEVEL ${widget.levelNumber}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                stars == 3
                                    ? 'Flawless sorting mastery!'
                                    : 'Awesome puzzle completed!',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF584140),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Stats Container
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F6FD),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFE8E5F8),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                margin: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFFDE68A),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xFFD97706),
                                                    width: 2,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  '\$',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF78350F),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Coins Earned',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                    Text(
                                                      '+${widget.coinsEarned}',
                                                      style: const TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            AppColors.darkText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFCCFBF1),
                                            borderRadius:
                                                BorderRadius.circular(9999),
                                          ),
                                          child: Text(
                                            stars == 3
                                                ? '3★ Bonus +15'
                                                : 'Bonus +10',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.mintDeep,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      color: const Color(0xFFEBE7F7),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: Icon(
                                                  Icons.shuffle,
                                                  size: 18,
                                                  color: AppColors.mintDeep,
                                                ),
                                              ),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Moves',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                    Text(
                                                      '${widget.moves} Steps',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            AppColors.darkText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 28,
                                          color: const Color(0xFFEBE7F7),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: Icon(
                                                  Icons.timer_outlined,
                                                  size: 18,
                                                  color: AppColors.coralDeep,
                                                ),
                                              ),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Time',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF6B7280),
                                                      ),
                                                    ),
                                                    Text(
                                                      widget.timeFormatted,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            AppColors.darkText,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              // CTA 1: Tactile 3D Emerald Button "WATCH VIDEO - Claim 3x Coins"
                              Tactile3DButton(
                                onPressed: widget.onClaim3x,
                                title: 'WATCH VIDEO',
                                subtitle: 'Claim 3x Coins',
                                color: const Color(0xFF22C55E),
                                shadeColor: const Color(0xFF15803D),
                                height: 60,
                                extrusionDepth: 6,
                                icon: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 18,
                                    color: Color(0xFF22C55E),
                                  ),
                                ),
                                rightBadge: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE68A),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '\$',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF78350F),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '+${widget.coinsEarned * 3}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF78350F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // CTA 2: Secondary Next Level button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(9999),
                                  onTap: () {
                                    AudioService.maybeOf(context)?.playClick();
                                    widget.onNextLevel();
                                  },
                                  child: Ink(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2EFFE),
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(
                                        color: const Color(0xFFE4DFFA),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Next Level (+${widget.coinsEarned} Coins)',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF28233C),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: Color(0xFF28233C),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Top 3D Golden Star Crest Overflow
                        Positioned(
                          top: -50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SmallCrestStar(
                                label: 'SUPER',
                                active: stars >= 1,
                              ),
                              _CenterCrestStar(
                                label: centerBadge,
                                active: stars >= 3,
                              ),
                              _SmallCrestStar(
                                label: 'CLEAN',
                                active: stars >= 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Helpful Hint beneath the modal
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 15,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Tip: Empty vials give you room to maneuver pure colors!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF655E7A),
                          ),
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
    );
  }

  Widget _buildConfettiItem({
    required int idx,
    required _ConfettiPiece piece,
    required double maxWidth,
    required double maxHeight,
  }) {
    final double phaseOffset = piece.delayMs / 2400.0;
    final double t = (_confettiController.value + phaseOffset) % 1.0;
    final double startY = -40.0 - (idx % 3) * 35.0;
    final double endY = math.max(520.0, maxHeight) + (idx % 2) * 60.0;
    final double y = startY + (endY - startY) * t;
    final double angle = (idx.isEven ? 1.0 : -1.0) * t * 2.0 * math.pi;

    return Positioned(
      left: piece.leftFraction * maxWidth,
      top: y,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: piece.size,
          height: piece.size * 1.6,
          decoration: BoxDecoration(
            color: piece.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _SmallCrestStar extends StatelessWidget {
  const _SmallCrestStar({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFFD97706) : const Color(0xFFE5E7EB),
              border: Border.all(
                color:
                    active ? const Color(0xFFFBBF24) : const Color(0xFFD1D5DB),
                width: 4,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD97706).withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.star,
              size: 26,
              color: active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF78350F),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterCrestStar extends StatelessWidget {
  const _CenterCrestStar({
    required this.label,
    required this.active,
  });

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, right: 6, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? const Color(0xFFD97706) : const Color(0xFFE5E7EB),
              border: Border.all(
                color:
                    active ? const Color(0xFFFDE68A) : const Color(0xFFD1D5DB),
                width: 5,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD97706).withOpacity(0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.star,
              size: 40,
              color: active ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: const Color(0xFFD97706),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF78350F),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
