import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';

/// Persistent storage service backed by [SharedPreferences], with an in-memory
/// fallback mode for headless unit and widget tests.
class StorageService {
  static const String storageKey = 'colorflow_saved_progress_v1';

  final SharedPreferences? _prefs;
  SavedProgress _memoryStore = SavedProgress.initial();

  StorageService([this._prefs]);

  /// Creates an in-memory storage instance without accessing platform channels.
  StorageService.inMemory() : _prefs = null;

  /// Loads the platform [SharedPreferences] instance.
  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Reads saved progress from storage, falling back to Level 1 defaults.
  SavedProgress loadProgress() {
    final prefs = _prefs;
    if (prefs != null) {
      try {
        final raw = prefs.getString(storageKey);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw);
          if (decoded is Map) {
            final loaded =
                SavedProgress.fromJson(Map<String, dynamic>.from(decoded));
            _memoryStore = loaded;
            return loaded;
          }
        }
      } catch (_) {
        // Fallback to cached memory store or defaults.
      }
    }
    return _memoryStore;
  }

  /// Persists [progress] to memory and [SharedPreferences] when available.
  Future<void> saveProgress(SavedProgress progress) async {
    _memoryStore = progress;
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.setString(storageKey, jsonEncode(progress.toJson()));
    } catch (_) {
      // Ignore storage write failures cleanly.
    }
  }

  /// Resets saved progress back to Level 1 initial defaults.
  Future<SavedProgress> resetProgress() async {
    final fresh = SavedProgress.initial();
    await saveProgress(fresh);
    return fresh;
  }
}
