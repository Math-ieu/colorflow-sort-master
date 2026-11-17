import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/game_models.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';
import 'screens/levels_screen.dart';
import 'screens/ranks_screen.dart';
import 'screens/shop_screen.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import 'widgets/modals/profile_modal.dart';
import 'widgets/modals/rewarded_ad_modal.dart';
import 'widgets/modals/settings_modal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (_) {
    // Ignore orientation lock failures on desktop/unsupported platforms.
  }

  StorageService storageService;
  try {
    storageService = await StorageService.getInstance();
  } catch (_) {
    storageService = StorageService.inMemory();
  }

  final audioService = AudioService();
  final adService = AdService();
  unawaited(adService.initialize());

  runApp(
    ColorFlowApp(
      storageService: storageService,
      audioService: audioService,
      adService: adService,
    ),
  );
}

/// Root application widget for ColorFlow: Sort Master.
class ColorFlowApp extends StatefulWidget {
  const ColorFlowApp({
    super.key,
    this.storageService,
    this.audioService,
    this.adService,
    this.gameProvider,
    this.enableTimer = true,
  });

  final StorageService? storageService;
  final AudioService? audioService;
  final AdService? adService;
  final GameProvider? gameProvider;
  final bool enableTimer;

  @override
  State<ColorFlowApp> createState() => _ColorFlowAppState();
}

class _ColorFlowAppState extends State<ColorFlowApp> {
  late final AudioService _audioService;
  late final AdService _adService;
  late final GameProvider _gameProvider;
  late final bool _ownsAudio;
  late final bool _ownsAdService;
  late final bool _ownsGameProvider;

  @override
  void initState() {
    super.initState();
    _ownsAudio = widget.audioService == null;
    _ownsAdService = widget.adService == null;
    _ownsGameProvider = widget.gameProvider == null;

    _audioService = widget.audioService ?? AudioService();
    _adService = widget.adService ?? AdService();
    _gameProvider = widget.gameProvider ??
        GameProvider(
          storageService: widget.storageService,
          audioService: _audioService,
          adService: _adService,
          enableTimer: widget.enableTimer,
        );
  }

  @override
  void dispose() {
    if (_ownsGameProvider) {
      _gameProvider.dispose();
    }
    if (_ownsAudio) {
      _audioService.dispose();
    }
    if (_ownsAdService) {
      _adService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AudioService>.value(value: _audioService),
        ChangeNotifierProvider<AdService>.value(value: _adService),
        ChangeNotifierProvider<GameProvider>.value(value: _gameProvider),
      ],
      child: MaterialApp(
        title: 'ColorFlow: Sort Master',
        debugShowCheckedModeBanner: false,
        theme: AppTypography.lightTheme,
        home: const MainShell(),
      ),
    );
  }
}

/// Centered mobile viewport shell hosting active tabs and global modals.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    Widget activeScreen;
    switch (provider.activeTab) {
      case ActiveTab.play:
        activeScreen = const GameScreen();
      case ActiveTab.levels:
        activeScreen = const LevelsScreen();
      case ActiveTab.shop:
        activeScreen = const ShopScreen();
      case ActiveTab.ranks:
        activeScreen = const RanksScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.appRootBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF191432).withOpacity(0.15),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(child: activeScreen),

                // Global Modals
                RewardedAdModal(
                  visible: provider.adTrigger != null,
                  trigger: provider.adTrigger,
                  pendingBaseCoins:
                      provider.pendingWinBaseCoins ?? provider.baseCoinsEarned,
                  onCompleteReward: provider.completeFallbackRewardedAd,
                  onCancel: provider.cancelFallbackRewardedAd,
                ),

                SettingsModal(
                  visible: provider.isSettingsOpen,
                  settings: provider.settings,
                  onUpdateSettings: provider.updateSettings,
                  onResetProgress: provider.resetAllProgress,
                  onClose: provider.closeSettings,
                ),

                ProfileModal(
                  visible: provider.isProfileOpen,
                  profile: provider.profile,
                  maxLevel: provider.maxUnlockedLevel,
                  totalStars: provider.totalStars,
                  coins: provider.coins,
                  globalRank: provider.userGlobalRank,
                  onUpdateProfile: provider.updateProfile,
                  onClose: provider.closeProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
