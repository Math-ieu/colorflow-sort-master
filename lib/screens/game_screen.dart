import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/game_engine.dart';
import '../models/game_models.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../theme/app_colors.dart';
import '../widgets/game/booster_deck.dart';
import '../widgets/game/fluid_stream.dart';
import '../widgets/game/hint_banner.dart';
import '../widgets/game/test_tube.dart';
import '../widgets/game/top_hud.dart';
import '../widgets/modals/level_completed_modal.dart';
import '../widgets/navigation/ad_banner_widget.dart';
import '../widgets/navigation/bottom_nav_bar.dart';

class _PouringState {
  const _PouringState({
    required this.sourceIndex,
    required this.targetIndex,
    required this.color,
    required this.pouredCount,
    required this.isRight,
    required this.sourceOuterX,
    required this.sourceOuterY,
    required this.streamX,
    required this.streamStartY,
    required this.streamInitialEndY,
    required this.streamFinalEndY,
    required this.txValues,
    required this.tyValues,
    required this.degValues,
  });

  final int sourceIndex;
  final int targetIndex;
  final LiquidColor color;
  final int pouredCount;
  final bool isRight;
  final double sourceOuterX;
  final double sourceOuterY;
  final double streamX;
  final double streamStartY;
  final double streamInitialEndY;
  final double streamFinalEndY;
  final List<double> txValues;
  final List<double> tyValues;
  final List<double> degValues;
}

/// Primary gameplay screen with tube arena, physics pouring stream, boosters,
/// interactive hint banner, banner ad, and level victory modal.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const double _tubeWidth = 54.0;
  static const double _tubeHeight = 190.0;
  static const double _tubeHorizontalPadding = 5.0;
  static const double _tubeTopIndicatorOffset = 18.0;

  late final AnimationController _pourController;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnim;

  final GlobalKey _arenaKey = GlobalKey();
  final List<GlobalKey> _tubeKeys = [];

  bool _isAnimating = false;
  _PouringState? _pouringState;

  @override
  void initState() {
    super.initState();
    _pourController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 3.0,
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -9.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -6.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 45),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _pourController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _syncTubeKeys(int count) {
    while (_tubeKeys.length < count) {
      _tubeKeys.add(GlobalKey());
    }
    if (_tubeKeys.length > count) {
      _tubeKeys.removeRange(count, _tubeKeys.length);
    }
  }

  Offset? _measureGlassInArena(int index) {
    if (index < 0 || index >= _tubeKeys.length) return null;
    final arenaObj = _arenaKey.currentContext?.findRenderObject();
    final glassObj = _tubeKeys[index].currentContext?.findRenderObject();
    if (arenaObj is! RenderBox || glassObj is! RenderBox) return null;
    if (!arenaObj.hasSize || !glassObj.hasSize) return null;
    return glassObj.localToGlobal(Offset.zero, ancestor: arenaObj);
  }

  Future<void> _triggerShake(GameProvider provider) async {
    try {
      await _shakeController.forward(from: 0.0).orCancel;
    } on TickerCanceled {
      return;
    }
    if (mounted) {
      provider.clearShake();
    }
  }

  Future<void> _onTubeTapped(GameProvider provider, int index) async {
    if (provider.isCompleted || _isAnimating) return;

    final result = provider.handleTubeTap(index);
    if (result.outcome == TapOutcome.invalid) {
      await _triggerShake(provider);
      return;
    }

    if (result.outcome == TapOutcome.readyToPour && result.pourPlan != null) {
      await _runPourAnimation(provider, result.pourPlan!);
    }
  }

  Future<void> _runPourAnimation(GameProvider provider, PourPlan plan) async {
    final int sourceIdx = plan.sourceIndex;
    final int targetIdx = plan.targetIndex;
    final int pouredCount = plan.preview.pouredCount;
    final LiquidColor colorPoured = plan.preview.colorPoured;

    if (sourceIdx < 0 ||
        sourceIdx >= provider.tubes.length ||
        targetIdx < 0 ||
        targetIdx >= provider.tubes.length) {
      return;
    }

    final Tube targetTube = provider.tubes[targetIdx];

    final Offset sourcePos = _measureGlassInArena(sourceIdx) ??
        Offset(sourceIdx * 64.0 + _tubeHorizontalPadding, 36.0);
    final Offset targetPos = _measureGlassInArena(targetIdx) ??
        Offset(targetIdx * 64.0 + _tubeHorizontalPadding, 36.0);

    final double dx = targetPos.dx - sourcePos.dx;
    final bool isRight = dx >= 0;
    final double segmentHeight = (_tubeHeight - 10.0) / targetTube.maxCapacity;

    final double sourceCenterX = sourcePos.dx + _tubeWidth / 2.0;
    final double sourceCenterY = sourcePos.dy + _tubeHeight / 2.0;

    final double lx = isRight ? 25.0 : -25.0;
    const double ly = -92.0;

    final double pourLipX = targetPos.dx + _tubeWidth / 2.0;
    final double pourLipY = targetPos.dy - 8.0;

    final double startLipX = sourceCenterX + lx;
    final double startLipY = sourceCenterY - 18.0 + ly;
    final double restLipX = sourceCenterX + lx;
    final double restLipY = sourceCenterY + ly;

    final List<double> txValues = [];
    final List<double> tyValues = [];
    final List<double> degValues = [];

    for (final double s in TestTube.pourKeyframes) {
      double deg = 0.0;
      double lipX = restLipX;
      double lipY = restLipY;

      if (s <= 1.0) {
        final double u = s;
        final double ease = u * u * (3.0 - 2.0 * u);
        deg = (isRight ? 1.0 : -1.0) * 58.0 * ease;
        lipX = startLipX + (pourLipX - startLipX) * ease;
        lipY = startLipY +
            (pourLipY - startLipY) * ease -
            18.0 * math.sin(math.pi * u);
      } else if (s <= 2.0) {
        final double u = s - 1.0;
        deg = (isRight ? 1.0 : -1.0) * (58.0 + 20.0 * u);
        lipX = pourLipX;
        lipY = pourLipY;
      } else {
        final double u = s - 2.0;
        final double ease = u * u * (3.0 - 2.0 * u);
        deg = (isRight ? 1.0 : -1.0) * 78.0 * (1.0 - ease);
        lipX = pourLipX + (restLipX - pourLipX) * ease;
        lipY = pourLipY +
            (restLipY - pourLipY) * ease -
            12.0 * math.sin(math.pi * u);
      }

      final double rad = deg * math.pi / 180.0;
      final double rotLipX = lx * math.cos(rad) - ly * math.sin(rad);
      final double rotLipY = lx * math.sin(rad) + ly * math.cos(rad);

      txValues.add(lipX - sourceCenterX - rotLipX);
      tyValues.add(lipY - sourceCenterY - rotLipY);
      degValues.add(deg);
    }

    final double targetInnerBottomY = targetPos.dy + _tubeHeight - 2.0;
    final int initialTargetCount = targetTube.colors.length;
    final int finalTargetCount = initialTargetCount + pouredCount;

    final double streamInitialEndY =
        targetInnerBottomY - initialTargetCount * segmentHeight;
    final double streamFinalEndY =
        targetInnerBottomY - finalTargetCount * segmentHeight;

    _pourController.value = 0.0;

    setState(() {
      _isAnimating = true;
      _pouringState = _PouringState(
        sourceIndex: sourceIdx,
        targetIndex: targetIdx,
        color: colorPoured,
        pouredCount: pouredCount,
        isRight: isRight,
        sourceOuterX: sourcePos.dx - _tubeHorizontalPadding,
        sourceOuterY: sourcePos.dy - _tubeTopIndicatorOffset,
        streamX: pourLipX,
        streamStartY: pourLipY,
        streamInitialEndY: streamInitialEndY,
        streamFinalEndY: streamFinalEndY,
        txValues: txValues,
        tyValues: tyValues,
        degValues: degValues,
      );
    });

    final int pourDurationMs = 380 + (pouredCount - 1) * 110;

    try {
      await _pourController
          .animateTo(
            1.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          )
          .orCancel;

      if (!mounted) return;
      AudioService.maybeOf(context)?.playPour();

      await _pourController
          .animateTo(
            2.0,
            duration: Duration(milliseconds: pourDurationMs),
            curve: Curves.easeInOutQuad,
          )
          .orCancel;

      if (!mounted) return;
      await _pourController
          .animateTo(
            3.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
          )
          .orCancel;
    } on TickerCanceled {
      return;
    }

    if (!mounted) return;
    setState(() {
      _pouringState = null;
      _isAnimating = false;
    });
    provider.commitPour(sourceIdx, targetIdx);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final tubes = provider.tubes;
    _syncTubeKeys(tubes.length);

    final _PouringState? activePour = _pouringState;

    return Container(
      color: AppColors.canvas,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top HUD
                TopHUD(
                  levelNumber: provider.levelData.levelNumber,
                  difficulty: provider.levelData.difficulty.label,
                  milestoneText: provider.liveMilestoneText,
                  coins: provider.coins,
                  isSoundEnabled: provider.settings.soundEnabled,
                  onToggleSound: provider.toggleSound,
                  onOpenSettings: provider.openSettings,
                  onOpenProfile: provider.openProfile,
                ),

                // Scrollable Arena, Booster Deck, Hint Banner & Ad Banner
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, viewportConstraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: math.max(
                                0.0, viewportConstraints.maxHeight - 6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Central Arena with Test Tubes, Shelf & Fluid Stream
                              Container(
                                width: double.infinity,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                constraints:
                                    const BoxConstraints(minHeight: 270),
                                child: Stack(
                                  key: _arenaKey,
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Glass Shelf Bar behind tube bases
                                    Positioned(
                                      bottom: 2,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: FractionallySizedBox(
                                          widthFactor: 0.92,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 420,
                                            ),
                                            child: Container(
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDFDCF5),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFFCCC8EE),
                                                  width: 1,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x141E1E3C),
                                                    blurRadius: 16,
                                                    offset: Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                height: 3,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Resting & Target Test Tubes
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: 230,
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Wrap(
                                            spacing: 0,
                                            runSpacing: 14,
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.end,
                                            children: List.generate(
                                              tubes.length,
                                              (idx) {
                                                final tube = tubes[idx];
                                                final bool isSource =
                                                    activePour?.sourceIndex ==
                                                        idx;
                                                final bool isTarget =
                                                    activePour?.targetIndex ==
                                                        idx;
                                                final bool isShaken =
                                                    provider.shakenTubeIndex ==
                                                        idx;
                                                final bool isHint = provider
                                                    .hintIndices
                                                    .contains(idx);

                                                final Widget tubeWidget =
                                                    TestTube(
                                                  key: ValueKey(tube.id),
                                                  tube: tube,
                                                  index: idx,
                                                  isSelected: provider
                                                          .selectedTubeIndex ==
                                                      idx,
                                                  onTap: (tappedIdx) =>
                                                      _onTubeTapped(
                                                    provider,
                                                    tappedIdx,
                                                  ),
                                                  width: _tubeWidth,
                                                  height: _tubeHeight,
                                                  glassKey: _tubeKeys[idx],
                                                  vesselSkin: provider
                                                      .equippedVesselSkin,
                                                  paletteId:
                                                      provider.equippedPalette,
                                                  colorBlindMode: provider
                                                      .settings.colorBlindMode,
                                                  isHintHighlighted: isHint,
                                                  isPouringTarget: isTarget,
                                                  pouredCount:
                                                      activePour?.pouredCount ??
                                                          1,
                                                  isRight:
                                                      activePour?.isRight ??
                                                          true,
                                                  pourPhase: isTarget
                                                      ? _pourController
                                                      : null,
                                                  fillingColor: isTarget &&
                                                          activePour != null
                                                      ? activePour.color
                                                      : null,
                                                  shakeAnim: isShaken
                                                      ? _shakeAnim
                                                      : null,
                                                );

                                                if (isSource) {
                                                  return Opacity(
                                                    opacity: 0.0,
                                                    child: IgnorePointer(
                                                      child: tubeWidget,
                                                    ),
                                                  );
                                                }
                                                return tubeWidget;
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Pouring Liquid Stream
                                    if (activePour != null)
                                      Positioned(
                                        left: activePour.streamX - 16.0,
                                        top: 0,
                                        child: FluidStream(
                                          x: activePour.streamX,
                                          startY: activePour.streamStartY,
                                          initialEndY:
                                              activePour.streamInitialEndY,
                                          finalEndY: activePour.streamFinalEndY,
                                          color: activePour.color,
                                          pourPhase: _pourController,
                                          paletteId: provider.equippedPalette,
                                        ),
                                      ),

                                    // Active Pouring Source Tube Overlay (always above other tubes)
                                    if (activePour != null &&
                                        activePour.sourceIndex < tubes.length)
                                      Positioned(
                                        left: activePour.sourceOuterX,
                                        top: activePour.sourceOuterY,
                                        child: TestTube(
                                          tube: tubes[activePour.sourceIndex],
                                          index: activePour.sourceIndex,
                                          isSelected: false,
                                          onTap: (_) {},
                                          width: _tubeWidth,
                                          height: _tubeHeight,
                                          vesselSkin:
                                              provider.equippedVesselSkin,
                                          paletteId: provider.equippedPalette,
                                          colorBlindMode:
                                              provider.settings.colorBlindMode,
                                          isPouringSource: true,
                                          pouredCount: activePour.pouredCount,
                                          isRight: activePour.isRight,
                                          pourPhase: _pourController,
                                          txValues: activePour.txValues,
                                          tyValues: activePour.tyValues,
                                          degValues: activePour.degValues,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Booster Deck
                              BoosterDeck(
                                undoCount: provider.undoCount,
                                extraTubeUsed: provider.extraTubeUsed,
                                onUndo: () {
                                  if (_isAnimating) return;
                                  provider.undo();
                                },
                                onRefillUndoAd: () {
                                  if (_isAnimating) return;
                                  provider.requestRewardedAd(
                                    RewardedAdTrigger.refillUndo,
                                  );
                                },
                                onAddTube: () {
                                  if (_isAnimating ||
                                      provider.isCompleted ||
                                      provider.extraTubeUsed) {
                                    return;
                                  }
                                  provider.requestRewardedAd(
                                    RewardedAdTrigger.extraTube,
                                  );
                                },
                                onRestart: () {
                                  if (_isAnimating) return;
                                  provider.restartLevel();
                                },
                              ),

                              // Dynamic Interactive Hint & Deadlock Banner
                              HintBanner(
                                message: provider.hintMessage,
                                isDeadlocked: provider.isDeadlocked,
                                onRequestHint: () {
                                  if (_isAnimating || provider.isCompleted) {
                                    return;
                                  }
                                  provider.requestHint();
                                },
                              ),

                              // Adaptive Ad Banner
                              const AdBannerWidget(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation
                BottomNavBar(
                  activeTab: provider.activeTab,
                  onSelectTab: provider.selectTab,
                ),
              ],
            ),
          ),

          // Level Completed Victory Modal
          LevelCompletedModal(
            visible: provider.isCompleted,
            levelNumber: provider.levelData.levelNumber,
            moves: provider.moves,
            timeFormatted: formatTime(provider.timeSeconds),
            starsEarned: provider.starsEarned,
            coinsEarned: provider.baseCoinsEarned,
            onClaim3x: () => provider.requestRewardedAd(
              RewardedAdTrigger.claim3x,
              winStars: provider.starsEarned,
              winBaseCoins: provider.baseCoinsEarned,
            ),
            onNextLevel: provider.completeNextLevel1x,
          ),
        ],
      ),
    );
  }
}
