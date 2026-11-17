import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../theme/app_colors.dart';
import 'test_tube.dart';

/// Animated gravity stream connecting the tilted pouring source spout
/// to the rising liquid meniscus inside the target tube.
class FluidStream extends StatefulWidget {
  final double x;
  final double startY;
  final double initialEndY;
  final double finalEndY;
  final LiquidColor color;
  final Animation<double> pourPhase;
  final FluidPaletteId paletteId;

  const FluidStream({
    super.key,
    required this.x,
    required this.startY,
    required this.initialEndY,
    required this.finalEndY,
    required this.color,
    required this.pourPhase,
    this.paletteId = FluidPaletteId.paletteClassic,
  });

  @override
  State<FluidStream> createState() => _FluidStreamState();
}

class _FluidStreamState extends State<FluidStream>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePalette = paletteSchemes[widget.paletteId] ??
        paletteSchemes[FluidPaletteId.paletteClassic]!;
    final scheme =
        activePalette[widget.color] ?? activePalette[LiquidColor.coral]!;

    final double canvasHeight = math.max(
            widget.startY, math.max(widget.initialEndY, widget.finalEndY)) +
        20;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.pourPhase, _shimmerController]),
        builder: (context, _) {
          final t = widget.pourPhase.value;

          final double currentTopY = TestTube.interpolate(
            t,
            const [0, 0.92, 2.0, 2.28, 3.0],
            [
              widget.startY,
              widget.startY,
              widget.startY,
              widget.finalEndY,
              widget.finalEndY,
            ],
          );

          final double currentBottomY = TestTube.interpolate(
            t,
            const [0, 0.92, 1.1, 2.0, 2.28, 3.0],
            [
              widget.startY,
              widget.startY,
              widget.initialEndY,
              widget.finalEndY,
              widget.finalEndY,
              widget.finalEndY,
            ],
          );

          final double streamHeight =
              math.max(0.0, currentBottomY - currentTopY);

          final double streamOpacity = TestTube.interpolate(
            t,
            const [0, 0.9, 0.96, 2.24, 2.3, 3.0],
            const [0, 0, 1, 1, 0, 0],
          ).clamp(0.0, 1.0);

          final double baseWidth = TestTube.interpolate(
            t,
            const [0, 0.95, 1.15, 1.85, 2.15, 2.3],
            const [2, 9, 8.5, 7.5, 3, 1],
          );

          final double spoutOpacity = TestTube.interpolate(
            t,
            const [0, 0.92, 1.0, 1.98, 2.05, 3.0],
            const [0, 0, 1, 1, 0, 0],
          ).clamp(0.0, 1.0);

          final double splashOpacity = TestTube.interpolate(
            t,
            const [0, 1.06, 1.12, 2.1, 2.26, 3.0],
            const [0, 0, 1, 1, 0, 0],
          ).clamp(0.0, 1.0);

          final double splashScale =
              0.85 + (_shimmerController.value * 0.40); // 0.85..1.25

          return Opacity(
            opacity: streamOpacity,
            child: SizedBox(
              width: 32,
              height: canvasHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Pouring lip meniscus bead at the spout
                  Positioned(
                    left: (32 - 11) / 2,
                    top: currentTopY - 3,
                    child: Opacity(
                      opacity: spoutOpacity,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: scheme.bg,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  // Continuous Gravity Stream
                  if (streamHeight > 0)
                    Positioned(
                      left: (32 - baseWidth) / 2,
                      top: currentTopY,
                      child: Container(
                        width: baseWidth,
                        height: streamHeight,
                        decoration: BoxDecoration(
                          color: scheme.bg,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.shine.withOpacity(0.7),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 2.5,
                          height: streamHeight,
                          decoration: BoxDecoration(
                            color: scheme.meniscus.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                  // Surface Impact Crown / Splash Ripple
                  Positioned(
                    left: (32 - 22) / 2,
                    top: currentBottomY - 5,
                    child: Opacity(
                      opacity: splashOpacity,
                      child: Transform.scale(
                        scaleX: splashScale,
                        scaleY: 1.0,
                        child: Container(
                          width: 22,
                          height: 8,
                          decoration: BoxDecoration(
                            color: scheme.meniscus,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: scheme.shine,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
