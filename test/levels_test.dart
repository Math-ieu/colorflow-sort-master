import 'dart:collection';

import 'package:colorflow_sort_master/logic/game_engine.dart';
import 'package:colorflow_sort_master/logic/levels.dart';
import 'package:colorflow_sort_master/models/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

String _canonicalKey(List<Tube> tubes) {
  final parts = tubes.map((t) => t.colors.map((c) => c.key).join(',')).toList()
    ..sort();
  return parts.join('|');
}

bool _isSolvableByBfs(List<Tube> startTubes, {int maxVisitedStates = 15000}) {
  if (isLevelComplete(startTubes)) return true;

  final queue = Queue<List<Tube>>()..add(cloneTubes(startTubes));
  final visited = <String>{_canonicalKey(startTubes)};

  while (queue.isNotEmpty && visited.length < maxVisitedStates) {
    final current = queue.removeFirst();

    for (int i = 0; i < current.length; i++) {
      final src = current[i];
      if (src.colors.isEmpty || isTubeCompleted(src)) continue;
      final isSrcMonochrome = src.colors.every((c) => c == src.colors.first);

      for (int j = 0; j < current.length; j++) {
        if (i == j) continue;
        final dst = current[j];
        if (isSrcMonochrome && dst.colors.isEmpty) continue;

        final result = executePour(current, i, j);
        if (result == null) continue;

        if (isLevelComplete(result.newTubes)) {
          return true;
        }

        final key = _canonicalKey(result.newTubes);
        if (visited.add(key)) {
          queue.add(result.newTubes);
        }
      }
    }
  }

  return false;
}

void main() {
  group('Levels Generator & Presets', () {
    test('all 50 levels are valid, non-completed, playable, and balanced', () {
      for (int lvl = 1; lvl <= 50; lvl++) {
        final data = getLevelData(lvl);
        expect(data.levelNumber, lvl);
        expect(data.parMoves, greaterThan(0));
        expect(data.milestoneText, isNotEmpty);

        final tubes = buildInitialTubes(data);
        expect(tubes.length, greaterThanOrEqualTo(3));

        // Unique IDs and exact capacity
        final ids = tubes.map((t) => t.id).toSet();
        expect(
          ids.length,
          tubes.length,
          reason: 'Level $lvl tube IDs must be unique',
        );
        expect(
          tubes.every((t) => t.maxCapacity == maxTubeCapacity),
          isTrue,
          reason: 'Level $lvl tubes must use maxCapacity=$maxTubeCapacity',
        );

        // Must not start completed, must have valid moves, no pre-sealed tube
        expect(
          isLevelComplete(tubes),
          isFalse,
          reason: 'Level $lvl should not start completed',
        );
        expect(
          hasValidMoves(tubes),
          isTrue,
          reason: 'Level $lvl must have valid opening moves',
        );
        for (final tube in tubes) {
          expect(
            isTubeCompleted(tube),
            isFalse,
            reason: 'Level $lvl should not have a pre-completed tube',
          );
        }

        // Exact segment count: 4 segments per color present
        final counts = <LiquidColor, int>{};
        int totalSegments = 0;
        for (final tube in tubes) {
          for (final color in tube.colors) {
            counts[color] = (counts[color] ?? 0) + 1;
            totalSegments++;
          }
        }
        expect(
          counts.isNotEmpty,
          isTrue,
          reason: 'Level $lvl must contain colors',
        );
        for (final entry in counts.entries) {
          expect(
            entry.value,
            maxTubeCapacity,
            reason:
                'Level $lvl color ${entry.key.key} must have $maxTubeCapacity segments',
          );
        }
        expect(totalSegments, counts.length * maxTubeCapacity);

        final emptyTubes = tubes.where((t) => t.colors.isEmpty).length;
        expect(
          emptyTubes,
          greaterThanOrEqualTo(1),
          reason: 'Level $lvl must have at least 1 empty tube',
        );
      }
    });

    test('Level 42 has 2 empty buffer tubes and is mathematically solvable',
        () {
      final level42 = getLevelData(42);
      expect(level42.levelNumber, 42);
      expect(level42.difficulty, Difficulty.normal);
      expect(level42.parMoves, 9);

      final tubes = buildInitialTubes(level42);
      expect(tubes.length, 6);
      expect(tubes.where((t) => t.colors.isEmpty).length, 2);
      expect(tubes.where((t) => t.colors.isNotEmpty).length, 4);

      expect(
        _isSolvableByBfs(tubes),
        isTrue,
        reason: 'Level 42 must be solvable with 2 empty tubes',
      );
    });

    test('preset levels 1, 2, 3, 42, 43, 44 match contract metadata', () {
      expect(presetLevels.map((l) => l.levelNumber),
          containsAll([1, 2, 3, 42, 43, 44]));

      final l1 = getLevelData(1);
      expect(l1.difficulty, Difficulty.easy);
      expect(l1.tubes.length, 3);
      expect(l1.parMoves, 5);
      expect(_isSolvableByBfs(buildInitialTubes(l1)), isTrue);

      final l2 = getLevelData(2);
      expect(l2.difficulty, Difficulty.easy);
      expect(l2.tubes.length, 4);
      expect(l2.parMoves, 7);
      expect(_isSolvableByBfs(buildInitialTubes(l2)), isTrue);

      final l3 = getLevelData(3);
      expect(l3.difficulty, Difficulty.easy);
      expect(l3.tubes.length, 6);
      expect(l3.parMoves, 9);

      final l43 = getLevelData(43);
      expect(l43.difficulty, Difficulty.normal);
      expect(l43.tubes.length, 7);
      expect(l43.parMoves, 12);

      final l44 = getLevelData(44);
      expect(l44.difficulty, Difficulty.hard);
      expect(l44.tubes.length, 8);
      expect(l44.parMoves, 15);
    });
  });
}
