import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../logic/game_engine.dart';
import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import 'liquid_layer.dart';

/// Glass test tube widget supporting 4 vessel skins, 3 liquid palettes,
/// color-blind symbols, selection lift, hint highlight, shake, and pouring kinematics.
class TestTube extends StatefulWidget {
  static const List<double> pourKeyframes = [
    0,
    0.25,
    0.5,
    0.75,
    1,
    1.25,
    1.5,
    1.75,
    2,
    2.25,
    2.5,
    2.75,
    3,
  ];

  /// Piecewise linear interpolation with clamping at the range endpoints.
  static double interpolate(
    double value,
    List<double> inputRange,
    List<double> outputRange,
  ) {
    final len = math.min(inputRange.length, outputRange.length);
    if (len == 0) return 0.0;
    if (value <= inputRange[0]) return outputRange[0];
    if (value >= inputRange[len - 1]) return outputRange[len - 1];

    for (int i = 0; i < len - 1; i++) {
      final x0 = inputRange[i];
      final x1 = inputRange[i + 1];
      if (value >= x0 && value <= x1) {
        final y0 = outputRange[i];
        final y1 = outputRange[i + 1];
        final span = x1 - x0;
        if (span <= 0) return y1;
        final t = (value - x0) / span;
        return y0 + (y1 - y0) * t;
      }
    }
    return outputRange[len - 1];
  }

  final Tube tube;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;
  final double width;
  final double height;
  final Key? glassKey;

  // Cosmetics & Accessibility
  final VesselSkinId vesselSkin;
  final FluidPaletteId paletteId;
  final bool colorBlindMode;
  final bool isHintHighlighted;

  // Pour & Shake animation hooks
  final bool isPouringSource;
  final bool isPouringTarget;
  final int pouredCount;
  final bool isRight;
  final Animation<double>? pourPhase;
  final List<double>? txValues;
  final List<double>? tyValues;
  final List<double>? degValues;
  final LiquidColor? fillingColor;
  final Animation<double>? shakeAnim;

  const TestTube({
    super.key,
    required this.tube,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.width = 54,
    this.height = 190,
    this.glassKey,
    this.vesselSkin = VesselSkinId.tubeClassic,
    this.paletteId = FluidPaletteId.paletteClassic,
    this.colorBlindMode = false,
    this.isHintHighlighted = false,
    this.isPouringSource = false,
    this.isPouringTarget = false,
    this.pouredCount = 1,
    this.isRight = true,
    this.pourPhase,
    this.txValues,
    this.tyValues,
    this.degValues,
    this.fillingColor,
    this.shakeAnim,
  });

  @override
  State<TestTube> createState() => _TestTubeState();
}

class _TestTubeState extends State<TestTube> {
  void _handleTap() {
    if (widget.isPouringSource || widget.isPouringTarget) return;
    AudioService.maybeOf(context)?.playTap();
    widget.onTap(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    final skin = vesselSkinStyles[widget.vesselSkin] ??
        vesselSkinStyles[VesselSkinId.tubeClassic]!;
    final bool completed = !widget.isPouringSource &&
        !widget.isPouringTarget &&
        isTubeCompleted(widget.tube);

    final bool showIndicator = (widget.isSelected && !widget.isPouringSource) ||
        completed ||
        widget.isHintHighlighted;

    final double liftDy =
        (widget.isSelected && !widget.isPouringSource) ? -18.0 : 0.0;

    final double indicatorTargetDy = completed
        ? -6.0
        : (widget.isSelected && !widget.isPouringSource)
            ? -22.0
            : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: MouseRegion(
        cursor: (widget.isPouringSource || widget.isPouringTarget)
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top indicator (glowing dot when selected, sparkle when sealed, bulb when hint)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: indicatorTargetDy),
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                builder: (context, indicatorDy, child) {
                  return Transform.translate(
                    offset: Offset(0, indicatorDy),
                    child: child,
                  );
                },
                child: Opacity(
                  opacity: showIndicator ? 1.0 : 0.0,
                  child: SizedBox(
                    width: widget.width,
                    height: 16,
                    child: Center(
                      child: completed
                          ? Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gold.withOpacity(0.45),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: Colors.white,
                              ),
                            )
                          : widget.isHintHighlighted
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDE68A),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.lightbulb,
                                    size: 11,
                                    color: Color(0xFF78350F),
                                  ),
                                )
                              : Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.mint,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.mint.withOpacity(0.85),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Glass body slot with glassKey attached directly to the resting SizedBox(width, height)
              SizedBox(
                key: widget.glassKey,
                width: widget.width,
                height: widget.height,
                child: _buildTransformedGlass(skin, completed, liftDy),
              ),

              // Base drop shadow on shelf
              const SizedBox(height: 6),
              Opacity(
                opacity:
                    (widget.isSelected || widget.isPouringSource) ? 0.2 : 0.6,
                child: Transform.scale(
                  scale:
                      (widget.isSelected || widget.isPouringSource) ? 0.8 : 1.0,
                  child: Container(
                    width: widget.width * 0.85,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(140, 130, 180, 0.28),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransformedGlass(
    VesselSkinStyle skin,
    bool completed,
    double liftDy,
  ) {
    if (widget.isPouringSource &&
        widget.pourPhase != null &&
        widget.txValues != null &&
        widget.tyValues != null &&
        widget.degValues != null) {
      return AnimatedBuilder(
        animation: widget.pourPhase!,
        builder: (context, _) {
          final t = widget.pourPhase!.value;
          final tx = TestTube.interpolate(
            t,
            TestTube.pourKeyframes,
            widget.txValues!,
          );
          final ty = TestTube.interpolate(
            t,
            TestTube.pourKeyframes,
            widget.tyValues!,
          );
          final deg = TestTube.interpolate(
            t,
            TestTube.pourKeyframes,
            widget.degValues!,
          );

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(tx, ty)
              ..rotateZ(deg * math.pi / 180.0),
            child: _buildGlassAssembly(skin, completed, pourDeg: deg),
          );
        },
      );
    }

    final Widget glass = _buildGlassAssembly(skin, completed);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: liftDy),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      builder: (context, animatedDy, child) {
        if (widget.shakeAnim != null) {
          return AnimatedBuilder(
            animation: widget.shakeAnim!,
            builder: (context, innerChild) {
              return Transform.translate(
                offset: Offset(widget.shakeAnim!.value, animatedDy),
                child: innerChild,
              );
            },
            child: child,
          );
        }
        return Transform.translate(
          offset: Offset(0, animatedDy),
          child: child,
        );
      },
      child: glass,
    );
  }

  Widget _buildGlassAssembly(
    VesselSkinStyle skin,
    bool completed, {
    double pourDeg = 0.0,
  }) {
    final bool isEmpty =
        widget.tube.colors.isEmpty && widget.fillingColor == null;

    final Color lipBorderColor = completed
        ? const Color(0xFFF59E0B)
        : widget.isHintHighlighted
            ? const Color(0xFFF59E0B)
            : skin.lipBorder;

    final Color glassBorderColor = completed
        ? const Color.fromRGBO(251, 191, 36, 0.95)
        : widget.isHintHighlighted
            ? const Color(0xFFF59E0B)
            : skin.glassBorder;

    final BorderRadius outerRadius = BorderRadius.only(
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: Radius.circular(skin.bottomRadius),
      bottomRight: Radius.circular(skin.bottomRadius),
    );

    final double innerBottomRadius = math.max(0.0, skin.bottomRadius - 2.0);
    final BorderRadius innerRadius = BorderRadius.only(
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
      bottomLeft: Radius.circular(innerBottomRadius),
      bottomRight: Radius.circular(innerBottomRadius),
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glass Body Container
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: skin.glassBg,
              borderRadius: outerRadius,
              border: Border.all(
                color: glassBorderColor,
                width: 2,
              ),
              boxShadow: (widget.isSelected && !widget.isPouringSource)
                  ? AppShadows.vesselGlow()
                  : AppShadows.vesselResting,
            ),
            child: ClipRRect(
              borderRadius: innerRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Liquid Interior
                  if (widget.isPouringSource &&
                      widget.pourPhase != null &&
                      widget.degValues != null)
                    _buildPouringSourceLiquid(pourDeg)
                  else
                    _buildStaticOrReceivingLiquid(),

                  // Empty Tube Indicator
                  if (isEmpty)
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 22,
                            color: Color.fromRGBO(156, 163, 175, 0.65),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'EMPTY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color.fromRGBO(156, 163, 175, 0.7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Left Vertical Specular Shine Strip
                  Positioned(
                    top: 6,
                    left: 4,
                    bottom: 22,
                    width: 5,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: skin.shineColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Right Rim Highlight
                  Positioned(
                    top: 10,
                    right: 3,
                    bottom: 26,
                    width: 2,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.38),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Lip Rim Flange
          Positioned(
            top: -3,
            left: -3,
            width: widget.width + 6,
            height: 6,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: skin.lipBg,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: lipBorderColor,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),

          // Golden Cork Seal Cap when Tube is Completed
          if (completed)
            Positioned(
              top: -10,
              left: 2,
              width: widget.width - 4,
              height: 12,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle,
                    size: 11,
                    color: Color(0xFFFFFBEB),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaticOrReceivingLiquid() {
    final double segmentHeight = (widget.height - 10) / widget.tube.maxCapacity;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.up,
        children: [
          for (int colorIdx = 0;
              colorIdx < widget.tube.colors.length;
              colorIdx++)
            LiquidLayer(
              key: ValueKey('${widget.tube.id}-seg-$colorIdx'),
              color: widget.tube.colors[colorIdx],
              isBottom: colorIdx == 0,
              isTop: colorIdx == widget.tube.colors.length - 1 &&
                  widget.fillingColor == null,
              height: segmentHeight,
              isCompletedTube: !widget.isPouringSource &&
                  !widget.isPouringTarget &&
                  isTubeCompleted(widget.tube) &&
                  colorIdx == widget.tube.colors.length - 1,
              paletteId: widget.paletteId,
              colorBlindMode: widget.colorBlindMode,
            ),
          if (widget.isPouringTarget &&
              widget.fillingColor != null &&
              widget.pourPhase != null)
            AnimatedBuilder(
              animation: widget.pourPhase!,
              builder: (context, _) {
                final risingHeight = TestTube.interpolate(
                  widget.pourPhase!.value,
                  const [0, 1.08, 2.02, 3.0],
                  [
                    0,
                    0,
                    widget.pouredCount * segmentHeight,
                    widget.pouredCount * segmentHeight,
                  ],
                );
                if (risingHeight <= 0.1) {
                  return const SizedBox.shrink();
                }
                return LiquidLayer(
                  color: widget.fillingColor!,
                  isBottom: widget.tube.colors.isEmpty,
                  isTop: true,
                  height: risingHeight,
                  isReceiving: true,
                  paletteId: widget.paletteId,
                  colorBlindMode: widget.colorBlindMode,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPouringSourceLiquid(double deg) {
    final double segmentHeight = (widget.height - 10) / widget.tube.maxCapacity;
    final double innerWidth = widget.width - 4;
    final double innerHeight = widget.height - 4;

    final int initialCount = widget.tube.colors.length;
    final int remainingCount = math.max(0, initialCount - widget.pouredCount);
    final double restTopY = innerHeight - initialCount * segmentHeight;
    final double afterPourTopY = innerHeight - remainingCount * segmentHeight;

    final double t = widget.pourPhase!.value;

    final double surfaceAnchorX = TestTube.interpolate(
      t,
      const [0, 0.85, 1, 2, 2.15, 3],
      [
        innerWidth / 2,
        widget.isRight ? innerWidth - 6 : 6,
        widget.isRight ? innerWidth - 4 : 4,
        widget.isRight ? innerWidth - 4 : 4,
        widget.isRight ? innerWidth - 6 : 6,
        innerWidth / 2,
      ],
    );

    final double surfaceAnchorY = TestTube.interpolate(
      t,
      const [0, 0.85, 1, 2, 3],
      [restTopY, 10, 5, 5, afterPourTopY],
    );

    return Positioned(
      left: surfaceAnchorX - 130,
      top: surfaceAnchorY,
      width: 260,
      child: Transform.rotate(
        angle: -deg * math.pi / 180.0,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int colorIdx = initialCount - 1; colorIdx >= 0; colorIdx--)
              _buildPouringSegment(
                colorIdx: colorIdx,
                initialCount: initialCount,
                segmentHeight: segmentHeight,
                t: t,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPouringSegment({
    required int colorIdx,
    required int initialCount,
    required double segmentHeight,
    required double t,
  }) {
    final color = widget.tube.colors[colorIdx];
    final bool isDrainingSegment =
        colorIdx >= initialCount - widget.pouredCount;
    final bool isBottomSegment = colorIdx == 0;
    final bool isTopRemaining =
        colorIdx == initialCount - widget.pouredCount - 1;
    final bool isVeryTop = colorIdx == initialCount - 1;

    final double layerHeight = isDrainingSegment
        ? TestTube.interpolate(
            t,
            const [0, 1, 2, 3],
            [segmentHeight, segmentHeight * 0.62, 0, 0],
          )
        : TestTube.interpolate(
            t,
            const [0, 1, 2, 3],
            [
              segmentHeight,
              segmentHeight * 0.65 + (isBottomSegment ? 16 : 0),
              segmentHeight * 0.52 + (isBottomSegment ? 18 : 0),
              segmentHeight,
            ],
          );

    if (layerHeight <= 0.1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      key: ValueKey('${widget.tube.id}-pour-seg-$colorIdx'),
      width: 260,
      height: layerHeight,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minWidth: 260,
          maxWidth: 260,
          minHeight: segmentHeight + 20,
          maxHeight: segmentHeight + 20,
          child: LiquidLayer(
            color: color,
            isBottom: isBottomSegment,
            isTop: isVeryTop || isTopRemaining,
            height: segmentHeight + 20,
            isReceiving: isVeryTop,
            paletteId: widget.paletteId,
            colorBlindMode: widget.colorBlindMode,
          ),
        ),
      ),
    );
  }
}
