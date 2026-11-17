import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

/// Tactile sound effects and haptic feedback manager backed by `just_audio`
/// and pre-synthesized WAV assets under `assets/sounds/`.
///
/// Safely disables platform audio and haptics inside Flutter test bindings or
/// when `enablePlatformAudio` is false.
class AudioService {
  static const String _pourAsset = 'assets/sounds/pour.wav';
  static const String _tapAsset = 'assets/sounds/tap.wav';
  static const String _tubeCompleteAsset = 'assets/sounds/tube_complete.wav';
  static const String _invalidAsset = 'assets/sounds/invalid.wav';
  static const String _winAsset = 'assets/sounds/win.wav';
  static const String _clickAsset = 'assets/sounds/click.wav';

  static const List<String> _allAssets = [
    _pourAsset,
    _tapAsset,
    _tubeCompleteAsset,
    _invalidAsset,
    _winAsset,
    _clickAsset,
  ];

  final bool enablePlatformAudio;
  bool _soundEnabled;
  bool _hapticsEnabled;
  bool _disposed = false;

  final Map<String, AudioPlayer> _players = {};
  final Map<String, Future<AudioPlayer?>> _loadingPlayers = {};
  final Map<String, int> _playSequence = {};

  AudioService({
    bool soundEnabled = true,
    bool hapticsEnabled = true,
    this.enablePlatformAudio = true,
  })  : _soundEnabled = soundEnabled,
        _hapticsEnabled = hapticsEnabled {
    if (_canUsePlatform) {
      preloadAll();
    }
  }

  /// Looks up [AudioService] from [Provider] without throwing if absent.
  static AudioService? maybeOf(BuildContext context) {
    try {
      return Provider.of<AudioService>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  static bool _isTestBinding() {
    try {
      final name = WidgetsBinding.instance.runtimeType.toString();
      return name.contains('Test');
    } catch (_) {
      return true;
    }
  }

  bool get _canUsePlatform =>
      enablePlatformAudio && !_disposed && !_isTestBinding();

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  void setSoundEnabled(bool v) {
    _soundEnabled = v;
    if (!v) {
      for (final player in _players.values) {
        if (player.playing) {
          player.pause().then((_) {}, onError: (_) {});
        }
      }
    }
  }

  void setHapticsEnabled(bool v) {
    _hapticsEnabled = v;
  }

  /// Preloads all 6 WAV assets for zero-latency playback.
  Future<void> preloadAll() async {
    if (!_canUsePlatform) return;
    await Future.wait(_allAssets.map(_ensurePlayerLoaded));
  }

  Future<AudioPlayer?> _ensurePlayerLoaded(String assetPath) {
    if (!_canUsePlatform) return Future.value(null);
    final existing = _players[assetPath];
    if (existing != null) return Future.value(existing);

    final pending = _loadingPlayers[assetPath];
    if (pending != null) return pending;

    final future = () async {
      try {
        final player = AudioPlayer();
        await player.setAsset(assetPath);
        if (_disposed) {
          await player.dispose();
          return null;
        }
        _players[assetPath] = player;
        return player;
      } catch (_) {
        return null;
      } finally {
        _loadingPlayers.remove(assetPath);
      }
    }();

    _loadingPlayers[assetPath] = future;
    return future;
  }

  Future<void> _playAsset(String assetPath) async {
    if (!_soundEnabled || !_canUsePlatform) return;
    final int seq = (_playSequence[assetPath] ?? 0) + 1;
    _playSequence[assetPath] = seq;
    try {
      final player = await _ensurePlayerLoaded(assetPath);
      if (player == null ||
          _disposed ||
          !_soundEnabled ||
          _playSequence[assetPath] != seq) {
        return;
      }
      // just_audio keeps `playing == true` after ProcessingState.completed
      // (especially on Web), causing subsequent `play()` calls to no-op unless paused first.
      if (player.playing) {
        await player.pause();
      }
      if (_disposed || !_soundEnabled || _playSequence[assetPath] != seq) {
        return;
      }
      if (player.processingState == ProcessingState.idle) {
        await player.setAsset(assetPath);
      }
      await player.seek(Duration.zero);
      if (_disposed || !_soundEnabled || _playSequence[assetPath] != seq) {
        return;
      }
      // Do not await playback completion so rapid interactions remain responsive.
      player.play().then((_) {}, onError: (_) {});
    } catch (_) {
      // Ignore audio failures in unsupported/headless environments.
    }
  }

  Future<void> _triggerHaptic(Future<void> Function() action) async {
    if (!_hapticsEnabled || !_canUsePlatform) return;
    try {
      await action();
    } catch (_) {
      // Ignore MissingPluginException or unsupported haptic platforms.
    }
  }

  Future<void> playPour() async {
    await _triggerHaptic(HapticFeedback.lightImpact);
    await _playAsset(_pourAsset);
  }

  Future<void> playTap() async {
    await _triggerHaptic(HapticFeedback.selectionClick);
    await _playAsset(_tapAsset);
  }

  Future<void> playTubeComplete() async {
    await _triggerHaptic(HapticFeedback.mediumImpact);
    await _playAsset(_tubeCompleteAsset);
  }

  Future<void> playInvalid() async {
    await _triggerHaptic(HapticFeedback.lightImpact);
    await _playAsset(_invalidAsset);
  }

  Future<void> playWin() async {
    await _triggerHaptic(HapticFeedback.heavyImpact);
    await _playAsset(_winAsset);
  }

  Future<void> playClick() async {
    await _triggerHaptic(HapticFeedback.selectionClick);
    await _playAsset(_clickAsset);
  }

  Future<void> dispose() async {
    _disposed = true;
    final players = List<AudioPlayer>.from(_players.values);
    _players.clear();
    _loadingPlayers.clear();
    _playSequence.clear();
    for (final player in players) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }
}
