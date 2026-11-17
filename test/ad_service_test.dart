import 'dart:async';

import 'package:colorflow_sort_master/models/game_models.dart';
import 'package:colorflow_sort_master/providers/game_provider.dart';
import 'package:colorflow_sort_master/services/ad_service.dart';
import 'package:colorflow_sort_master/services/audio_service.dart';
import 'package:colorflow_sort_master/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdService Unit & GameProvider Integration Tests', () {
    test(
      'uses Google official test IDs in non-release mode and detects test binding safely',
      () async {
        final adService = AdService();
        addTearDown(adService.dispose);

        expect(kReleaseMode, isFalse);
        expect(adService.isUsingTestIds, isTrue);
        expect(adService.isRealAdsActive, isFalse);
        expect(
          adService.bannerAdUnitId,
          startsWith('ca-app-pub-3940256099942544/'),
        );
        expect(
          adService.rewardedAdUnitId,
          startsWith('ca-app-pub-3940256099942544/'),
        );
        expect(
          adService.interstitialAdUnitId,
          startsWith('ca-app-pub-3940256099942544/'),
        );

        await adService.initialize();
        expect(adService.isInitialized, isTrue);
        expect(
          adService.createBannerAd(listener: const BannerAdListener()),
          isNull,
        );
      },
    );

    test(
      'showRewardedAd triggers fallback on inactive real ads and respects rewardedOverride',
      () async {
        // Fallback when no override and real ads inactive
        final fallbackService = AdService(enableRealAds: false);
        addTearDown(fallbackService.dispose);

        bool rewarded = false;
        bool failed = false;
        final fallbackResult = await fallbackService.showRewardedAd(
          onUserEarnedReward: () => rewarded = true,
          onAdFailedToLoad: () => failed = true,
        );
        expect(fallbackResult, isFalse);
        expect(rewarded, isFalse);
        expect(failed, isTrue);

        // Override path: failure then success
        bool shouldFail = true;
        int overrideCalls = 0;
        final overrideService = AdService(
          rewardedOverride: ({
            required VoidCallback onUserEarnedReward,
            VoidCallback? onAdFailedToLoad,
            VoidCallback? onAdDismissed,
          }) async {
            overrideCalls++;
            if (shouldFail) {
              onAdFailedToLoad?.call();
              return false;
            }
            onUserEarnedReward();
            onAdDismissed?.call();
            return true;
          },
        );
        addTearDown(overrideService.dispose);

        rewarded = false;
        failed = false;
        expect(
          await overrideService.showRewardedAd(
            onUserEarnedReward: () => rewarded = true,
            onAdFailedToLoad: () => failed = true,
          ),
          isFalse,
        );
        expect(overrideCalls, 1);
        expect(rewarded, isFalse);
        expect(failed, isTrue);

        shouldFail = false;
        rewarded = false;
        failed = false;
        bool dismissed = false;
        expect(
          await overrideService.showRewardedAd(
            onUserEarnedReward: () => rewarded = true,
            onAdFailedToLoad: () => failed = true,
            onAdDismissed: () => dismissed = true,
          ),
          isTrue,
        );
        expect(overrideCalls, 2);
        expect(rewarded, isTrue);
        expect(failed, isFalse);
        expect(dismissed, isTrue);
      },
    );

    test(
      'showInterstitialAdIfReady never interrupts when not ready or while isBusyWithRewardedAd',
      () async {
        // Without override in test binding (not ready / real ads inactive)
        final plainService = AdService(enableRealAds: false);
        addTearDown(plainService.dispose);
        expect(plainService.isInterstitialAdReady, isFalse);
        expect(await plainService.showInterstitialAdIfReady(), isFalse);

        // With async rewardedOverride in flight -> isBusyWithRewardedAd guards interstitial
        final rewardedCompleter = Completer<bool>();
        int interstitialCalls = 0;

        final guardedService = AdService(
          rewardedOverride: ({
            required VoidCallback onUserEarnedReward,
            VoidCallback? onAdFailedToLoad,
            VoidCallback? onAdDismissed,
          }) async {
            final ok = await rewardedCompleter.future;
            if (ok) {
              onUserEarnedReward();
              onAdDismissed?.call();
            }
            return ok;
          },
          interstitialOverride: ({VoidCallback? onAdDismissed}) async {
            interstitialCalls++;
            onAdDismissed?.call();
            return true;
          },
        );
        addTearDown(guardedService.dispose);

        bool rewardGranted = false;
        final pendingRewardFuture = guardedService.showRewardedAd(
          onUserEarnedReward: () => rewardGranted = true,
        );

        // Rewarded ad is currently active -> interstitial MUST NOT fire
        expect(guardedService.isBusyWithRewardedAd, isTrue);
        final blockedResult = await guardedService.showInterstitialAdIfReady();
        expect(blockedResult, isFalse);
        expect(interstitialCalls, 0);

        // Finish rewarded ad -> interstitial may now fire
        rewardedCompleter.complete(true);
        expect(await pendingRewardFuture, isTrue);
        expect(rewardGranted, isTrue);
        expect(guardedService.isBusyWithRewardedAd, isFalse);

        final allowedResult = await guardedService.showInterstitialAdIfReady();
        expect(allowedResult, isTrue);
        expect(interstitialCalls, 1);
      },
    );

    test(
      'interstitial fires every 3rd completeNextLevel1x and never on claim3x',
      () async {
        int interstitialCalls = 0;
        int rewardedCalls = 0;

        final adService = AdService(
          enableRealAds: false,
          rewardedOverride: ({
            required VoidCallback onUserEarnedReward,
            VoidCallback? onAdFailedToLoad,
            VoidCallback? onAdDismissed,
          }) async {
            rewardedCalls++;
            onUserEarnedReward();
            onAdDismissed?.call();
            return true;
          },
          interstitialOverride: ({VoidCallback? onAdDismissed}) async {
            interstitialCalls++;
            onAdDismissed?.call();
            return true;
          },
        );
        addTearDown(adService.dispose);

        final provider = GameProvider(
          storageService: StorageService.inMemory(),
          audioService: AudioService(enablePlatformAudio: false),
          adService: adService,
          enableTimer: false,
        );
        addTearDown(provider.dispose);

        // 1st 1x completion -> no interstitial
        await provider.completeNextLevel1x();
        expect(provider.completedLevelsSinceInterstitial, 1);
        expect(interstitialCalls, 0);

        // 2nd 1x completion -> no interstitial
        await provider.completeNextLevel1x();
        expect(provider.completedLevelsSinceInterstitial, 2);
        expect(interstitialCalls, 0);

        // claim3x after 2 1x completions -> must NEVER trigger interstitial
        await provider.requestRewardedAd(
          RewardedAdTrigger.claim3x,
          winStars: 3,
          winBaseCoins: 65,
        );
        expect(rewardedCalls, 1);
        expect(interstitialCalls, 0);

        // 3rd 1x completion -> triggers interstitial and resets counter
        await provider.completeNextLevel1x();
        expect(interstitialCalls, 1);
        expect(provider.completedLevelsSinceInterstitial, 0);

        // Next 2 1x completions do not trigger; 6th triggers 2nd interstitial
        await provider.completeNextLevel1x();
        await provider.completeNextLevel1x();
        expect(interstitialCalls, 1);
        await provider.completeNextLevel1x();
        expect(interstitialCalls, 2);
        expect(provider.completedLevelsSinceInterstitial, 0);
      },
    );
  });
}
