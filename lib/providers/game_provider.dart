import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../logic/game_engine.dart';
import '../logic/levels.dart';
import '../models/game_models.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Central application and gameplay state controller for ColorFlow: Sort Master.
class GameProvider extends ChangeNotifier {
  final StorageService _storage;
  final AudioService _audio;
  final AdService _adService;
  final bool _ownsAudio;
  final bool _ownsAdService;

  late SavedProgress _progress;
  ActiveTab _activeTab = ActiveTab.play;
  RewardedAdTrigger? _adTrigger;
  int? _pendingWinStars;
  int? _pendingWinBaseCoins;
  bool _isSettingsOpen = false;
  bool _isProfileOpen = false;
  bool _isRewardedRequestInFlight = false;

  late LevelData _levelData;
  late List<Tube> _tubes;
  int? _selectedTubeIndex;
  int? _shakenTubeIndex;
  List<int> _hintIndices = const [];
  int _moves = 0;
  int _timeSeconds = 0;
  bool _extraTubeUsed = false;
  bool _isCompleted = false;
  bool _isDeadlocked = false;
  List<List<Tube>> _history = const [];
  String _hintMessage = 'Tap any tube to lift and pour matching color!';
  int _completedLevelsSinceInterstitial = 0;

  Timer? _timer;

  GameProvider({
    StorageService? storageService,
    AudioService? audioService,
    AdService? adService,
    bool enableTimer = true,
  })  : _storage = storageService ?? StorageService.inMemory(),
        _audio = audioService ?? AudioService(),
        _adService = adService ?? AdService(),
        _ownsAudio = audioService == null,
        _ownsAdService = adService == null {
    _progress = _storage.loadProgress();
    _audio.setSoundEnabled(_progress.settings.soundEnabled);
    _audio.setHapticsEnabled(_progress.settings.hapticsEnabled);
    _initLevelState(_progress.currentLevel);

    if (enableTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        tickTimer();
      });
    }
  }

  /// Looks up [GameProvider] from [Provider] without throwing if absent in tests.
  static GameProvider? maybeOf(BuildContext context) {
    try {
      return Provider.of<GameProvider>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  // Persistent progression & preferences getters
  SavedProgress get progress => _progress;
  int get currentLevel => _progress.currentLevel;
  int get maxUnlockedLevel => _progress.maxUnlockedLevel;
  Map<int, int> get levelStars => Map.unmodifiable(_progress.levelStars);
  int get totalStars => _progress.totalStars;
  int get coins => _progress.coins;
  int get undoCount => _progress.undoCount;
  List<String> get purchasedItems => List.unmodifiable(_progress.purchasedItems);
  VesselSkinId get equippedVesselSkin => _progress.equippedVesselSkin;
  FluidPaletteId get equippedPalette => _progress.equippedPalette;
  PlayerSettings get settings => _progress.settings;
  PlayerProfile get profile => _progress.profile;

  // Navigation & modal state getters
  ActiveTab get activeTab => _activeTab;
  RewardedAdTrigger? get adTrigger => _adTrigger;
  int? get pendingWinBaseCoins => _pendingWinBaseCoins;
  bool get isSettingsOpen => _isSettingsOpen;
  bool get isProfileOpen => _isProfileOpen;

  // Live level state getters
  LevelData get levelData => _levelData;
  List<Tube> get tubes => List.unmodifiable(_tubes);
  int? get selectedTubeIndex => _selectedTubeIndex;
  int? get shakenTubeIndex => _shakenTubeIndex;
  List<int> get hintIndices => List.unmodifiable(_hintIndices);
  int get moves => _moves;
  int get timeSeconds => _timeSeconds;
  bool get extraTubeUsed => _extraTubeUsed;
  bool get isCompleted => _isCompleted;
  bool get isDeadlocked => _isDeadlocked;
  List<List<Tube>> get history => List.unmodifiable(_history);
  String get hintMessage => _hintMessage;
  int get completedLevelsSinceInterstitial => _completedLevelsSinceInterstitial;

  bool get canUndo => _history.isNotEmpty && undoCount > 0 && !_isCompleted;
  int get completedTubesCount => _tubes.where(isTubeCompleted).length;
  int get totalColorGroups => math.max(
        1,
        (_tubes.fold<int>(0, (acc, t) => acc + t.colors.length) /
                maxTubeCapacity)
            .round(),
      );
  String get liveMilestoneText => '$completedTubesCount / $totalColorGroups Sorts';
  int get starsEarned => calculateStars(_moves, parMoves: _levelData.parMoves);
  int get baseCoinsEarned => calculateBaseCoins(starsEarned);

  List<RankCompetitor> get rankedLeaderboard {
    final entries = <({String name, int level, int stars, bool isUser})>[
      (name: 'Luna_SortMaster', level: 50, stars: 150, isUser: false),
      (name: 'Alex_Flow', level: 48, stars: 141, isUser: false),
      (name: 'PixelSamurai', level: 45, stars: 132, isUser: false),
      (
        name: '${_progress.profile.name} (You)',
        level: _progress.maxUnlockedLevel,
        stars: _progress.totalStars,
        isUser: true,
      ),
      (name: 'EchoVial', level: 39, stars: 114, isUser: false),
      (name: 'CyanSplash', level: 35, stars: 102, isUser: false),
    ];

    entries.sort((a, b) {
      final starCmp = b.stars.compareTo(a.stars);
      if (starCmp != 0) return starCmp;
      return b.level.compareTo(a.level);
    });

    return List<RankCompetitor>.generate(entries.length, (idx) {
      final entry = entries[idx];
      final medal = idx == 0
          ? '🥇'
          : idx == 1
              ? '🥈'
              : idx == 2
                  ? '🥉'
                  : '#${idx + 1}';
      return RankCompetitor(
        name: entry.name,
        level: entry.level,
        stars: entry.stars,
        isUser: entry.isUser,
        rank: idx + 1,
        medal: medal,
      );
    });
  }

  int get userGlobalRank {
    return rankedLeaderboard.firstWhere((e) => e.isUser).rank;
  }

  void _initLevelState(int levelNumber) {
    _levelData = getLevelData(levelNumber);
    _tubes = buildInitialTubes(_levelData);
    _selectedTubeIndex = null;
    _shakenTubeIndex = null;
    _hintIndices = const [];
    _moves = 0;
    _timeSeconds = 0;
    _extraTubeUsed = false;
    _isCompleted = false;
    _isDeadlocked = false;
    _history = const [];
    _hintMessage = 'Tap any tube to lift and pour matching color!';
  }

  void _persist() {
    _storage.saveProgress(_progress);
  }

  void selectTab(ActiveTab tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    notifyListeners();
  }

  void selectLevel(int levelNumber) {
    if (levelNumber < 1) return;
    _progress = _progress.copyWith(currentLevel: levelNumber);
    _initLevelState(levelNumber);
    _activeTab = ActiveTab.play;
    _persist();
    notifyListeners();
  }

  void loadLevel(int levelNumber) {
    if (levelNumber < 1) return;
    _initLevelState(levelNumber);
    notifyListeners();
  }

  /// Processes a tube tap and either updates selection/shake state or returns
  /// a [PourPlan] so the UI can animate the pour before calling [commitPour].
  TapResult handleTubeTap(int index) {
    if (_isCompleted || index < 0 || index >= _tubes.length) {
      return const TapResult(TapOutcome.ignored);
    }

    _hintIndices = const [];
    final tappedTube = _tubes[index];

    if (_selectedTubeIndex == null) {
      if (tappedTube.colors.isEmpty) {
        _shakenTubeIndex = index;
        _audio.playInvalid();
        _hintMessage = 'This tube is empty! Select a tube with liquid.';
        notifyListeners();
        return TapResult(TapOutcome.invalid, message: _hintMessage);
      }
      if (isTubeCompleted(tappedTube)) {
        _shakenTubeIndex = index;
        _audio.playInvalid();
        _hintMessage = 'This tube is already sorted and sealed!';
        notifyListeners();
        return TapResult(TapOutcome.invalid, message: _hintMessage);
      }
      _selectedTubeIndex = index;
      _audio.playTap();
      _hintMessage = 'Now tap a matching or empty tube to pour!';
      notifyListeners();
      return TapResult(TapOutcome.selected, message: _hintMessage);
    }

    if (_selectedTubeIndex == index) {
      _selectedTubeIndex = null;
      _audio.playTap();
      _hintMessage = 'Tap any tube to lift and pour matching color!';
      notifyListeners();
      return TapResult(TapOutcome.deselected, message: _hintMessage);
    }

    final srcIdx = _selectedTubeIndex!;
    final targetTube = _tubes[index];
    final preview = executePour(_tubes, srcIdx, index);

    if (preview == null) {
      _shakenTubeIndex = index;
      _audio.playInvalid();
      _hintMessage = targetTube.colors.length >= targetTube.maxCapacity
          ? 'That tube is full! Choose an empty or matching tube.'
          : "Top colors don't match! Tap the lifted tube to cancel selection.";
      notifyListeners();
      return TapResult(TapOutcome.invalid, message: _hintMessage);
    }

    _hintMessage = 'Pouring liquid...';
    notifyListeners();
    return TapResult(
      TapOutcome.readyToPour,
      pourPlan: PourPlan(
        sourceIndex: srcIdx,
        targetIndex: index,
        preview: preview,
      ),
      message: _hintMessage,
    );
  }

  void triggerShake(int index) {
    _shakenTubeIndex = index;
    notifyListeners();
  }

  void clearShake() {
    if (_shakenTubeIndex == null) return;
    _shakenTubeIndex = null;
    notifyListeners();
  }

  /// Commits a planned pour, updates move history, and checks win/deadlock state.
  void commitPour(int sourceIndex, int targetIndex) {
    final result = executePour(_tubes, sourceIndex, targetIndex);
    if (result == null) return;

    _history = [..._history, cloneTubes(_tubes)];
    _tubes = result.newTubes;
    _moves++;
    _selectedTubeIndex = null;
    _shakenTubeIndex = null;
    _hintIndices = const [];

    final targetNowCompleted = isTubeCompleted(_tubes[targetIndex]);
    final levelNowCompleted = isLevelComplete(_tubes);

    if (levelNowCompleted) {
      _audio.playWin();
      _isCompleted = true;
      _isDeadlocked = false;
      _hintMessage = 'Flawless victory! Level completed!';
    } else if (!hasValidMoves(_tubes)) {
      _audio.playInvalid();
      _isDeadlocked = true;
      _hintMessage =
          'No more valid moves! Use Undo, +1 Tube [AD], or Restart.';
    } else if (targetNowCompleted) {
      _audio.playTubeComplete();
      _isDeadlocked = false;
      _hintMessage = 'Tube sealed! Awesome sort!';
    } else {
      _isDeadlocked = false;
      _hintMessage = 'Smooth pour! Tap HINT if you need a clue.';
    }

    notifyListeners();
  }

  /// Headless convenience method for tests: handles a tube tap and immediately
  /// commits the pour when ready. Returns `true` if the tap resulted in a valid
  /// selection, deselection, or pour (and `false` when invalid or ignored).
  bool tapTubeImmediate(int index) {
    final tap = handleTubeTap(index);
    if (tap.outcome == TapOutcome.readyToPour && tap.pourPlan != null) {
      commitPour(tap.pourPlan!.sourceIndex, tap.pourPlan!.targetIndex);
      return true;
    }
    return tap.outcome != TapOutcome.invalid &&
        tap.outcome != TapOutcome.ignored;
  }

  /// Reverts the last pour move when undo inventory is available.
  bool undo() {
    if (!canUndo) return false;

    final previousTubes = _history.last;
    _history = _history.sublist(0, _history.length - 1);
    _tubes = previousTubes;
    _progress = _progress.copyWith(undoCount: _progress.undoCount - 1);
    _selectedTubeIndex = null;
    _shakenTubeIndex = null;
    _hintIndices = const [];
    _isDeadlocked = !hasValidMoves(previousTubes);
    _hintMessage = 'Move undone!';
    _persist();
    notifyListeners();
    return true;
  }

  /// Restarts the current level board while preserving the max-1 extra tube cap.
  void restartLevel() {
    _tubes = buildInitialTubes(_levelData);
    _selectedTubeIndex = null;
    _shakenTubeIndex = null;
    _hintIndices = const [];
    _moves = 0;
    _timeSeconds = 0;
    _isCompleted = false;
    _isDeadlocked = false;
    _history = const [];
    _hintMessage = 'Level restarted. Good luck!';
    notifyListeners();
  }

  /// Computes and highlights the highest-scoring hint move on the current board.
  HintMove? requestHint() {
    if (_isCompleted) return null;
    final suggestion = findBestHintMove(_tubes);
    if (suggestion == null) {
      _isDeadlocked = true;
      _hintMessage =
          'No productive moves left! Try Undo, +1 Tube [AD], or Restart.';
      notifyListeners();
      return null;
    }
    _hintIndices = [suggestion.sourceIndex, suggestion.targetIndex];
    _selectedTubeIndex = suggestion.sourceIndex;
    _hintMessage = 'Hint: ${suggestion.reason}';
    notifyListeners();
    return suggestion;
  }

  void toggleSound() {
    final nextSound = !_progress.settings.soundEnabled;
    _audio.setSoundEnabled(nextSound);
    _progress = _progress.copyWith(
      settings: _progress.settings.copyWith(soundEnabled: nextSound),
    );
    _persist();
    notifyListeners();
  }

  void updateSettings(PlayerSettings next) {
    _audio.setSoundEnabled(next.soundEnabled);
    _audio.setHapticsEnabled(next.hapticsEnabled);
    _progress = _progress.copyWith(settings: next);
    _persist();
    notifyListeners();
  }

  void updateProfile(PlayerProfile next) {
    _progress = _progress.copyWith(profile: next);
    _persist();
    notifyListeners();
  }

  void openSettings() {
    _isSettingsOpen = true;
    notifyListeners();
  }

  void closeSettings() {
    _isSettingsOpen = false;
    notifyListeners();
  }

  void openProfile() {
    _isProfileOpen = true;
    notifyListeners();
  }

  void closeProfile() {
    _isProfileOpen = false;
    notifyListeners();
  }

  void _recordLevelVictory(int stars, int coinsReward) {
    final lvl = _progress.currentLevel;
    final prevStars = _progress.levelStars[lvl] ?? 0;
    final nextStars = math.max(prevStars, stars);
    final nextLevel = lvl + 1;
    final nextMaxUnlocked = math.max(_progress.maxUnlockedLevel, nextLevel);
    final isNewFlawless = prevStars < 3 && stars == 3;

    final updatedStars = Map<int, int>.from(_progress.levelStars);
    updatedStars[lvl] = nextStars;

    _progress = _progress.copyWith(
      currentLevel: nextLevel,
      maxUnlockedLevel: nextMaxUnlocked,
      coins: _progress.coins + coinsReward,
      levelStars: updatedStars,
      profile: _progress.profile.copyWith(
        levelsCompleted: math.max(_progress.profile.levelsCompleted, lvl),
        flawlessWins: _progress.profile.flawlessWins + (isNewFlawless ? 1 : 0),
      ),
    );
    _persist();
    _initLevelState(nextLevel);
  }

  void _grantRewardForTrigger(RewardedAdTrigger trigger) {
    switch (trigger) {
      case RewardedAdTrigger.extraTube:
        if (!_isCompleted && !_extraTubeUsed) {
          final newTube = Tube(
            id: 'extra-tube-${_levelData.levelNumber}',
            colors: const [],
            maxCapacity: maxTubeCapacity,
          );
          _tubes = [..._tubes, newTube];
          _extraTubeUsed = true;
          _isDeadlocked = false;
          _hintMessage = 'Bonus empty tube unlocked! Keep sorting.';
          notifyListeners();
        }
      case RewardedAdTrigger.refillUndo:
        _progress = _progress.copyWith(undoCount: _progress.undoCount + 3);
        _persist();
        notifyListeners();
      case RewardedAdTrigger.claim3x:
        final stars = _pendingWinStars ?? starsEarned;
        final baseCoins = _pendingWinBaseCoins ?? baseCoinsEarned;
        _pendingWinStars = null;
        _pendingWinBaseCoins = null;
        _recordLevelVictory(stars, baseCoins * 3);
        notifyListeners();
      case RewardedAdTrigger.freeCoins:
        _progress = _progress.copyWith(coins: _progress.coins + 100);
        _persist();
        notifyListeners();
    }
  }

  /// Attempts to display a native rewarded ad first; on unsupported/test
  /// platforms where real ads are inactive, opens the 3-second fallback modal.
  Future<void> requestRewardedAd(
    RewardedAdTrigger trigger, {
    int? winStars,
    int? winBaseCoins,
  }) async {
    if (_isRewardedRequestInFlight || _adTrigger != null) {
      return;
    }
    if (trigger == RewardedAdTrigger.extraTube &&
        (_extraTubeUsed || _isCompleted)) {
      return;
    }

    _isRewardedRequestInFlight = true;
    try {
      if (trigger == RewardedAdTrigger.claim3x) {
        _pendingWinStars = winStars ?? starsEarned;
        _pendingWinBaseCoins = winBaseCoins ?? baseCoinsEarned;
      } else if (winStars != null || winBaseCoins != null) {
        _pendingWinStars = winStars;
        _pendingWinBaseCoins = winBaseCoins;
      }

      final shown = await _adService.showRewardedAd(
        onUserEarnedReward: () {
          _grantRewardForTrigger(trigger);
        },
      );

      if (!shown) {
        if (!_adService.isRealAdsActive) {
          _adTrigger = trigger;
          notifyListeners();
        } else {
          _hintMessage =
              'Video ad unavailable right now. Check connection and try again.';
          notifyListeners();
        }
      }
    } finally {
      _isRewardedRequestInFlight = false;
    }
  }

  void completeFallbackRewardedAd() {
    final current = _adTrigger;
    if (current == null) return;
    _adTrigger = null;
    _grantRewardForTrigger(current);
  }

  void cancelFallbackRewardedAd() {
    _adTrigger = null;
    _pendingWinStars = null;
    _pendingWinBaseCoins = null;
    notifyListeners();
  }

  /// Claims standard 1x victory coins, advances to the next level, and shows
  /// an interstitial ad every 3rd standard victory when ready.
  Future<void> completeNextLevel1x() async {
    final stars = starsEarned;
    final coinsReward = baseCoinsEarned;
    _recordLevelVictory(stars, coinsReward);
    _completedLevelsSinceInterstitial++;
    notifyListeners();

    if (_completedLevelsSinceInterstitial >= 3 &&
        !_adService.isBusyWithRewardedAd) {
      final shown = await _adService.showInterstitialAdIfReady();
      if (shown) {
        _completedLevelsSinceInterstitial = 0;
        notifyListeners();
      }
    }
  }

  /// Purchases or equips a vessel skin, liquid palette, or undo booster pack.
  void buyOrEquipShopItem(String itemId, ShopItemKind kind, int price) {
    final isOwned = kind != ShopItemKind.consumable &&
        _progress.purchasedItems.contains(itemId);

    if (isOwned) {
      _progress = _progress.copyWith(
        equippedVesselSkin: kind == ShopItemKind.vessel
            ? VesselSkinId.fromId(itemId)
            : _progress.equippedVesselSkin,
        equippedPalette: kind == ShopItemKind.palette
            ? FluidPaletteId.fromId(itemId)
            : _progress.equippedPalette,
      );
      _persist();
      notifyListeners();
      return;
    }

    if (_progress.coins < price) return;
    _audio.playWin();

    if (kind == ShopItemKind.consumable) {
      _progress = _progress.copyWith(
        coins: _progress.coins - price,
        undoCount: _progress.undoCount + 10,
      );
      _persist();
      notifyListeners();
      return;
    }

    _progress = _progress.copyWith(
      coins: _progress.coins - price,
      purchasedItems: [..._progress.purchasedItems, itemId],
      equippedVesselSkin: kind == ShopItemKind.vessel
          ? VesselSkinId.fromId(itemId)
          : _progress.equippedVesselSkin,
      equippedPalette: kind == ShopItemKind.palette
          ? FluidPaletteId.fromId(itemId)
          : _progress.equippedPalette,
    );
    _persist();
    notifyListeners();
  }

  /// Clears saved progress and restarts from Level 1 defaults.
  Future<void> resetAllProgress() async {
    _progress = await _storage.resetProgress();
    _audio.setSoundEnabled(_progress.settings.soundEnabled);
    _audio.setHapticsEnabled(_progress.settings.hapticsEnabled);
    _activeTab = ActiveTab.play;
    _adTrigger = null;
    _pendingWinStars = null;
    _pendingWinBaseCoins = null;
    _completedLevelsSinceInterstitial = 0;
    _initLevelState(_progress.currentLevel);
    notifyListeners();
  }

  /// Increments the active play timer when gameplay is visible and unpaused.
  void tickTimer() {
    if (_isCompleted ||
        _activeTab != ActiveTab.play ||
        _isSettingsOpen ||
        _isProfileOpen ||
        _adTrigger != null) {
      return;
    }
    _timeSeconds++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_ownsAudio) {
      _audio.dispose();
    }
    if (_ownsAdService) {
      _adService.dispose();
    }
    super.dispose();
  }
}
