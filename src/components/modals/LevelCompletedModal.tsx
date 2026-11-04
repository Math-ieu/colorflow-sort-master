import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Platform,
  Animated,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { Tactile3DButton } from '../common/Tactile3DButton';
import { audioManager } from '../../utils/audio';

interface LevelCompletedModalProps {
  visible: boolean;
  levelNumber: number;
  moves: number;
  timeFormatted: string;
  starsEarned?: 1 | 2 | 3;
  coinsEarned?: number;
  onClaim3x: () => void;
  onNextLevel: () => void;
}

const CONFETTI_PIECES = [
  { left: '8%', color: '#FF6B6B', delay: 0, size: 9 },
  { left: '18%', color: '#4ECDC4', delay: 120, size: 7 },
  { left: '28%', color: '#FFE66D', delay: 60, size: 10 },
  { left: '40%', color: '#9B5DE5', delay: 180, size: 8 },
  { left: '52%', color: '#10B981', delay: 40, size: 9 },
  { left: '64%', color: '#F59E0B', delay: 150, size: 8 },
  { left: '76%', color: '#FF6B6B', delay: 90, size: 10 },
  { left: '88%', color: '#4ECDC4', delay: 30, size: 7 },
];

export const LevelCompletedModal: React.FC<LevelCompletedModalProps> = ({
  visible,
  levelNumber,
  moves,
  timeFormatted,
  starsEarned = 3,
  coinsEarned = 50,
  onClaim3x,
  onNextLevel,
}) => {
  const confettiAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (visible) {
      audioManager.playWin();
      confettiAnim.setValue(0);
      const loop = Animated.loop(
        Animated.timing(confettiAnim, {
          toValue: 1,
          duration: 2400,
          useNativeDriver: true,
        })
      );
      loop.start();
      return () => loop.stop();
    }
  }, [visible]);

  if (!visible) return null;

  return (
    <View style={styles.overlay}>
      {/* Celebratory Animated Confetti Rain */}
      <View style={styles.confettiLayer} pointerEvents="none">
        {CONFETTI_PIECES.map((piece, idx) => {
          const translateY = confettiAnim.interpolate({
            inputRange: [0, 1],
            outputRange: [-40 - (idx % 3) * 35, 520 + (idx % 2) * 60],
          });
          const rotate = confettiAnim.interpolate({
            inputRange: [0, 1],
            outputRange: ['0deg', idx % 2 === 0 ? '360deg' : '-360deg'],
          });

          return (
            <Animated.View
              key={`confetti-${idx}`}
              style={[
                styles.confettiPiece,
                {
                  left: piece.left as any,
                  width: piece.size,
                  height: piece.size * 1.6,
                  backgroundColor: piece.color,
                  transform: [{ translateY }, { rotate }],
                },
              ]}
            />
          );
        })}
      </View>

      {/* Centered Modal Card with Top Star Crest Overflow */}
      <View style={styles.modalCard}>
        {/* 3D Golden Star Crest (SUPER, PERFECT!, CLEAN) */}
        <View style={styles.starCrestContainer}>
          {/* Star 1: SUPER */}
          <View style={styles.starWrapperSmall}>
            <View
              style={[
                styles.goldStarCircleSmall,
                starsEarned < 1 && styles.inactiveStarCircle,
              ]}
            >
              <Ionicons
                name="star"
                size={26}
                color={starsEarned >= 1 ? '#FFFFFF' : '#9CA3AF'}
              />
            </View>
            <Text style={styles.starLabel}>SUPER</Text>
          </View>

          {/* Star 2: PERFECT! (Elevated Centerpiece) */}
          <View style={styles.starWrapperLarge}>
            <View
              style={[
                styles.goldStarCircleLarge,
                starsEarned < 3 && styles.inactiveStarCircle,
              ]}
            >
              <Ionicons
                name="star"
                size={40}
                color={starsEarned >= 3 ? '#FFFFFF' : '#9CA3AF'}
              />
            </View>
            <View style={styles.perfectPill}>
              <Text style={styles.perfectText}>
                {starsEarned === 3
                  ? 'PERFECT!'
                  : starsEarned === 2
                  ? 'GREAT!'
                  : 'CLEARED!'}
              </Text>
            </View>
          </View>

          {/* Star 3: CLEAN */}
          <View style={styles.starWrapperSmall}>
            <View
              style={[
                styles.goldStarCircleSmall,
                starsEarned < 2 && styles.inactiveStarCircle,
              ]}
            >
              <Ionicons
                name="star"
                size={26}
                color={starsEarned >= 2 ? '#FFFFFF' : '#9CA3AF'}
              />
            </View>
            <Text style={styles.starLabel}>CLEAN</Text>
          </View>
        </View>

        {/* Stage Cleared Subtitle */}
        <Text style={styles.stageClearedTag}>STAGE CLEARED</Text>

        {/* Level Title */}
        <Text style={styles.levelTitle}>LEVEL {levelNumber}</Text>

        {/* Congratulatory subtitle */}
        <Text style={styles.subtitleText}>
          {starsEarned === 3
            ? 'Flawless sorting mastery!'
            : 'Awesome puzzle completed!'}
        </Text>

        {/* Stats Container */}
        <View style={styles.statsCard}>
          {/* Coins Earned Row */}
          <View style={styles.coinsRow}>
            <View style={styles.coinsLeftGroup}>
              <View style={styles.goldCoinIcon}>
                <Ionicons name="logo-usd" size={16} color="#78350F" />
              </View>
              <View>
                <Text style={styles.statLabel}>Coins Earned</Text>
                <Text style={styles.statBigValue}>+{coinsEarned}</Text>
              </View>
            </View>

            <View style={styles.bonusPill}>
              <Text style={styles.bonusPillText}>
                {starsEarned === 3 ? '3★ Bonus +15' : 'Bonus +10'}
              </Text>
            </View>
          </View>

          <View style={styles.statsDivider} />

          {/* Moves & Time Grid */}
          <View style={styles.metricsRow}>
            {/* Moves */}
            <View style={styles.metricItem}>
              <View style={styles.metricIconWrap}>
                <Ionicons name="shuffle" size={18} color={Colors.mintDeep} />
              </View>
              <View>
                <Text style={styles.statLabel}>Moves</Text>
                <Text style={styles.metricValue}>{moves} Steps</Text>
              </View>
            </View>

            <View style={styles.verticalDivider} />

            {/* Time */}
            <View style={styles.metricItem}>
              <View style={styles.metricIconWrap}>
                <Ionicons
                  name="stopwatch-outline"
                  size={18}
                  color={Colors.coralDeep}
                />
              </View>
              <View>
                <Text style={styles.statLabel}>Time</Text>
                <Text style={styles.metricValue}>{timeFormatted}</Text>
              </View>
            </View>
          </View>
        </View>

        {/* CTA 1: Tactile 3D Emerald Button "Watch Video - Claim 3x Coins" */}
        <View style={styles.ctaWrapper}>
          <Tactile3DButton
            onPress={onClaim3x}
            title="WATCH VIDEO"
            subtitle="Claim 3x Coins"
            color="#22C55E"
            shadeColor="#15803D"
            height={60}
            extrusionDepth={6}
            icon={
              <View style={styles.videoIconBox}>
                <Ionicons name="play" size={18} color="#22C55E" />
              </View>
            }
            rightBadge={
              <View style={styles.claim3xBadge}>
                <Ionicons
                  name="logo-usd"
                  size={12}
                  color="#78350F"
                  style={{ marginRight: 2 }}
                />
                <Text style={styles.claim3xText}>+{coinsEarned * 3}</Text>
              </View>
            }
          />
        </View>

        {/* CTA 2: Soft Secondary Button "Next Level (1x Coins) ->" */}
        <Pressable
          onPress={() => {
            audioManager.playClick();
            onNextLevel();
          }}
          style={({ pressed }) => [
            styles.nextLevelBtn,
            { opacity: pressed ? 0.8 : 1 },
          ]}
        >
          <Text style={styles.nextLevelText}>
            Next Level (+{coinsEarned} Coins)
          </Text>
          <Ionicons
            name="arrow-forward"
            size={16}
            color="#28233C"
            style={{ marginLeft: 6 }}
          />
        </Pressable>
      </View>

      {/* Helpful Hint beneath the modal */}
      <View style={styles.tipRow}>
        <Ionicons
          name="bulb-outline"
          size={15}
          color="#D97706"
          style={{ marginRight: 6 }}
        />
        <Text style={styles.tipText}>
          Tip: Empty vials give you room to maneuver pure colors!
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(235, 233, 248, 0.72)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    zIndex: 100,
    overflow: 'hidden',
    ...Platform.select({
      web: {
        backdropFilter: 'blur(12px)',
      } as any,
    }),
  },
  confettiLayer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 105,
  },
  confettiPiece: {
    position: 'absolute',
    top: 0,
    borderRadius: 3,
  },
  modalCard: {
    width: '100%',
    maxWidth: 390,
    backgroundColor: '#FFFFFF',
    borderRadius: 36,
    paddingTop: 54,
    paddingBottom: 24,
    paddingHorizontal: 20,
    alignItems: 'center',
    position: 'relative',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.95)',
    zIndex: 110,
    ...Platform.select({
      web: {
        boxShadow:
          '0 24px 50px rgba(30, 30, 60, 0.15), 0 4px 16px rgba(0, 0, 0, 0.05)',
      } as any,
      default: {
        shadowColor: '#1E1E2E',
        shadowOffset: { width: 0, height: 16 },
        shadowOpacity: 0.18,
        shadowRadius: 28,
        elevation: 16,
      },
    }),
  },
  starCrestContainer: {
    position: 'absolute',
    top: -50,
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'center',
    zIndex: 10,
  },
  starWrapperSmall: {
    alignItems: 'center',
    marginHorizontal: 4,
  },
  goldStarCircleSmall: {
    width: 62,
    height: 62,
    borderRadius: 31,
    backgroundColor: '#D97706',
    borderWidth: 4,
    borderColor: '#FBBF24',
    justifyContent: 'center',
    alignItems: 'center',
    ...Platform.select({
      web: {
        boxShadow: '0 6px 14px rgba(217, 119, 6, 0.35)',
      } as any,
    }),
  },
  inactiveStarCircle: {
    backgroundColor: '#E5E7EB',
    borderColor: '#D1D5DB',
  },
  starLabel: {
    fontSize: 10,
    fontWeight: '900',
    color: '#78350F',
    marginTop: 4,
    letterSpacing: 0.5,
  },
  starWrapperLarge: {
    alignItems: 'center',
    marginHorizontal: 6,
    marginBottom: 10,
  },
  goldStarCircleLarge: {
    width: 82,
    height: 82,
    borderRadius: 41,
    backgroundColor: '#D97706',
    borderWidth: 5,
    borderColor: '#FDE68A',
    justifyContent: 'center',
    alignItems: 'center',
    ...Platform.select({
      web: {
        boxShadow: '0 8px 20px rgba(217, 119, 6, 0.45)',
      } as any,
    }),
  },
  perfectPill: {
    backgroundColor: '#FDE68A',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 9999,
    borderWidth: 1,
    borderColor: '#D97706',
    marginTop: -8,
  },
  perfectText: {
    fontSize: 10,
    fontWeight: '900',
    color: '#78350F',
    letterSpacing: 0.5,
  },
  stageClearedTag: {
    fontSize: 13,
    fontWeight: '800',
    color: Colors.mintDeep,
    letterSpacing: 1.5,
    marginTop: 10,
    marginBottom: 4,
  },
  levelTitle: {
    fontSize: 32,
    fontWeight: '900',
    color: Colors.darkText,
    letterSpacing: -0.5,
  },
  subtitleText: {
    fontSize: 15,
    fontWeight: '700',
    color: '#584140',
    marginBottom: 18,
  },
  statsCard: {
    width: '100%',
    backgroundColor: '#F7F6FD',
    borderRadius: 22,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E8E5F8',
    marginBottom: 18,
  },
  coinsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  coinsLeftGroup: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  goldCoinIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#FDE68A',
    borderWidth: 2,
    borderColor: '#D97706',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 10,
  },
  statLabel: {
    fontSize: 11,
    fontWeight: '600',
    color: '#6B7280',
  },
  statBigValue: {
    fontSize: 22,
    fontWeight: '900',
    color: Colors.darkText,
  },
  bonusPill: {
    backgroundColor: '#CCFBF1',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 9999,
  },
  bonusPillText: {
    fontSize: 12,
    fontWeight: '800',
    color: Colors.mintDeep,
  },
  statsDivider: {
    height: 1,
    backgroundColor: '#EBE7F7',
    marginVertical: 12,
  },
  metricsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
  metricItem: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    justifyContent: 'center',
  },
  metricIconWrap: {
    marginRight: 8,
  },
  metricValue: {
    fontSize: 16,
    fontWeight: '800',
    color: Colors.darkText,
  },
  verticalDivider: {
    width: 1,
    height: 28,
    backgroundColor: '#EBE7F7',
  },
  ctaWrapper: {
    width: '100%',
    marginBottom: 10,
  },
  videoIconBox: {
    width: 28,
    height: 28,
    borderRadius: 8,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  claim3xBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FDE68A',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 9999,
    marginLeft: 10,
  },
  claim3xText: {
    fontSize: 13,
    fontWeight: '900',
    color: '#78350F',
  },
  nextLevelBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#F2EFFE',
    width: '100%',
    paddingVertical: 14,
    borderRadius: 9999,
    borderWidth: 1,
    borderColor: '#E4DFFA',
    cursor: 'pointer' as any,
  },
  nextLevelText: {
    fontSize: 14,
    fontWeight: '800',
    color: '#28233C',
  },
  tipRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 20,
    paddingHorizontal: 10,
    zIndex: 110,
  },
  tipText: {
    fontSize: 11,
    fontWeight: '600',
    color: '#655E7A',
  },
});
