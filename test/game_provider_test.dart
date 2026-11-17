import 'dart:async';

import 'package:colorflow_sort_master/models/game_models.dart';
import 'package:colorflow_sort_master/providers/game_provider.dart';
import 'package:colorflow_sort_master/services/ad_service.dart';
import 'package:colorflow_sort_master/services/audio_service.dart';
import 'package:colorflow_sort_master/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

GameProvider _createProvider({
  StorageService? storage,
  AdService? adService,
}) {
  return GameProvider(
    storageService: storage ?? StorageService.inMemory(),
    audioService: AudioService(enablePlatformAudio: false),
    adService: adService ?? AdService(enableRealAds: false),
    enableTimer: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('GameProvider', () {
    test('starts with exact Level 1 initial defaults', () async {
      final storage = await StorageService.getInstance();
      final provider = _createProvider(storage: storage);

      expect(provider.currentLevel, 1);
      expect(provider.maxUnlockedLevel, 1);
      expect(provider.coins, 250);
      expect(provider.undoCount, 3);
      expect(provider.levelStars, isEmpty);
      expect(provider.totalStars, 0);
      expect(
        provider.purchasedItems,
        <String>['tube-classic', 'palette-classic'],
      );
      expect(provider.equippedVesselSkin, VesselSkinId.tubeClassic);
      expect(provider.equippedPalette, FluidPaletteId.paletteClassic);
      expect(provider.profile.name, 'FlowMaster');
      expect(provider.profile.avatarIcon, 'ColorWand');
      expect(provider.profile.levelsCompleted, 0);
      expect(provider.profile.flawlessWins, 0);
      expect(provider.settings.soundEnabled, isTrue);
      expect(provider.settings.hapticsEnabled, isTrue);
      expect(provider.settings.colorBlindMode, isFalse);
      expect(provider.activeTab, ActiveTab.play);
      expect(provider.tubes.length, 3);
      expect(provider.moves, 0);
      expect(provider.isCompleted, isFalse);
      expect(provider.isDeadlocked, isFalse);
    });

    test('handles tube tap, pour, undo, hint, and restart correctly', () {
      final provider = _createProvider();

      // Tapping empty tube with no selection is invalid
      final emptyTap = provider.handleTubeTap(2);
      expect(emptyTap.outcome, TapOutcome.invalid);

      // Select tube 0, then tap again to deselect
      expect(provider.handleTubeTap(0).outcome, TapOutcome.selected);
      expect(provider.selectedTubeIndex, 0);
      expect(provider.handleTubeTap(0).outcome, TapOutcome.deselected);
      expect(provider.selectedTubeIndex, isNull);

      // Select tube 0, tap incompatible tube 1 -> invalid
      expect(provider.handleTubeTap(0).outcome, TapOutcome.selected);
      expect(provider.handleTubeTap(1).outcome, TapOutcome.invalid);

      // Tap empty tube 2 -> readyToPour
      final pourTap = provider.handleTubeTap(2);
      expect(pourTap.outcome, TapOutcome.readyToPour);
      expect(pourTap.pourPlan, isNotNull);
      expect(pourTap.pourPlan!.sourceIndex, 0);
      expect(pourTap.pourPlan!.targetIndex, 2);

      // Execute via tapTubeImmediate after resetting selection
      provider.handleTubeTap(0); // already selected -> deselect
      expect(provider.tapTubeImmediate(0), isTrue);
      expect(provider.tapTubeImmediate(2), isTrue);
      expect(provider.moves, 1);
      expect(provider.history.length, 1);
      expect(provider.canUndo, isTrue);
      expect(provider.tubes[0].colors, <LiquidColor>[
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.coral,
      ]);
      expect(provider.tubes[2].colors, <LiquidColor>[LiquidColor.mint]);

      // Undo restores previous board and decrements undoCount
      expect(provider.undo(), isTrue);
      expect(provider.undoCount, 2);
      expect(provider.tubes[2].colors, isEmpty);
      expect(provider.history, isEmpty);
      expect(provider.canUndo, isFalse);
      expect(provider.undo(), isFalse);

      // Hint highlights best move and selects source tube
      final hint = provider.requestHint();
      expect(hint, isNotNull);
      expect(provider.hintIndices, <int>[hint!.sourceIndex, hint.targetIndex]);
      expect(provider.selectedTubeIndex, hint.sourceIndex);
      expect(provider.hintMessage, startsWith('Hint: '));

      // Perform a move then restart
      provider.tapTubeImmediate(0);
      provider.tapTubeImmediate(2);
      expect(provider.moves, 1);
      provider.restartLevel();
      expect(provider.moves, 0);
      expect(provider.timeSeconds, 0);
      expect(provider.history, isEmpty);
      expect(provider.hintIndices, isEmpty);
      expect(provider.isCompleted, isFalse);
      expect(provider.tubes[2].colors, isEmpty);
    });

    test(
      'completing Level 1 and calling completeNextLevel1x updates stars, coins, profile, and storage',
      () async {
        final storage = await StorageService.getInstance();
        final provider = _createProvider(storage: storage);

        // Solve Level 1 in 7 moves
        const movesSequence = <(int, int)>[
          (0, 2),
          (1, 0),
          (1, 2),
          (0, 1),
          (0, 2),
          (1, 0),
          (1, 2),
        ];
        for (final (src, dst) in movesSequence) {
          expect(provider.tapTubeImmediate(src), isTrue);
          expect(provider.tapTubeImmediate(dst), isTrue);
        }

        expect(provider.isCompleted, isTrue);
        expect(provider.moves, 7);
        expect(provider.starsEarned, 2);
        expect(provider.baseCoinsEarned, 50);
        expect(provider.completedTubesCount, 2);
        expect(provider.liveMilestoneText, '2 / 2 Sorts');

        await provider.completeNextLevel1x();

        expect(provider.currentLevel, 2);
        expect(provider.maxUnlockedLevel, 2);
        expect(provider.coins, 300);
        expect(provider.levelStars[1], 2);
        expect(provider.totalStars, 2);
        expect(provider.profile.levelsCompleted, 1);
        expect(provider.profile.flawlessWins, 0);
        expect(provider.isCompleted, isFalse);
        expect(provider.tubes.length, 4);

        // Persisted to SharedPreferences
        final reloaded = storage.loadProgress();
        expect(reloaded.currentLevel, 2);
        expect(reloaded.maxUnlockedLevel, 2);
        expect(reloaded.coins, 300);
        expect(reloaded.levelStars[1], 2);
        expect(reloaded.profile.levelsCompleted, 1);
      },
    );

    test('shop buy/equip and Undo Master (+10) work accurately', () async {
      final adService = AdService(
        rewardedOverride: ({
          required VoidCallback onUserEarnedReward,
          VoidCallback? onAdFailedToLoad,
          VoidCallback? onAdDismissed,
        }) async {
          onUserEarnedReward();
          onAdDismissed?.call();
          return true;
        },
      );
      final provider = _createProvider(adService: adService);

      // Cannot afford Royal Golden Tubes (800) with 250 coins
      provider.buyOrEquipShopItem('tube-gold', ShopItemKind.vessel, 800);
      expect(provider.coins, 250);
      expect(provider.purchasedItems, isNot(contains('tube-gold')));

      // Buy Undo Master (+10) consumable for 150 coins
      provider.buyOrEquipShopItem('booster-pack', ShopItemKind.consumable, 150);
      expect(provider.coins, 100);
      expect(provider.undoCount, 13);
      expect(provider.purchasedItems, isNot(contains('booster-pack')));

      // Earn +200 coins via 2 freeCoins ads -> 300 coins
      await provider.requestRewardedAd(RewardedAdTrigger.freeCoins);
      await provider.requestRewardedAd(RewardedAdTrigger.freeCoins);
      expect(provider.coins, 300);

      // Buy Crystal Flacons (250) -> equips automatically
      provider.buyOrEquipShopItem('tube-crystal', ShopItemKind.vessel, 250);
      expect(provider.coins, 50);
      expect(provider.purchasedItems, contains('tube-crystal'));
      expect(provider.equippedVesselSkin, VesselSkinId.tubeCrystal);

      // Switch back to owned classic skin without spending coins
      provider.buyOrEquipShopItem('tube-classic', ShopItemKind.vessel, 0);
      expect(provider.coins, 50);
      expect(provider.equippedVesselSkin, VesselSkinId.tubeClassic);

      // Re-equip owned crystal skin without repaying 250 coins
      provider.buyOrEquipShopItem('tube-crystal', ShopItemKind.vessel, 250);
      expect(provider.coins, 50);
      expect(provider.equippedVesselSkin, VesselSkinId.tubeCrystal);

      // Earn 400 coins and buy Neon Glow Fluids palette
      for (int i = 0; i < 4; i++) {
        await provider.requestRewardedAd(RewardedAdTrigger.freeCoins);
      }
      expect(provider.coins, 450);
      provider.buyOrEquipShopItem('theme-neon', ShopItemKind.palette, 400);
      expect(provider.coins, 50);
      expect(provider.purchasedItems, contains('theme-neon'));
      expect(provider.equippedPalette, FluidPaletteId.themeNeon);
    });

    test(
      'rewarded ad triggers handle extraTube, refillUndo, freeCoins, and claim3x via override and fallback modal',
      () async {
        // 1. Direct override path
        final overrideAd = AdService(
          rewardedOverride: ({
            required VoidCallback onUserEarnedReward,
            VoidCallback? onAdFailedToLoad,
            VoidCallback? onAdDismissed,
          }) async {
            onUserEarnedReward();
            onAdDismissed?.call();
            return true;
          },
        );
        final p1 = _createProvider(adService: overrideAd);

        // extraTube
        expect(p1.tubes.length, 3);
        expect(p1.extraTubeUsed, isFalse);
        await p1.requestRewardedAd(RewardedAdTrigger.extraTube);
        expect(p1.tubes.length, 4);
        expect(p1.tubes.last.colors, isEmpty);
        expect(p1.extraTubeUsed, isTrue);
        expect(p1.adTrigger, isNull);

        // Second extraTube on same level is capped
        await p1.requestRewardedAd(RewardedAdTrigger.extraTube);
        expect(p1.tubes.length, 4);

        // refillUndo
        await p1.requestRewardedAd(RewardedAdTrigger.refillUndo);
        expect(p1.undoCount, 6);

        // freeCoins
        await p1.requestRewardedAd(RewardedAdTrigger.freeCoins);
        expect(p1.coins, 350);

        // claim3x (3 stars, 65 base coins -> +195 coins, flawlessWins == 1)
        await p1.requestRewardedAd(
          RewardedAdTrigger.claim3x,
          winStars: 3,
          winBaseCoins: 65,
        );
        expect(p1.coins, 545);
        expect(p1.levelStars[1], 3);
        expect(p1.currentLevel, 2);
        expect(p1.maxUnlockedLevel, 2);
        expect(p1.profile.levelsCompleted, 1);
        expect(p1.profile.flawlessWins, 1);

        // 2. Fallback modal path (when real ads are inactive & no override)
        final fallbackAd = AdService(enableRealAds: false);
        final p2 = _createProvider(adService: fallbackAd);

        await p2.requestRewardedAd(RewardedAdTrigger.freeCoins);
        expect(p2.adTrigger, RewardedAdTrigger.freeCoins);
        expect(p2.coins, 250);

        p2.cancelFallbackRewardedAd();
        expect(p2.adTrigger, isNull);
        expect(p2.coins, 250);

        await p2.requestRewardedAd(RewardedAdTrigger.freeCoins);
        expect(p2.adTrigger, RewardedAdTrigger.freeCoins);
        p2.completeFallbackRewardedAd();
        expect(p2.adTrigger, isNull);
        expect(p2.coins, 350);

        await p2.requestRewardedAd(
          RewardedAdTrigger.claim3x,
          winStars: 3,
          winBaseCoins: 65,
        );
        expect(p2.adTrigger, RewardedAdTrigger.claim3x);
        expect(p2.pendingWinBaseCoins, 65);
        p2.completeFallbackRewardedAd();
        expect(p2.adTrigger, isNull);
        expect(p2.coins, 545);
        expect(p2.profile.flawlessWins, 1);
        expect(p2.currentLevel, 2);

        // 3. Re-entrancy guard prevents duplicate rewarded ad triggers while in flight
        final inFlightCompleter = Completer<bool>();
        int overrideCalls = 0;
        final guardedAd = AdService(
          rewardedOverride: ({
            required VoidCallback onUserEarnedReward,
            VoidCallback? onAdFailedToLoad,
            VoidCallback? onAdDismissed,
          }) async {
            overrideCalls++;
            final ok = await inFlightCompleter.future;
            if (ok) {
              onUserEarnedReward();
              onAdDismissed?.call();
            }
            return ok;
          },
        );
        final p3 = _createProvider(adService: guardedAd);
        final firstCall = p3.requestRewardedAd(RewardedAdTrigger.freeCoins);
        final secondCall = p3.requestRewardedAd(RewardedAdTrigger.freeCoins);
        inFlightCompleter.complete(true);
        await Future.wait(<Future<void>>[firstCall, secondCall]);

        expect(overrideCalls, 1);
        expect(p3.coins, 350);
      },
    );

    test(
      'settings, profile, tabs, timer, and resetAllProgress work correctly',
      () async {
        final storage = await StorageService.getInstance();
        final provider = _createProvider(storage: storage);

        // Modals & settings
        provider.openSettings();
        expect(provider.isSettingsOpen, isTrue);
        provider.toggleSound();
        expect(provider.settings.soundEnabled, isFalse);
        provider.updateSettings(
          const PlayerSettings(
            soundEnabled: false,
            hapticsEnabled: false,
            colorBlindMode: true,
          ),
        );
        expect(provider.settings.colorBlindMode, isTrue);
        provider.closeSettings();
        expect(provider.isSettingsOpen, isFalse);

        // Profile
        provider.openProfile();
        expect(provider.isProfileOpen, isTrue);
        provider.updateProfile(
          const PlayerProfile(
            name: 'AquaWizard',
            avatarIcon: 'Diamond',
            levelsCompleted: 4,
            flawlessWins: 2,
          ),
        );
        expect(provider.profile.name, 'AquaWizard');
        provider.closeProfile();
        expect(provider.isProfileOpen, isFalse);

        // Timer tick only increments on active play tab with no modal open
        provider.tickTimer();
        expect(provider.timeSeconds, 1);
        provider.selectTab(ActiveTab.shop);
        expect(provider.activeTab, ActiveTab.shop);
        provider.tickTimer();
        expect(provider.timeSeconds, 1);

        // Spend coins & advance state before reset
        provider.buyOrEquipShopItem(
            'booster-pack', ShopItemKind.consumable, 150);
        expect(provider.coins, 100);
        expect(provider.undoCount, 13);

        await provider.resetAllProgress();

        expect(provider.currentLevel, 1);
        expect(provider.maxUnlockedLevel, 1);
        expect(provider.coins, 250);
        expect(provider.undoCount, 3);
        expect(provider.levelStars, isEmpty);
        expect(
          provider.purchasedItems,
          <String>['tube-classic', 'palette-classic'],
        );
        expect(provider.equippedVesselSkin, VesselSkinId.tubeClassic);
        expect(provider.equippedPalette, FluidPaletteId.paletteClassic);
        expect(provider.profile.name, 'FlowMaster');
        expect(provider.profile.levelsCompleted, 0);
        expect(provider.profile.flawlessWins, 0);
        expect(provider.settings.colorBlindMode, isFalse);
        expect(provider.activeTab, ActiveTab.play);
      },
    );
  });
}
