import 'dart:math' as math;
import '../models/game_models.dart';
import 'game_engine.dart';

/// Handcrafted preset levels matching the React Native specification.
/// Level 42 includes 2 empty buffer tubes so all 50 levels remain solvable without ads.
const List<LevelData> presetLevels = [
  LevelData(
    levelNumber: 1,
    difficulty: Difficulty.easy,
    tubes: [
      [
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.coral,
        LiquidColor.mint,
      ],
      [
        LiquidColor.mint,
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.coral,
      ],
      [],
    ],
    milestoneText: '1 / 5 Sorts',
    parMoves: 5,
  ),
  LevelData(
    levelNumber: 2,
    difficulty: Difficulty.easy,
    tubes: [
      [
        LiquidColor.coral,
        LiquidColor.yellow,
        LiquidColor.coral,
        LiquidColor.yellow,
      ],
      [
        LiquidColor.yellow,
        LiquidColor.mint,
        LiquidColor.yellow,
        LiquidColor.mint,
      ],
      [
        LiquidColor.mint,
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.coral,
      ],
      [],
    ],
    milestoneText: '2 / 5 Sorts',
    parMoves: 7,
  ),
  LevelData(
    levelNumber: 3,
    difficulty: Difficulty.easy,
    tubes: [
      [
        LiquidColor.violet,
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.yellow,
      ],
      [
        LiquidColor.yellow,
        LiquidColor.violet,
        LiquidColor.coral,
        LiquidColor.mint,
      ],
      [
        LiquidColor.mint,
        LiquidColor.yellow,
        LiquidColor.violet,
        LiquidColor.coral,
      ],
      [
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.yellow,
        LiquidColor.violet,
      ],
      [],
      [],
    ],
    milestoneText: '3 / 5 Sorts',
    parMoves: 9,
  ),
  LevelData(
    levelNumber: 42,
    difficulty: Difficulty.normal,
    tubes: [
      [
        LiquidColor.violet,
        LiquidColor.yellow,
        LiquidColor.mint,
        LiquidColor.coral,
      ],
      [
        LiquidColor.mint,
        LiquidColor.coral,
        LiquidColor.yellow,
        LiquidColor.mint,
      ],
      [
        LiquidColor.violet,
        LiquidColor.yellow,
        LiquidColor.coral,
        LiquidColor.violet,
      ],
      [
        LiquidColor.yellow,
        LiquidColor.mint,
        LiquidColor.coral,
        LiquidColor.violet,
      ],
      [],
      [],
    ],
    milestoneText: '3 / 5 Sorts',
    parMoves: 9,
  ),
  LevelData(
    levelNumber: 43,
    difficulty: Difficulty.normal,
    tubes: [
      [
        LiquidColor.emerald,
        LiquidColor.coral,
        LiquidColor.yellow,
        LiquidColor.mint,
      ],
      [
        LiquidColor.mint,
        LiquidColor.emerald,
        LiquidColor.coral,
        LiquidColor.violet,
      ],
      [
        LiquidColor.violet,
        LiquidColor.yellow,
        LiquidColor.emerald,
        LiquidColor.coral,
      ],
      [
        LiquidColor.coral,
        LiquidColor.mint,
        LiquidColor.violet,
        LiquidColor.yellow,
      ],
      [
        LiquidColor.yellow,
        LiquidColor.violet,
        LiquidColor.mint,
        LiquidColor.emerald,
      ],
      [],
      [],
    ],
    milestoneText: '4 / 5 Sorts',
    parMoves: 12,
  ),
  LevelData(
    levelNumber: 44,
    difficulty: Difficulty.hard,
    tubes: [
      [
        LiquidColor.violet,
        LiquidColor.gold,
        LiquidColor.coral,
        LiquidColor.mint,
      ],
      [
        LiquidColor.mint,
        LiquidColor.yellow,
        LiquidColor.violet,
        LiquidColor.emerald,
      ],
      [
        LiquidColor.emerald,
        LiquidColor.coral,
        LiquidColor.yellow,
        LiquidColor.gold,
      ],
      [
        LiquidColor.gold,
        LiquidColor.violet,
        LiquidColor.mint,
        LiquidColor.coral,
      ],
      [
        LiquidColor.coral,
        LiquidColor.emerald,
        LiquidColor.gold,
        LiquidColor.yellow,
      ],
      [
        LiquidColor.yellow,
        LiquidColor.emerald,
        LiquidColor.violet,
        LiquidColor.mint,
      ],
      [],
      [],
    ],
    milestoneText: '5 / 5 Sorts',
    parMoves: 15,
  ),
];

/// Returns preset level data if available, or deterministically generates a
/// solvable level with 2 empty buffer tubes and no pre-completed tubes.
LevelData getLevelData(int levelNum) {
  for (final preset in presetLevels) {
    if (preset.levelNumber == levelNum) {
      return preset;
    }
  }

  const availableColors = LiquidColor.values;
  final int numColors = levelNum <= 5
      ? 3
      : levelNum <= 18
          ? 4
          : levelNum <= 35
              ? 5
              : 6;
  final activeColors = availableColors.sublist(0, numColors);

  final pool = <LiquidColor>[];
  for (int layer = 0; layer < maxTubeCapacity; layer++) {
    for (int cIdx = 0; cIdx < numColors; cIdx++) {
      final shiftedIdx = (cIdx +
              layer +
              (levelNum % math.max<int>(1, numColors - 1))) %
          numColors;
      pool.add(activeColors[shiftedIdx]);
    }
  }

  for (int step = 0; step < numColors * 3; step++) {
    final a = (math.sin(levelNum * 313 + step * 17).abs() * pool.length)
            .floor() %
        pool.length;
    final b = (math.cos(levelNum * 719 + step * 29).abs() * pool.length)
            .floor() %
        pool.length;
    final tmp = pool[a];
    pool[a] = pool[b];
    pool[b] = tmp;
  }

  final tubes = <List<LiquidColor>>[];
  for (int i = 0; i < numColors; i++) {
    tubes.add(
      pool.sublist(i * maxTubeCapacity, (i + 1) * maxTubeCapacity),
    );
  }

  // Ensure no tube starts with 4 identical colors.
  for (int i = 0; i < numColors; i++) {
    final t = tubes[i];
    if (t.every((c) => c == t[0])) {
      final nextTubeIdx = (i + 1) % numColors;
      final swapColor = tubes[nextTubeIdx][0];
      tubes[nextTubeIdx][0] = t[t.length - 1];
      t[t.length - 1] = swapColor;
    }
  }

  // Append 2 empty buffer tubes.
  tubes.add([]);
  tubes.add([]);

  final difficulty = levelNum > 35
      ? Difficulty.hard
      : levelNum > 15
          ? Difficulty.normal
          : Difficulty.easy;

  return LevelData(
    levelNumber: levelNum,
    difficulty: difficulty,
    tubes: tubes,
    milestoneText: '${((levelNum - 1) % 5) + 1} / 5 Sorts',
    parMoves: numColors * 2 + 2,
  );
}

/// Builds initial [Tube] instances from [levelData].
List<Tube> buildInitialTubes(LevelData levelData) {
  return List<Tube>.generate(
    levelData.tubes.length,
    (index) => Tube(
      id: 'tube-${levelData.levelNumber}-$index',
      colors: List<LiquidColor>.of(levelData.tubes[index]),
      maxCapacity: maxTubeCapacity,
    ),
  );
}
