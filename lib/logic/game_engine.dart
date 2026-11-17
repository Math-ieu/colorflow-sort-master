import 'dart:math' as math;
import '../models/game_models.dart';

const int maxTubeCapacity = 4;

/// Deep clones the tubes list to preserve immutable history for undo.
List<Tube> cloneTubes(List<Tube> tubes) {
  return tubes.map((t) => t.clone()).toList();
}

/// Checks if a single tube is completely filled with a single uniform color (sealed).
bool isTubeCompleted(Tube tube) {
  if (tube.colors.length != tube.maxCapacity || tube.colors.isEmpty) {
    return false;
  }
  final first = tube.colors[0];
  return tube.colors.every((c) => c == first);
}

/// Checks whether liquid can be poured from [source] tube to [target] tube.
bool canPour(Tube source, Tube target) {
  if (source.id == target.id) return false;
  if (source.colors.isEmpty) return false;
  if (isTubeCompleted(source)) return false;
  if (target.colors.length >= target.maxCapacity) return false;

  // Empty target tube can always receive liquid.
  if (target.colors.isEmpty) return true;

  return source.colors.last == target.colors.last;
}

/// Executes a pour move between [sourceIndex] and [targetIndex].
/// Moves contiguous units of the matching top color up to available capacity.
/// Returns `null` if indices are out of bounds or the pour is not allowed.
PourResult? executePour(
  List<Tube> tubes,
  int sourceIndex,
  int targetIndex,
) {
  if (sourceIndex < 0 ||
      sourceIndex >= tubes.length ||
      targetIndex < 0 ||
      targetIndex >= tubes.length) {
    return null;
  }

  final source = tubes[sourceIndex];
  final target = tubes[targetIndex];
  if (!canPour(source, target)) {
    return null;
  }

  final nextTubes = cloneTubes(tubes);
  final nextSource = nextTubes[sourceIndex];
  final nextTarget = nextTubes[targetIndex];

  final colorToPour = nextSource.colors.last;
  final availableSpace = nextTarget.maxCapacity - nextTarget.colors.length;

  int consecutiveCount = 0;
  for (int i = nextSource.colors.length - 1; i >= 0; i--) {
    if (nextSource.colors[i] == colorToPour) {
      consecutiveCount++;
    } else {
      break;
    }
  }

  final amountToPour = math.min(consecutiveCount, availableSpace);

  for (int i = 0; i < amountToPour; i++) {
    nextSource.colors.removeLast();
    nextTarget.colors.add(colorToPour);
  }

  return PourResult(
    newTubes: nextTubes,
    pouredCount: amountToPour,
    colorPoured: colorToPour,
  );
}

/// Checks if all tubes are either completely empty or filled with a single color.
bool isLevelComplete(List<Tube> tubes) {
  if (tubes.isEmpty) return false;

  int filledTubesCount = 0;
  for (final tube in tubes) {
    if (tube.colors.isEmpty) {
      continue;
    }
    if (tube.colors.length != tube.maxCapacity) {
      return false;
    }
    final firstColor = tube.colors[0];
    if (!tube.colors.every((c) => c == firstColor)) {
      return false;
    }
    filledTubesCount++;
  }

  return filledTubesCount > 0;
}

/// Checks if the player has at least one meaningful valid move left.
bool hasValidMoves(List<Tube> tubes) {
  if (isLevelComplete(tubes)) return false;

  for (int i = 0; i < tubes.length; i++) {
    final src = tubes[i];
    if (src.colors.isEmpty || isTubeCompleted(src)) continue;

    final isSrcMonochrome = src.colors.every((c) => c == src.colors[0]);

    for (int j = 0; j < tubes.length; j++) {
      if (i == j) continue;
      final dst = tubes[j];
      if (!canPour(src, dst)) continue;

      // Pouring a monochromatic partial tube into an empty tube is a redundant no-op.
      if (isSrcMonochrome && dst.colors.isEmpty) {
        continue;
      }

      return true;
    }
  }

  return false;
}

/// AI Hint Solver: Finds the highest-value next move on the board.
HintMove? findBestHintMove(List<Tube> tubes) {
  HintMove? bestMove;
  int? bestScore;

  for (int i = 0; i < tubes.length; i++) {
    final src = tubes[i];
    if (src.colors.isEmpty || isTubeCompleted(src)) continue;

    final topColor = src.colors.last;
    int topGroupCount = 0;
    for (int k = src.colors.length - 1; k >= 0; k--) {
      if (src.colors[k] == topColor) {
        topGroupCount++;
      } else {
        break;
      }
    }

    final isSrcMonochrome = topGroupCount == src.colors.length;

    for (int j = 0; j < tubes.length; j++) {
      if (i == j) continue;
      final dst = tubes[j];
      if (!canPour(src, dst)) continue;

      // Avoid pointless move of single-color stack into an empty tube.
      if (isSrcMonochrome && dst.colors.isEmpty) continue;

      final availableSpace = dst.maxCapacity - dst.colors.length;
      int score = 10;
      String reason = 'Pour Tube #${i + 1} into Tube #${j + 1}';

      if (dst.colors.isNotEmpty &&
          dst.colors.every((c) => c == topColor) &&
          dst.colors.length + math.min(topGroupCount, availableSpace) ==
              dst.maxCapacity) {
        score = 100;
        reason = 'Seal Tube #${j + 1} by pouring from Tube #${i + 1}!';
      } else if (dst.colors.isNotEmpty && availableSpace >= topGroupCount) {
        score = 80 + topGroupCount * 3;
        reason = 'Uncover new color in Tube #${i + 1} → Tube #${j + 1}';
      } else if (dst.colors.isEmpty &&
          !isSrcMonochrome &&
          availableSpace >= topGroupCount) {
        score = 50 + topGroupCount * 2;
        reason =
            'Move ${topColor.key.toUpperCase()} from Tube #${i + 1} to empty Tube #${j + 1}';
      } else if (dst.colors.isNotEmpty) {
        score = 35;
      }

      if (bestScore == null || score > bestScore) {
        bestScore = score;
        bestMove = HintMove(
          sourceIndex: i,
          targetIndex: j,
          reason: reason,
        );
      }
    }
  }

  return bestMove;
}

/// Calculates 1, 2, or 3 stars earned based on move count vs level par.
int calculateStars(int moves, {int parMoves = 10}) {
  if (moves <= parMoves) return 3;
  if (moves <= (parMoves * 1.45).ceil()) return 2;
  return 1;
}

/// Base coin reward for completing a level with [stars] rating.
int calculateBaseCoins(int stars) {
  if (stars == 3) return 65;
  if (stars == 2) return 50;
  return 40;
}

/// Formats elapsed seconds into zero-padded `MM:SS` string.
String formatTime(int seconds) {
  final safe = seconds < 0 ? 0 : seconds;
  final mins = safe ~/ 60;
  final secs = safe % 60;
  return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
