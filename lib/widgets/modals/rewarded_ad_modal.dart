import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models/game_models.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

class _RewardMeta {
  const _RewardMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
}

/// Interactive 3-second fallback modal shown when native AdMob rewarded video is unavailable.
class RewardedAdModal extends StatefulWidget {
  const RewardedAdModal({
    super.key,
    required this.visible,
    required this.trigger,
    this.pendingBaseCoins = 50,
    required this.onCompleteReward,
    required this.onCancel,
  });

  final bool visible;
  final RewardedAdTrigger? trigger;
  final int pendingBaseCoins;
  final VoidCallback onCompleteReward;
  final VoidCallback onCancel;

  @override
  State<RewardedAdModal> createState() => _RewardedAdModalState();
}

class _RewardedAdModalState extends State<RewardedAdModal> {
  int _secondsLeft = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.visible && widget.trigger != null) {
      _startCountdown();
    }
  }

  @override
  void didUpdateWidget(covariant RewardedAdModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool nowActive = widget.visible && widget.trigger != null;
    final bool wasActive = oldWidget.visible && oldWidget.trigger != null;

    if (nowActive && (!wasActive || oldWidget.trigger != widget.trigger)) {
      _startCountdown();
    } else if (!nowActive && wasActive) {
      _stopCountdown();
    }
  }

  void _startCountdown() {
    _stopCountdown();
    _secondsLeft = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft <= 1) {
          _secondsLeft = 0;
          timer.cancel();
        } else {
          _secondsLeft -= 1;
        }
      });
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _stopCountdown();
    super.dispose();
  }

  _RewardMeta _metaFor(RewardedAdTrigger trigger) {
    final int tripleCoins = widget.pendingBaseCoins * 3;
    switch (trigger) {
      case RewardedAdTrigger.extraTube:
        return const _RewardMeta(
          title: 'Unlock +1 Extra Tube',
          subtitle: 'Add an empty glass vial for this level',
          icon: Icons.science_outlined,
          badge: '+1 TUBE',
        );
      case RewardedAdTrigger.refillUndo:
        return const _RewardMeta(
          title: 'Refill +3 Undo Moves',
          subtitle: 'Rewind tricky steps and rescue your board',
          icon: Icons.undo,
          badge: '+3 UNDOS',
        );
      case RewardedAdTrigger.claim3x:
        return _RewardMeta(
          title: 'Triple Victory Coins!',
          subtitle:
              'Boost your level reward from ${widget.pendingBaseCoins} to $tripleCoins Coins',
          icon: Icons.emoji_events,
          badge: '+$tripleCoins COINS',
        );
      case RewardedAdTrigger.freeCoins:
        return const _RewardMeta(
          title: 'Free Treasure Chest',
          subtitle: 'Instant bonus coins for the Vessel Shop',
          icon: Icons.card_giftcard,
          badge: '+100 COINS',
        );
    }
  }

  void _claimReward() {
    AudioService.maybeOf(context)?.playWin();
    widget.onCompleteReward();
  }

  @override
  Widget build(BuildContext context) {
    final RewardedAdTrigger? trigger = widget.trigger;
    if (!widget.visible || trigger == null) {
      return const SizedBox.shrink();
    }

    final _RewardMeta info = _metaFor(trigger);
    final bool isReady = _secondsLeft == 0;
    final double progress = ((3 - _secondsLeft) / 3).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: const Color(0xD90F0C20),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B3A),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: const Color(0xFF3B346E),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top AdMob Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videocam,
                                    size: 12,
                                    color: Color(0xFFFDE68A),
                                  ),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'GOOGLE ADMOB • REWARDED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFE2E8F0),
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isReady)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: _claimReward,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.emerald,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Reward Granted',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF312E81),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Reward in ${_secondsLeft}s',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFA5B4FC),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Video Showcase Area
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131129),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF2D2856),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    const Color(0xFFF59E0B).withOpacity(0.16),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                info.icon,
                                size: 44,
                                color: const Color(0xFFFFE66D),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                info.badge,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E1B3A),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              info.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              info.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Progress Track
                            Container(
                              width: double.infinity,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2856),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.centerLeft,
                              child: AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 250),
                                widthFactor: progress,
                                heightFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.mint,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Bottom Actions
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                AudioService.maybeOf(context)?.playClick();
                                widget.onCancel();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: isReady ? _claimReward : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isReady
                                        ? AppColors.emerald
                                        : const Color(0xFF475569),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isReady
                                              ? Icons.card_giftcard
                                              : Icons.hourglass_empty,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isReady
                                              ? 'CLAIM ${info.badge}'
                                              : 'Wait ${_secondsLeft}s...',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
