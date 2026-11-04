import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Platform,
  Animated,
  Easing,
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { Colors } from '../theme/colors';
import {
  Tube,
  ActiveTab,
  LiquidColor,
  VesselSkinId,
  FluidPaletteId,
  PlayerSettings,
} from '../types/game';
import {
  canPour,
  executePour,
  isLevelComplete,
  isTubeCompleted,
  hasValidMoves,
  findBestHintMove,
  calculateStars,
  formatTime,
  cloneTubes,
} from '../logic/gameEngine';
import { getLevelData, buildInitialTubes } from '../logic/levels';
import { TopHUD } from '../components/game/TopHUD';
import { TestTube } from '../components/game/TestTube';
import { FluidStream } from '../components/game/FluidStream';
import { BoosterDeck } from '../components/game/BoosterDeck';
import { HintBanner } from '../components/game/HintBanner';
import { AdBanner } from '../components/navigation/AdBanner';
import { BottomNavBar } from '../components/navigation/BottomNavBar';
import { LevelCompletedModal } from '../components/modals/LevelCompletedModal';
import { audioManager } from '../utils/audio';

interface GameScreenProps {
  activeTab: ActiveTab;
  onSelectTab: (tab: ActiveTab) => void;
  currentLevelNumber: number;
  coins: number;
  undoCount: number;
  equippedVesselSkin: VesselSkinId;
  equippedPalette: FluidPaletteId;
  settings: PlayerSettings;
  extraTubeGrantSignal: number;
  onUpdateUndoCount: (nextCount: number) => void;
  onRequestExtraTubeAd: () => void;
  onRequestRefillUndoAd: () => void;
  onRequestClaim3xAd: (starsEarned: 1 | 2 | 3, baseCoins: number) => void;
  onCompleteNextLevel1x: (starsEarned: 1 | 2 | 3, baseCoins: number) => void;
  onToggleSound: () => void;
  onOpenSettings: () => void;
  onOpenProfile: () => void;
}

interface PouringState {
  sourceIndex: number;
  targetIndex: number;
  color: LiquidColor;
  pouredCount: number;
  isRight: boolean;
  streamX: number;
  streamStartY: number;
  streamInitialEndY: number;
  streamFinalEndY: number;
  txValues: number[];
  tyValues: number[];
  degStrings: string[];
  counterDegStrings: string[];
}

const POUR_KEYFRAMES = [
  0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3,
];

export const GameScreen: React.FC<GameScreenProps> = ({
  activeTab,
  onSelectTab,
  currentLevelNumber,
  coins,
  undoCount,
  equippedVesselSkin,
  equippedPalette,
  settings,
  extraTubeGrantSignal,
  onUpdateUndoCount,
  onRequestExtraTubeAd,
  onRequestRefillUndoAd,
  onRequestClaim3xAd,
  onCompleteNextLevel1x,
  onToggleSound,
  onOpenSettings,
  onOpenProfile,
}) => {
  const [levelData, setLevelData] = useState(() =>
    getLevelData(currentLevelNumber)
  );
  const [tubes, setTubes] = useState<Tube[]>(() =>
    buildInitialTubes(levelData)
  );
  const [selectedTubeIndex, setSelectedTubeIndex] = useState<number | null>(
    null
  );
  const [shakenTubeIndex, setShakenTubeIndex] = useState<number | null>(null);
  const [hintIndices, setHintIndices] = useState<number[]>([]);
  const [moves, setMoves] = useState(0);
  const [timeSeconds, setTimeSeconds] = useState(0);
  const [extraTubeUsed, setExtraTubeUsed] = useState(false);
  const [isCompleted, setIsCompleted] = useState(false);
  const [isDeadlocked, setIsDeadlocked] = useState(false);
  const [history, setHistory] = useState<Tube[][]>([]);
  const [hintMessage, setHintMessage] = useState(
    'Tap any tube to lift and pour matching color!'
  );
  const [isAnimating, setIsAnimating] = useState(false);
  const [pouringState, setPouringState] = useState<PouringState | null>(null);

  const pourPhase = useRef(new Animated.Value(0)).current;
  const shakeAnim = useRef(new Animated.Value(0)).current;
  const timerRef = useRef<any>(null);
  const tubeLayouts = useRef<{ [key: number]: { x: number; y: number } }>({});
  const lastGrantSignalRef = useRef(extraTubeGrantSignal);

  // Initialize or reset level when level changes
  useEffect(() => {
    const data = getLevelData(currentLevelNumber);
    setLevelData(data);
    setTubes(buildInitialTubes(data));
    setSelectedTubeIndex(null);
    setShakenTubeIndex(null);
    setHintIndices([]);
    setMoves(0);
    setTimeSeconds(0);
    setExtraTubeUsed(false);
    setIsCompleted(false);
    setIsDeadlocked(false);
    setHistory([]);
    setPouringState(null);
    setIsAnimating(false);
    pourPhase.setValue(0);
    setHintMessage('Tap any tube to lift and pour matching color!');
  }, [currentLevelNumber]);

  // Listen for Rewarded Ad grant for +1 Extra Tube
  useEffect(() => {
    if (extraTubeGrantSignal > lastGrantSignalRef.current) {
      lastGrantSignalRef.current = extraTubeGrantSignal;
      if (!isCompleted && !extraTubeUsed) {
        const newTube: Tube = {
          id: `extra-tube-${Date.now()}`,
          colors: [],
          maxCapacity: 4,
        };
        setTubes((prev) => [...prev, newTube]);
        setExtraTubeUsed(true);
        setIsDeadlocked(false);
        setHintMessage('Bonus empty tube unlocked! Keep sorting.');
      }
    }
  }, [extraTubeGrantSignal, isCompleted, extraTubeUsed]);

  // Timer loop
  useEffect(() => {
    if (isCompleted) {
      if (timerRef.current) clearInterval(timerRef.current);
      return;
    }

    timerRef.current = setInterval(() => {
      setTimeSeconds((prev) => prev + 1);
    }, 1000);

    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [isCompleted]);

  // Trigger horizontal shake on invalid tube tap
  const triggerInvalidShake = (index: number) => {
    setShakenTubeIndex(index);
    shakeAnim.setValue(0);
    audioManager.playInvalid();

    Animated.sequence([
      Animated.timing(shakeAnim, {
        toValue: -9,
        duration: 50,
        useNativeDriver: false,
      }),
      Animated.timing(shakeAnim, {
        toValue: 9,
        duration: 60,
        useNativeDriver: false,
      }),
      Animated.timing(shakeAnim, {
        toValue: -6,
        duration: 55,
        useNativeDriver: false,
      }),
      Animated.timing(shakeAnim, {
        toValue: 6,
        duration: 50,
        useNativeDriver: false,
      }),
      Animated.timing(shakeAnim, {
        toValue: 0,
        duration: 45,
        useNativeDriver: false,
      }),
    ]).start(() => {
      setShakenTubeIndex(null);
    });
  };

  // Tube selection & pouring mechanics
  const handleTubePress = (index: number) => {
    if (isCompleted || isAnimating) return;

    setHintIndices([]);
    const tappedTube = tubes[index];

    if (selectedTubeIndex === null) {
      if (tappedTube.colors.length === 0) {
        triggerInvalidShake(index);
        setHintMessage('This tube is empty! Select a tube with liquid.');
        return;
      }
      if (isTubeCompleted(tappedTube)) {
        triggerInvalidShake(index);
        setHintMessage('This tube is already sorted and sealed!');
        return;
      }
      setSelectedTubeIndex(index);
      setHintMessage('Now tap a matching or empty tube to pour!');
      return;
    }

    if (selectedTubeIndex === index) {
      setSelectedTubeIndex(null);
      setHintMessage('Tap any tube to lift and pour matching color!');
      return;
    }

    const sourceTube = tubes[selectedTubeIndex];
    const targetTube = tubes[index];

    if (!canPour(sourceTube, targetTube)) {
      triggerInvalidShake(index);
      if (targetTube.colors.length >= targetTube.maxCapacity) {
        setHintMessage('That tube is full! Choose an empty or matching tube.');
      } else {
        setHintMessage(
          "Top colors don't match! Tap the lifted tube to cancel selection."
        );
      }
      return;
    }

    runFluidPourAnimation(selectedTubeIndex, index);
  };

  const runFluidPourAnimation = (sourceIdx: number, targetIdx: number) => {
    const previewResult = executePour(tubes, sourceIdx, targetIdx);
    if (!previewResult) return;

    const { pouredCount, colorPoured, newTubes } = previewResult;
    const targetTube = tubes[targetIdx];

    setIsAnimating(true);
    setHintMessage('Pouring liquid...');

    const sourceLayout = tubeLayouts.current[sourceIdx] || {
      x: sourceIdx * 64,
      y: 0,
    };
    const targetLayout = tubeLayouts.current[targetIdx] || {
      x: targetIdx * 64,
      y: 0,
    };

    const dx = targetLayout.x - sourceLayout.x;
    const isRight = dx >= 0;

    const tubeWidth = 54;
    const tubeHeight = 190;
    const topIndicatorOffset = 18;
    const segmentHeight = (tubeHeight - 10) / targetTube.maxCapacity;

    const sourceCenterX = sourceLayout.x + tubeWidth / 2;
    const sourceCenterY = sourceLayout.y + topIndicatorOffset + tubeHeight / 2;

    const Lx = isRight ? 25 : -25;
    const Ly = -92;

    const pourLipX = targetLayout.x + tubeWidth / 2;
    const pourLipY = targetLayout.y + topIndicatorOffset - 8;

    const startLipX = sourceCenterX + Lx;
    const startLipY = sourceCenterY - 18 + Ly;
    const restLipX = sourceCenterX + Lx;
    const restLipY = sourceCenterY + Ly;

    const txValues: number[] = [];
    const tyValues: number[] = [];
    const degStrings: string[] = [];
    const counterDegStrings: string[] = [];

    for (const s of POUR_KEYFRAMES) {
      let deg = 0;
      let lipX = restLipX;
      let lipY = restLipY;

      if (s <= 1) {
        const u = s;
        const ease = u * u * (3 - 2 * u);
        deg = (isRight ? 1 : -1) * 58 * ease;
        lipX = startLipX + (pourLipX - startLipX) * ease;
        lipY =
          startLipY +
          (pourLipY - startLipY) * ease -
          18 * Math.sin(Math.PI * u);
      } else if (s <= 2) {
        const u = s - 1;
        deg = (isRight ? 1 : -1) * (58 + 20 * u);
        lipX = pourLipX;
        lipY = pourLipY;
      } else {
        const u = s - 2;
        const ease = u * u * (3 - 2 * u);
        deg = (isRight ? 1 : -1) * 78 * (1 - ease);
        lipX = pourLipX + (restLipX - pourLipX) * ease;
        lipY =
          pourLipY +
          (restLipY - pourLipY) * ease -
          12 * Math.sin(Math.PI * u);
      }

      const rad = (deg * Math.PI) / 180;
      const rotLipX = Lx * Math.cos(rad) - Ly * Math.sin(rad);
      const rotLipY = Lx * Math.sin(rad) + Ly * Math.cos(rad);

      const tx = lipX - sourceCenterX - rotLipX;
      const ty = lipY - sourceCenterY - rotLipY;

      txValues.push(tx);
      tyValues.push(ty);
      degStrings.push(`${deg.toFixed(2)}deg`);
      counterDegStrings.push(`${(-deg).toFixed(2)}deg`);
    }

    const targetInnerBottomY =
      targetLayout.y + topIndicatorOffset + tubeHeight - 2;
    const initialTargetCount = targetTube.colors.length;
    const finalTargetCount = initialTargetCount + pouredCount;

    const streamInitialEndY =
      targetInnerBottomY - initialTargetCount * segmentHeight;
    const streamFinalEndY =
      targetInnerBottomY - finalTargetCount * segmentHeight;

    pourPhase.setValue(0);

    setPouringState({
      sourceIndex: sourceIdx,
      targetIndex: targetIdx,
      color: colorPoured,
      pouredCount,
      isRight,
      streamX: pourLipX,
      streamStartY: pourLipY,
      streamInitialEndY,
      streamFinalEndY,
      txValues,
      tyValues,
      degStrings,
      counterDegStrings,
    });

    const pourDuration = 380 + (pouredCount - 1) * 110;
    const startFillRatio = initialTargetCount / targetTube.maxCapacity;
    const endFillRatio = finalTargetCount / targetTube.maxCapacity;

    Animated.timing(pourPhase, {
      toValue: 1,
      duration: 260,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start(() => {
      audioManager.playPour(pourDuration, startFillRatio, endFillRatio);

      Animated.timing(pourPhase, {
        toValue: 2,
        duration: pourDuration,
        easing: Easing.inOut(Easing.quad),
        useNativeDriver: false,
      }).start(() => {
        Animated.timing(pourPhase, {
          toValue: 3,
          duration: 260,
          easing: Easing.inOut(Easing.cubic),
          useNativeDriver: false,
        }).start(() => {
          setHistory((prev) => [...prev, cloneTubes(tubes)]);
          setTubes(newTubes);
          setMoves((prev) => prev + 1);
          setSelectedTubeIndex(null);
          setPouringState(null);
          setIsAnimating(false);

          const targetNowCompleted = isTubeCompleted(newTubes[targetIdx]);
          const levelNowCompleted = isLevelComplete(newTubes);

          if (levelNowCompleted) {
            audioManager.playWin();
            setIsCompleted(true);
            setIsDeadlocked(false);
            setHintMessage('Flawless victory! Level completed!');
          } else if (!hasValidMoves(newTubes)) {
            audioManager.playInvalid();
            setIsDeadlocked(true);
            setHintMessage(
              'No more valid moves! Use Undo, +1 Tube [AD], or Restart.'
            );
          } else if (targetNowCompleted) {
            audioManager.playTubeComplete();
            setIsDeadlocked(false);
            setHintMessage('Tube sealed! Awesome sort!');
          } else {
            setIsDeadlocked(false);
            setHintMessage('Smooth pour! Tap HINT if you need a clue.');
          }
        });
      });
    });
  };

  // Booster: Undo
  const handleUndo = () => {
    if (
      history.length === 0 ||
      undoCount <= 0 ||
      isCompleted ||
      isAnimating
    )
      return;

    const previousTubes = history[history.length - 1];
    setHistory((prev) => prev.slice(0, prev.length - 1));
    setTubes(previousTubes);
    onUpdateUndoCount(undoCount - 1);
    setSelectedTubeIndex(null);
    setHintIndices([]);
    setIsDeadlocked(!hasValidMoves(previousTubes));
    setHintMessage('Move undone!');
  };

  // Booster: +1 Tube (triggers Rewarded Ad modal, max 1 per level)
  const handleAddTube = () => {
    if (isCompleted || isAnimating || extraTubeUsed) return;
    onRequestExtraTubeAd();
  };

  // Booster: Restart
  const handleRestart = () => {
    if (isAnimating) return;
    setTubes(buildInitialTubes(levelData));
    setSelectedTubeIndex(null);
    setShakenTubeIndex(null);
    setHintIndices([]);
    setMoves(0);
    setTimeSeconds(0);
    setIsCompleted(false);
    setIsDeadlocked(false);
    setHistory([]);
    setPouringState(null);
    pourPhase.setValue(0);
    setHintMessage('Level restarted. Good luck!');
  };

  // AI Hint Solver
  const handleRequestHint = () => {
    if (isCompleted || isAnimating) return;
    const suggestion = findBestHintMove(tubes);
    if (!suggestion) {
      setIsDeadlocked(true);
      setHintMessage(
        'No productive moves left! Try Undo, +1 Tube [AD], or Restart.'
      );
      return;
    }
    setHintIndices([suggestion.sourceIndex, suggestion.targetIndex]);
    setSelectedTubeIndex(suggestion.sourceIndex);
    setHintMessage(`Hint: ${suggestion.reason}`);
  };

  const completedTubesCount = tubes.filter(isTubeCompleted).length;
  const totalColorGroups = Math.max(
    1,
    Math.round(tubes.reduce((acc, t) => acc + t.colors.length, 0) / 4)
  );
  const liveMilestoneText = `${completedTubesCount} / ${totalColorGroups} Sorts`;

  const starsEarned = calculateStars(moves, levelData.parMoves || 10);
  const baseCoinsEarned = starsEarned === 3 ? 65 : starsEarned === 2 ? 50 : 40;

  const animTranslateX = pouringState
    ? pourPhase.interpolate({
        inputRange: POUR_KEYFRAMES,
        outputRange: pouringState.txValues,
      })
    : undefined;

  const animTranslateY = pouringState
    ? pourPhase.interpolate({
        inputRange: POUR_KEYFRAMES,
        outputRange: pouringState.tyValues,
      })
    : undefined;

  const tiltAngle = pouringState
    ? pourPhase.interpolate({
        inputRange: POUR_KEYFRAMES,
        outputRange: pouringState.degStrings,
      })
    : undefined;

  const counterTiltAngle = pouringState
    ? pourPhase.interpolate({
        inputRange: POUR_KEYFRAMES,
        outputRange: pouringState.counterDegStrings,
      })
    : undefined;

  return (
    <SafeAreaView style={styles.safeContainer}>
      <StatusBar style="dark" />

      {/* Top HUD with brand, coins, settings, level badge */}
      <TopHUD
        levelNumber={levelData.levelNumber}
        difficulty={levelData.difficulty}
        milestoneText={liveMilestoneText}
        coins={coins}
        isSoundEnabled={settings.soundEnabled}
        onToggleSound={onToggleSound}
        onOpenSettings={onOpenSettings}
        onOpenProfile={onOpenProfile}
      />

      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Central Arena with Test Tubes and Fluid Pouring Stream */}
        <View style={styles.arenaContainer}>
          <View style={styles.tubesRow}>
            {pouringState && (
              <FluidStream
                x={pouringState.streamX}
                startY={pouringState.streamStartY}
                initialEndY={pouringState.streamInitialEndY}
                finalEndY={pouringState.streamFinalEndY}
                color={pouringState.color}
                pourPhase={pourPhase}
                paletteId={equippedPalette}
              />
            )}

            {tubes.map((tube, idx) => {
              const isSource = pouringState?.sourceIndex === idx;
              const isTarget = pouringState?.targetIndex === idx;
              const isShaken = shakenTubeIndex === idx;
              const isHint = hintIndices.includes(idx);

              return (
                <TestTube
                  key={tube.id}
                  tube={tube}
                  index={idx}
                  isSelected={selectedTubeIndex === idx}
                  onPress={handleTubePress}
                  onLayout={(e) => {
                    tubeLayouts.current[idx] = {
                      x: e.nativeEvent.layout.x,
                      y: e.nativeEvent.layout.y,
                    };
                  }}
                  vesselSkin={equippedVesselSkin}
                  paletteId={equippedPalette}
                  colorBlindMode={settings.colorBlindMode}
                  isHintHighlighted={isHint}
                  isPouringSource={isSource}
                  isPouringTarget={isTarget}
                  pouredCount={pouringState ? pouringState.pouredCount : 1}
                  isRight={pouringState ? pouringState.isRight : true}
                  pourPhase={isSource || isTarget ? pourPhase : undefined}
                  animTranslateX={isSource ? animTranslateX : undefined}
                  animTranslateY={isSource ? animTranslateY : undefined}
                  tiltAngle={isSource ? tiltAngle : undefined}
                  counterTiltAngle={isSource ? counterTiltAngle : undefined}
                  fillingColor={
                    isTarget && pouringState ? pouringState.color : null
                  }
                  shakeAnim={isShaken ? shakeAnim : undefined}
                />
              );
            })}
          </View>

          {/* Wooden / Glass Shelf bar */}
          <View style={styles.shelfBar}>
            <View style={styles.shelfTopHighlight} />
          </View>
        </View>

        {/* Booster Deck */}
        <BoosterDeck
          undoCount={undoCount}
          extraTubeUsed={extraTubeUsed}
          onUndo={handleUndo}
          onRefillUndoAd={onRequestRefillUndoAd}
          onAddTube={handleAddTube}
          onRestart={handleRestart}
        />

        {/* Dynamic Interactive Hint & Deadlock Banner */}
        <HintBanner
          message={hintMessage}
          isDeadlocked={isDeadlocked}
          onRequestHint={handleRequestHint}
        />

        {/* Ad Banner */}
        <AdBanner />
      </ScrollView>

      {/* Bottom Navigation */}
      <BottomNavBar activeTab={activeTab} onSelectTab={onSelectTab} />

      {/* Level Completed Victory Modal */}
      <LevelCompletedModal
        visible={isCompleted}
        levelNumber={levelData.levelNumber}
        moves={moves}
        timeFormatted={formatTime(timeSeconds)}
        starsEarned={starsEarned}
        coinsEarned={baseCoinsEarned}
        onClaim3x={() => onRequestClaim3xAd(starsEarned, baseCoinsEarned)}
        onNextLevel={() => onCompleteNextLevel1x(starsEarned, baseCoinsEarned)}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeContainer: {
    flex: 1,
    backgroundColor: Colors.canvas,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'space-between',
    paddingBottom: 6,
  },
  arenaContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 18,
    marginHorizontal: 16,
    position: 'relative',
    minHeight: 270,
  },
  tubesRow: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'center',
    flexWrap: 'wrap',
    gap: 10,
    zIndex: 2,
    minHeight: 230,
    position: 'relative',
  },
  shelfBar: {
    width: '92%',
    maxWidth: 420,
    height: 14,
    borderRadius: 7,
    backgroundColor: '#DFDCF5',
    borderWidth: 1,
    borderColor: '#CCC8EE',
    marginTop: -8,
    zIndex: 1,
    overflow: 'hidden',
    ...Platform.select({
      web: {
        boxShadow: '0 8px 16px rgba(30, 30, 60, 0.08)',
      } as any,
    }),
  },
  shelfTopHighlight: {
    height: 3,
    backgroundColor: 'rgba(255, 255, 255, 0.8)',
  },
});
