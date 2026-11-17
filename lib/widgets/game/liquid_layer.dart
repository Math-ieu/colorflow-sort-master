import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../../models/game_models.dart';
import '../../theme/app_colors.dart';

/// Individual liquid segment inside a [TestTube], with meniscus shimmer,
/// color-blind symbol watermark, and effervescent micro-bubbles.
class LiquidLayer extends StatefulWidget {
  final LiquidColor color;
  final bool isBottom;
  final bool isTop;
  final double height;
  final bool isReceiving;
  final bool isCompletedTube;
  final FluidPaletteId paletteId;
  final bool colorBlindMode;

  const LiquidLayer({
    super.key,
    required this.color,
    required this.isBottom,
    required this.isTop,
    required this.height,
    this.isReceiving = false,
    this.isCompletedTube = false,
    this.paletteId = FluidPaletteId.paletteClassic,
    this.colorBlindMode = false,
  });

  @override
  State<LiquidLayer> createState() => _LiquidLayerState();
}

class _LiquidLayerState extends State<LiquidLayer>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _bubbleController;

  bool get _isAgitated => widget.isReceiving || widget.isCompletedTube;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    if (_isAgitated) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(covariant LiquidLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasAgitated = oldWidget.isReceiving || oldWidget.isCompletedTube;
    if (_isAgitated && !wasAgitated) {
      _startAnimations();
    } else if (!_isAgitated && wasAgitated) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _waveController.repeat(reverse: true);
    _bubbleController.repeat();
  }

  void _stopAnimations() {
    _waveController.stop();
    _waveController.value = 0.0;
    _bubbleController.stop();
    _bubbleController.value = 0.0;
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  double _bubbleOpacity(double t) {
    if (t <= 0.2) return (t / 0.2) * 0.85;
    if (t <= 0.8) return 0.85;
    return ((1.0 - t) / 0.2) * 0.85;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.height <= 0) {
      return const SizedBox.shrink();
    }

    final activePalette = paletteSchemes[widget.paletteId] ??
        paletteSchemes[FluidPaletteId.paletteClassic]!;
    final scheme =
        activePalette[widget.color] ?? activePalette[LiquidColor.coral]!;

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: ClipRect(
        child: ColoredBox(
          color: scheme.bg,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Subtle bottom depth line between distinct layers
              if (!widget.isBottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: ColoredBox(
                    color: scheme.shade.withOpacity(0.3),
                  ),
                ),

              // Color-Blind Accessibility Symbol Watermark
              if (widget.colorBlindMode && widget.height >= 25)
                Center(
                  child: IgnorePointer(
                    child: Text(
                      scheme.symbol,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(25, 20, 45, 0.42),
                      ),
                    ),
                  ),
                ),

              // Top free-surface meniscus with wave agitation when pouring/sealed
              if (widget.isTop)
                Positioned(
                  top: 0,
                  left: -6,
                  right: -6,
                  height: 5,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      final waveVal = _isAgitated
                          ? (_waveController.value * 2.0 - 1.0)
                          : 0.0;
                      final waveTx = waveVal * 6.0;
                      final waveSy =
                          widget.isReceiving ? 1.35 - 0.5 * waveVal.abs() : 1.0;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(waveTx, 0.0)
                          ..scale(1.0, waveSy),
                        child: child,
                      );
                    },
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: scheme.meniscus,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.65,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Effervescent micro-bubbles when receiving liquid or completed
              if (_isAgitated)
                IgnorePointer(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      return AnimatedBuilder(
                        animation: _bubbleController,
                        builder: (context, _) {
                          final t = _bubbleController.value;
                          final opacity = _bubbleOpacity(t).clamp(0.0, 1.0);
                          final y1 = lerpDouble(
                            math.max(12.0, widget.height - 4.0),
                            2.0,
                            t,
                          )!;
                          final y2 = lerpDouble(
                            math.max(8.0, widget.height * 0.7),
                            0.0,
                            t,
                          )!;

                          return Stack(
                            children: [
                              Positioned(
                                left: maxWidth * 0.44,
                                top: y1,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.75),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: maxWidth * 0.55,
                                top: y2,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Container(
                                    width: 3.5,
                                    height: 3.5,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.75),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
