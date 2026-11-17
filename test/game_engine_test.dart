import 'package:colorflow_sort_master/logic/game_engine.dart';
import 'package:colorflow_sort_master/logic/levels.dart';
import 'package:colorflow_sort_master/models/game_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Engine', () {
    test(
      'canPour correctly validates allowed and forbidden moves (including sealed tubes)',
      () {
        const tubeFullCoral = Tube(
          id: '1',
          colors: <LiquidColor>[
            LiquidColor.coral,
            LiquidColor.coral,
            LiquidColor.coral,
            LiquidColor.coral,
          ],
          maxCapacity: 4,
        );
        const tubeMixedTopCoral = Tube(
          id: '1b',
          colors: <LiquidColor>[
            LiquidColor.mint,
            LiquidColor.coral,
            LiquidColor.coral,
          ],
          maxCapacity: 4,
        );
        const tubeWithMint = Tube(
          id: '2',
          colors: <LiquidColor>[LiquidColor.mint],
          maxCapacity: 4,
        );
        const tubeWithCoralSpace = Tube(
          id: '3',
          colors: <LiquidColor>[LiquidColor.coral, LiquidColor.coral],
          maxCapacity: 4,
        );
        const tubeEmpty = Tube(
          id: '4',
          colors: <LiquidColor>[],
          maxCapacity: 4,
        );

        // Can pour into empty tube
        expect(canPour(tubeWithMint, tubeEmpty), isTrue);

        // Can pour mixed tube with top coral into matching coral tube with space
        expect(canPour(tubeMixedTopCoral, tubeWithCoralSpace), isTrue);

        // Cannot pour FROM an already completed (4/4) sealed tube
        expect(canPour(tubeFullCoral, tubeEmpty), isFalse);

        // Cannot pour into full tube
        expect(canPour(tubeWithMint, tubeFullCoral), isFalse);

        // Cannot pour mismatched color
        expect(canPour(tubeWithMint, tubeWithCoralSpace), isFalse);

        // Cannot pour from empty tube
        expect(canPour(tubeEmpty, tubeWithCoralSpace), isFalse);

        // Cannot pour into itself
        expect(canPour(tubeWithMint, tubeWithMint), isFalse);
      },
    );

    test(
      'executePour transfers consecutive matching segments up to capacity',
      () {
        const tubes = <Tube>[
          Tube(
            id: '1',
            colors: <LiquidColor>[
              LiquidColor.yellow,
              LiquidColor.coral,
              LiquidColor.coral,
            ],
            maxCapacity: 4,
          ),
          Tube(
            id: '2',
            colors: <LiquidColor>[LiquidColor.coral],
            maxCapacity: 4,
          ),
        ];

        final result = executePour(tubes, 0, 1);
        expect(result, isNotNull);
        expect(result!.pouredCount, 2);
        expect(result.colorPoured, LiquidColor.coral);
        expect(result.newTubes[0].colors, <LiquidColor>[LiquidColor.yellow]);
        expect(result.newTubes[1].colors, <LiquidColor>[
          LiquidColor.coral,
          LiquidColor.coral,
          LiquidColor.coral,
        ]);

        // Input tubes remain untouched (immutable update)
        expect(tubes[0].colors.length, 3);
        expect(tubes[1].colors.length, 1);

        // Caps transferred units to available space in target tube
        const cappedTubes = <Tube>[
          Tube(
            id: 'a',
            colors: <LiquidColor>[
              LiquidColor.mint,
              LiquidColor.coral,
              LiquidColor.coral,
              LiquidColor.coral,
            ],
          ),
          Tube(
            id: 'b',
            colors: <LiquidColor>[
              LiquidColor.yellow,
              LiquidColor.yellow,
              LiquidColor.coral,
            ],
          ),
        ];
        final cappedResult = executePour(cappedTubes, 0, 1);
        expect(cappedResult, isNotNull);
        expect(cappedResult!.pouredCount, 1);
        expect(cappedResult.newTubes[0].colors, <LiquidColor>[
          LiquidColor.mint,
          LiquidColor.coral,
          LiquidColor.coral,
        ]);
        expect(cappedResult.newTubes[1].colors.length, 4);

        // Invalid and out-of-bounds pours return null
        expect(executePour(tubes, 1, 0), isNotNull);
        expect(executePour(tubes, 0, 0), isNull);
        expect(executePour(tubes, -1, 1), isNull);
        expect(executePour(tubes, 0, 5), isNull);
      },
    );

    test('isLevelComplete detects completed and incomplete levels', () {
      const incompleteTubes = <Tube>[
        Tube(
          id: '1',
          colors: <LiquidColor>[
            LiquidColor.coral,
            LiquidColor.mint,
            LiquidColor.coral,
            LiquidColor.mint,
          ],
        ),
        Tube(
          id: '2',
          colors: <LiquidColor>[
            LiquidColor.mint,
            LiquidColor.coral,
            LiquidColor.mint,
            LiquidColor.coral,
          ],
        ),
        Tube(id: '3', colors: <LiquidColor>[]),
      ];
      expect(isLevelComplete(incompleteTubes), isFalse);

      const partialSingleColor = <Tube>[
        Tube(
          id: '1',
          colors: <LiquidColor>[LiquidColor.coral, LiquidColor.coral],
        ),
        Tube(
          id: '2',
          colors: <LiquidColor>[LiquidColor.coral, LiquidColor.coral],
        ),
      ];
      expect(isLevelComplete(partialSingleColor), isFalse);

      const allEmpty = <Tube>[
        Tube(id: '1', colors: <LiquidColor>[]),
      ];
      expect(isLevelComplete(allEmpty), isFalse);
      expect(isLevelComplete(const <Tube>[]), isFalse);

      const completedTubes = <Tube>[
        Tube(
          id: '1',
          colors: <LiquidColor>[
            LiquidColor.coral,
            LiquidColor.coral,
            LiquidColor.coral,
            LiquidColor.coral,
          ],
        ),
        Tube(
          id: '2',
          colors: <LiquidColor>[
            LiquidColor.mint,
            LiquidColor.mint,
            LiquidColor.mint,
            LiquidColor.mint,
          ],
        ),
        Tube(id: '3', colors: <LiquidColor>[]),
      ];
      expect(isLevelComplete(completedTubes), isTrue);
    });

    test(
      'hasValidMoves and findBestHintMove detect deadlocks and optimal moves',
      () {
        const deadlockedBoard = <Tube>[
          Tube(
            id: '1',
            colors: <LiquidColor>[
              LiquidColor.coral,
              LiquidColor.mint,
              LiquidColor.yellow,
              LiquidColor.violet,
            ],
          ),
          Tube(
            id: '2',
            colors: <LiquidColor>[
              LiquidColor.mint,
              LiquidColor.yellow,
              LiquidColor.violet,
              LiquidColor.coral,
            ],
          ),
        ];
        expect(hasValidMoves(deadlockedBoard), isFalse);
        expect(findBestHintMove(deadlockedBoard), isNull);

        // Moving monochromatic partial tube into empty tube is redundant
        const redundantOnlyBoard = <Tube>[
          Tube(
            id: '1',
            colors: <LiquidColor>[LiquidColor.coral, LiquidColor.coral],
          ),
          Tube(id: '2', colors: <LiquidColor>[]),
        ];
        expect(hasValidMoves(redundantOnlyBoard), isFalse);
        expect(findBestHintMove(redundantOnlyBoard), isNull);

        const playableBoard = <Tube>[
          Tube(
            id: '1',
            colors: <LiquidColor>[LiquidColor.mint, LiquidColor.coral],
          ),
          Tube(
            id: '2',
            colors: <LiquidColor>[
              LiquidColor.coral,
              LiquidColor.coral,
              LiquidColor.coral,
            ],
          ),
          Tube(id: '3', colors: <LiquidColor>[]),
        ];
        expect(hasValidMoves(playableBoard), isTrue);
        final hint = findBestHintMove(playableBoard);
        expect(hint, isNotNull);
        expect(hint!.sourceIndex, 0);
        expect(hint.targetIndex, 1);
        expect(hint.reason, contains('Seal Tube #2'));
      },
    );

    test('calculateStars and calculateBaseCoins compute rewards accurately',
        () {
      expect(calculateStars(8, parMoves: 10), 3);
      expect(calculateStars(10, parMoves: 10), 3);
      expect(calculateStars(13, parMoves: 10), 2);
      expect(calculateStars(15, parMoves: 10), 2);
      expect(calculateStars(16, parMoves: 10), 1);
      expect(calculateStars(20, parMoves: 10), 1);

      expect(calculateBaseCoins(3), 65);
      expect(calculateBaseCoins(2), 50);
      expect(calculateBaseCoins(1), 40);
    });

    test(
      'getLevelData generates valid non-completed puzzles for levels 1..50',
      () {
        for (int lvl = 1; lvl <= 50; lvl++) {
          final data = getLevelData(lvl);
          final tubes = buildInitialTubes(data);
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
        }
      },
    );

    test('cloneTubes creates a deep copy for immutable history', () {
      const tubes = <Tube>[
        Tube(
          id: '1',
          colors: <LiquidColor>[LiquidColor.coral, LiquidColor.mint],
        ),
      ];
      final cloned = cloneTubes(tubes);
      cloned[0].colors.add(LiquidColor.yellow);
      expect(tubes[0].colors.length, 2);
      expect(cloned[0].colors.length, 3);
    });

    test('formatTime formats seconds into MM:SS', () {
      expect(formatTime(0), '00:00');
      expect(formatTime(84), '01:24');
      expect(formatTime(359), '05:59');
      expect(formatTime(600), '10:00');
    });
  });
}
