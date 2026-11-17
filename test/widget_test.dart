import 'package:colorflow_sort_master/main.dart';
import 'package:colorflow_sort_master/models/game_models.dart';
import 'package:colorflow_sort_master/providers/game_provider.dart';
import 'package:colorflow_sort_master/services/ad_service.dart';
import 'package:colorflow_sort_master/services/audio_service.dart';
import 'package:colorflow_sort_master/services/storage_service.dart';
import 'package:colorflow_sort_master/widgets/game/test_tube.dart';
import 'package:colorflow_sort_master/widgets/modals/level_completed_modal.dart';
import 'package:colorflow_sort_master/widgets/modals/profile_modal.dart';
import 'package:colorflow_sort_master/widgets/modals/rewarded_ad_modal.dart';
import 'package:colorflow_sort_master/widgets/modals/settings_modal.dart';
import 'package:colorflow_sort_master/widgets/navigation/ad_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'ColorFlowApp renders Level 1, pours & undoes, navigates tabs, opens modals, and triggers RewardedAdModal',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final storage = StorageService.inMemory();
      final audio = AudioService(enablePlatformAudio: false);
      final adService = AdService(enableRealAds: false);
      final provider = GameProvider(
        storageService: storage,
        audioService: audio,
        adService: adService,
        enableTimer: false,
      );

      await tester.pumpWidget(
        ColorFlowApp(
          storageService: storage,
          audioService: audio,
          adService: adService,
          gameProvider: provider,
          enableTimer: false,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // 1. Verify Level 1 initial UI renders cleanly
      expect(find.text('ColorFlow'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('0 / 2 Sorts'), findsOneWidget);
      expect(find.byType(TestTube), findsNWidgets(3));
      expect(find.text('EMPTY'), findsOneWidget);
      expect(find.byType(AdBannerWidget), findsOneWidget);
      expect(find.text('Water Sort 3D • Free Gift'), findsOneWidget);

      // Verify tubes are laid out side-by-side horizontally on the same row
      final tube0Center = tester.getCenter(find.byType(TestTube).at(0));
      final tube1Center = tester.getCenter(find.byType(TestTube).at(1));
      final tube2Center = tester.getCenter(find.byType(TestTube).at(2));
      expect(tube0Center.dx, lessThan(tube1Center.dx));
      expect(tube1Center.dx, lessThan(tube2Center.dx));
      expect((tube0Center.dy - tube1Center.dy).abs(), lessThan(1.0));
      expect((tube1Center.dy - tube2Center.dy).abs(), lessThan(1.0));

      // 2. Test tube tap & pour animation (Tube 0 -> empty Tube 2)
      await tester.tap(find.byType(TestTube).at(0));
      await tester.pump();
      expect(provider.selectedTubeIndex, 0);

      await tester.tap(find.byType(TestTube).at(2));
      for (int i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(provider.moves, 1);
      expect(provider.tubes[2].colors, <LiquidColor>[LiquidColor.mint]);
      expect(find.text('EMPTY'), findsNothing);

      // Undo restores empty tube
      final undoIcon = find.byIcon(Icons.undo);
      await tester.ensureVisible(undoIcon);
      await tester.tap(undoIcon);
      await tester.pump(const Duration(milliseconds: 100));
      expect(provider.undoCount, 2);
      expect(find.text('EMPTY'), findsOneWidget);

      // 3. Navigate across Levels, Shop tabs and back to Play (Ranks removed)
      expect(find.text('Ranks'), findsNothing);
      await tester.tap(find.text('Levels'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Select Level'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('STITCH'), findsNothing);

      await tester.tap(find.text('Shop'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Vessel & Liquid Shop'), findsOneWidget);
      expect(find.text('Free Coin Chest'), findsOneWidget);
      expect(find.text('Classic Lab Vials'), findsOneWidget);
      expect(find.text('Crystal Flacons'), findsOneWidget);
      final undoMasterFinder = find.text('Undo Master (+10)');
      await tester.scrollUntilVisible(
        undoMasterFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(undoMasterFinder);
      expect(undoMasterFinder, findsOneWidget);

      await tester.tap(find.text('Play'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Level 1'), findsOneWidget);

      // 4. Open SettingsModal and toggle Color-Blind Symbols
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SettingsModal), findsOneWidget);
      expect(find.text('Game Settings'), findsOneWidget);
      expect(find.text('ASMR Fluid Sounds'), findsOneWidget);
      expect(find.text('Tactile Haptics'), findsOneWidget);
      expect(find.text('Color-Blind Symbols'), findsOneWidget);
      expect(find.text('Reset Saved Progress (Start Level 1)'), findsOneWidget);

      final switches = find.byType(Switch);
      if (switches.evaluate().length >= 3) {
        await tester.ensureVisible(switches.at(2));
        await tester.tap(switches.at(2));
      } else {
        await tester.tap(find.text('Color-Blind Symbols'));
      }
      await tester.pump();
      expect(provider.settings.colorBlindMode, isTrue);

      final saveSettingsBtn = find.text('Save & Resume');
      await tester.ensureVisible(saveSettingsBtn);
      await tester.tap(saveSettingsBtn);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Game Settings'), findsNothing);

      // 5. Open ProfileModal, switch avatar to Flash, and save profile
      await tester.tap(find.byKey(const Key('profile_hud_button')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ProfileModal), findsOneWidget);
      expect(find.text('Player Profile'), findsOneWidget);
      expect(find.text('DISPLAY NAME'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bolt).first);
      await tester.pump();

      final saveProfileBtn = find.text('Save Profile');
      await tester.ensureVisible(saveProfileBtn);
      await tester.tap(saveProfileBtn);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Player Profile'), findsNothing);
      expect(find.byIcon(Icons.bolt), findsOneWidget);

      // 6. Verify RewardedAdModal opens on +1 Tube in test mode & grants 4th tube
      final addTubeBtn = find.text('Tube');
      await tester.ensureVisible(addTubeBtn);
      await tester.tap(addTubeBtn);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RewardedAdModal), findsOneWidget);
      expect(find.text('GOOGLE ADMOB • REWARDED'), findsOneWidget);
      expect(find.text('Unlock +1 Extra Tube'), findsOneWidget);
      expect(find.text('+1 TUBE'), findsOneWidget);

      // Advance 3-second countdown
      for (int s = 0; s < 3; s++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump(const Duration(milliseconds: 100));

      final claimBtn = find.text('CLAIM +1 TUBE');
      expect(claimBtn, findsOneWidget);
      await tester.ensureVisible(claimBtn);
      await tester.tap(claimBtn);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('GOOGLE ADMOB • REWARDED'), findsNothing);
      expect(provider.tubes.length, 4);
      expect(provider.extraTubeUsed, isTrue);
      expect(find.byType(TestTube), findsNWidgets(4));
    },
  );

  testWidgets(
    'LevelCompletedModal renders without overflow and triggers 3x & Next Level callbacks',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int claim3xCalls = 0;
      int nextLevelCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                LevelCompletedModal(
                  visible: true,
                  levelNumber: 1,
                  moves: 5,
                  timeFormatted: '00:21',
                  starsEarned: 3,
                  coinsEarned: 65,
                  onClaim3x: () => claim3xCalls++,
                  onNextLevel: () => nextLevelCalls++,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('STAGE CLEARED'), findsOneWidget);
      expect(find.text('LEVEL 1'), findsOneWidget);
      expect(find.text('PERFECT!'), findsOneWidget);
      expect(find.text('WATCH VIDEO'), findsOneWidget);
      expect(find.text('Claim 3x Coins'), findsOneWidget);
      expect(find.text('+195'), findsOneWidget);
      expect(find.text('Next Level (+65 Coins)'), findsOneWidget);

      await tester.tap(find.text('WATCH VIDEO'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(claim3xCalls, 1);

      await tester.tap(find.text('Next Level (+65 Coins)'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(nextLevelCalls, 1);
    },
  );
}
