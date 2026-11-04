import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Pressable,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../theme/colors';
import { ActiveTab } from '../types/game';
import { BottomNavBar } from '../components/navigation/BottomNavBar';
import { CoinBadge } from '../components/common/CoinBadge';
import { audioManager } from '../utils/audio';

interface LevelsScreenProps {
  currentLevel: number;
  maxUnlockedLevel: number;
  levelStars: Record<number, number>;
  onSelectLevel: (lvl: number) => void;
  activeTab: ActiveTab;
  onSelectTab: (tab: ActiveTab) => void;
  coins: number;
}

export const LevelsScreen: React.FC<LevelsScreenProps> = ({
  currentLevel,
  maxUnlockedLevel,
  levelStars,
  onSelectLevel,
  activeTab,
  onSelectTab,
  coins,
}) => {
  const levels = Array.from({ length: 50 }, (_, i) => i + 1);
  const totalEarnedStars = Object.values(levelStars).reduce(
    (sum, s) => sum + s,
    0
  );

  return (
    <SafeAreaView style={styles.safeContainer}>
      {/* Top Header */}
      <View style={styles.headerRow}>
        <View>
          <Text style={styles.screenTitle}>Select Level</Text>
          <View style={styles.subtitleRow}>
            <Ionicons name="star" size={13} color="#F59E0B" />
            <Text style={styles.screenSubtitle}>
              {totalEarnedStars} / 150 Stars Earned • Max Lvl {maxUnlockedLevel}
            </Text>
          </View>
        </View>
        <CoinBadge amount={coins} />
      </View>

      {/* Levels Grid */}
      <ScrollView
        contentContainerStyle={styles.scrollGrid}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.gridContainer}>
          {levels.map((lvl) => {
            const isUnlocked = lvl <= maxUnlockedLevel;
            const isCurrent = lvl === currentLevel;
            const isStitchReference = lvl === 42;
            const stars = levelStars[lvl] || 0;

            return (
              <Pressable
                key={`lvl-${lvl}`}
                disabled={!isUnlocked}
                onPress={() => {
                  audioManager.playClick();
                  onSelectLevel(lvl);
                }}
                style={({ pressed }) => [
                  styles.levelTile,
                  isCurrent && styles.currentTile,
                  !isUnlocked && styles.lockedTile,
                  { opacity: pressed ? 0.8 : 1 },
                ]}
              >
                {isStitchReference && (
                  <View style={styles.referenceBadge}>
                    <Text style={styles.referenceBadgeText}>STITCH</Text>
                  </View>
                )}

                {isUnlocked ? (
                  <>
                    <Text
                      style={[
                        styles.levelNum,
                        isCurrent && styles.currentLevelNum,
                      ]}
                    >
                      {lvl}
                    </Text>
                    <View style={styles.starsRow}>
                      {[1, 2, 3].map((starIdx) => {
                        const earned = stars >= starIdx;
                        return (
                          <Ionicons
                            key={starIdx}
                            name={earned ? 'star' : 'star-outline'}
                            size={11}
                            color={
                              earned
                                ? isCurrent
                                  ? '#FFE66D'
                                  : '#F59E0B'
                                : isCurrent
                                ? 'rgba(255,255,255,0.45)'
                                : '#D1D5DB'
                            }
                          />
                        );
                      })}
                    </View>
                  </>
                ) : (
                  <Ionicons name="lock-closed" size={20} color="#9CA3AF" />
                )}
              </Pressable>
            );
          })}
        </View>
      </ScrollView>

      {/* Bottom Navigation */}
      <BottomNavBar activeTab={activeTab} onSelectTab={onSelectTab} />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeContainer: {
    flex: 1,
    backgroundColor: Colors.canvas,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: '#ECE7FA',
  },
  screenTitle: {
    fontSize: 22,
    fontWeight: '900',
    color: Colors.darkText,
  },
  subtitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    marginTop: 2,
  },
  screenSubtitle: {
    fontSize: 12,
    fontWeight: '700',
    color: '#6B7280',
  },
  scrollGrid: {
    padding: 16,
    paddingBottom: 24,
  },
  gridContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 12,
    justifyContent: 'center',
  },
  levelTile: {
    width: 64,
    height: 64,
    borderRadius: 20,
    backgroundColor: '#FFFFFF',
    borderWidth: 1.5,
    borderColor: '#ECE7FB',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    ...Platform.select({
      web: {
        boxShadow: '0 4px 10px rgba(30, 30, 50, 0.05)',
      } as any,
    }),
  },
  currentTile: {
    backgroundColor: Colors.coralDeep,
    borderColor: Colors.coralDeep,
  },
  lockedTile: {
    backgroundColor: '#F3F4F6',
    borderColor: '#E5E7EB',
  },
  referenceBadge: {
    position: 'absolute',
    top: -6,
    right: -4,
    backgroundColor: Colors.mintDeep,
    paddingHorizontal: 4,
    paddingVertical: 1,
    borderRadius: 4,
  },
  referenceBadgeText: {
    fontSize: 8,
    fontWeight: '900',
    color: '#FFFFFF',
  },
  levelNum: {
    fontSize: 17,
    fontWeight: '900',
    color: Colors.darkText,
  },
  currentLevelNum: {
    color: '#FFFFFF',
  },
  starsRow: {
    flexDirection: 'row',
    gap: 1,
    marginTop: 2,
  },
});
