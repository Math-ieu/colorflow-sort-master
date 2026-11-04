import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { CoinBadge } from '../common/CoinBadge';
import { audioManager } from '../../utils/audio';

interface TopHUDProps {
  levelNumber: number;
  difficulty: string;
  milestoneText: string;
  coins: number;
  isSoundEnabled: boolean;
  onToggleSound: () => void;
  onOpenSettings?: () => void;
  onOpenProfile?: () => void;
}

export const TopHUD: React.FC<TopHUDProps> = ({
  levelNumber,
  difficulty,
  milestoneText,
  coins,
  isSoundEnabled,
  onToggleSound,
  onOpenSettings,
  onOpenProfile,
}) => {
  return (
    <View style={styles.hudContainer}>
      {/* Row 1: Brand / Play Pill, Coins Counter, Action Circle Buttons */}
      <View style={styles.topRow}>
        {/* Brand & Play Chip */}
        <View style={styles.brandGroup}>
          <View style={styles.brandCard}>
            <Text style={styles.brandTitle}>ColorFlow</Text>
          </View>
          <View style={styles.playChip}>
            <Ionicons name="wine-outline" size={13} color={Colors.coralDeep} />
            <Text style={styles.playChipText}>PLAY</Text>
          </View>
        </View>

        {/* Coins Counter */}
        <CoinBadge amount={coins} />

        {/* Action Buttons: Sound, Settings, Profile */}
        <View style={styles.actionButtonsGroup}>
          {/* Sound Toggle */}
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onToggleSound();
            }}
            style={({ pressed }) => [
              styles.circleBtn,
              { opacity: pressed ? 0.75 : 1 },
            ]}
          >
            <Ionicons
              name={isSoundEnabled ? 'volume-high-outline' : 'volume-mute-outline'}
              size={18}
              color={Colors.darkText}
            />
          </Pressable>

          {/* Settings */}
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onOpenSettings?.();
            }}
            style={({ pressed }) => [
              styles.circleBtn,
              { opacity: pressed ? 0.75 : 1 },
            ]}
          >
            <Ionicons name="settings-outline" size={18} color={Colors.darkText} />
          </Pressable>

          {/* User Profile */}
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onOpenProfile?.();
            }}
            style={({ pressed }) => [
              styles.circleBtn,
              styles.profileBtn,
              { opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <Ionicons name="person" size={16} color="#FFFFFF" />
          </Pressable>
        </View>
      </View>

      {/* Row 2: Level Badge, Difficulty Chip, Milestone */}
      <View style={styles.secondRow}>
        {/* Red Level Badge with Drop */}
        <View style={styles.levelBadge}>
          <Ionicons name="water" size={15} color="#FFFFFF" style={{ marginRight: 4 }} />
          <Text style={styles.levelText}>Level {levelNumber}</Text>
        </View>

        {/* Difficulty Pill */}
        <View style={styles.difficultyPill}>
          <Ionicons name="star-outline" size={12} color="#7C3AED" style={{ marginRight: 3 }} />
          <Text style={styles.difficultyText}>{difficulty}</Text>
        </View>

        {/* Milestone Indicator */}
        <View style={styles.milestoneBox}>
          <Text style={styles.milestoneTitle}>Milestone</Text>
          <View style={styles.milestoneRow}>
            <Text style={styles.milestoneValue}>{milestoneText}</Text>
            <View style={styles.trophyCircle}>
              <Ionicons name="trophy-outline" size={12} color={Colors.mintDeep} />
            </View>
          </View>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  hudContainer: {
    paddingHorizontal: 16,
    paddingTop: 10,
    paddingBottom: 12,
  },
  topRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  brandGroup: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    padding: 3,
    borderRadius: 9999,
    borderWidth: 1,
    borderColor: '#ECE8FB',
  },
  brandCard: {
    paddingHorizontal: 7,
    paddingVertical: 2,
  },
  brandTitle: {
    fontSize: 12,
    fontWeight: '800',
    color: '#3B82F6',
    letterSpacing: -0.2,
  },
  playChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FEE2E2',
    paddingHorizontal: 7,
    paddingVertical: 3,
    borderRadius: 9999,
  },
  playChipText: {
    fontSize: 10,
    fontWeight: '800',
    color: Colors.coralDeep,
    marginLeft: 3,
  },
  actionButtonsGroup: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  circleBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#EAE6FA',
    ...Platform.select({
      web: {
        boxShadow: '0 2px 6px rgba(30, 30, 46, 0.05)',
      } as any,
      default: {
        shadowColor: '#1E1E2E',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.05,
        shadowRadius: 3,
        elevation: 2,
      },
    }),
  },
  profileBtn: {
    backgroundColor: Colors.coralDeep,
    borderColor: Colors.coralDeep,
  },
  secondRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  levelBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.coralDeep,
    paddingVertical: 6,
    paddingHorizontal: 14,
    borderRadius: 9999,
    ...Platform.select({
      web: {
        boxShadow: '0 4px 10px rgba(174, 47, 52, 0.3)',
      } as any,
      default: {
        shadowColor: Colors.coralDeep,
        shadowOffset: { width: 0, height: 3 },
        shadowOpacity: 0.3,
        shadowRadius: 6,
        elevation: 4,
      },
    }),
  },
  levelText: {
    fontSize: 15,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  difficultyPill: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#EDE9FE',
    paddingVertical: 5,
    paddingHorizontal: 12,
    borderRadius: 9999,
  },
  difficultyText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#5B21B6',
  },
  milestoneBox: {
    alignItems: 'flex-end',
  },
  milestoneTitle: {
    fontSize: 11,
    fontWeight: '600',
    color: '#6B7280',
    marginBottom: 2,
  },
  milestoneRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  milestoneValue: {
    fontSize: 13,
    fontWeight: '800',
    color: Colors.mintDeep,
    marginRight: 5,
  },
  trophyCircle: {
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: '#CCFBF1',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
