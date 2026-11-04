import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { Ionicons, MaterialCommunityIcons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { audioManager } from '../../utils/audio';

interface HintBannerProps {
  message?: string;
  isDeadlocked?: boolean;
  onRequestHint?: () => void;
}

export const HintBanner: React.FC<HintBannerProps> = ({
  message = 'Tap any tube to lift and pour matching color!',
  isDeadlocked = false,
  onRequestHint,
}) => {
  return (
    <Pressable
      onPress={() => {
        if (onRequestHint) {
          audioManager.playClick();
          onRequestHint();
        }
      }}
      style={({ pressed }) => [
        styles.bannerRow,
        isDeadlocked && styles.deadlockRow,
        { opacity: pressed ? 0.8 : 1 },
      ]}
    >
      <View style={styles.lightbulbCircle}>
        <Ionicons
          name={isDeadlocked ? 'warning-outline' : 'bulb-outline'}
          size={16}
          color={isDeadlocked ? '#B45309' : Colors.mintDeep}
        />
      </View>
      <Text
        style={[
          styles.hintText,
          isDeadlocked && styles.deadlockText,
        ]}
      >
        {message}
      </Text>
      {!isDeadlocked && onRequestHint && (
        <View style={styles.hintChip}>
          <Text style={styles.hintChipText}>HINT</Text>
        </View>
      )}
      {isDeadlocked && (
        <MaterialCommunityIcons
          name="restore"
          size={16}
          color="#B45309"
          style={styles.handIcon}
        />
      )}
    </Pressable>
  );
};

const styles = StyleSheet.create({
  bannerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginHorizontal: 16,
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.55)',
    borderWidth: 1,
    borderColor: '#ECE7FB',
    cursor: 'pointer' as any,
  },
  deadlockRow: {
    backgroundColor: '#FEF3C7',
    borderColor: '#F59E0B',
  },
  lightbulbCircle: {
    marginRight: 6,
  },
  hintText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#37324B',
    textAlign: 'center',
    flexShrink: 1,
  },
  deadlockText: {
    color: '#92400E',
    fontWeight: '800',
  },
  hintChip: {
    marginLeft: 8,
    backgroundColor: '#CCFBF1',
    paddingHorizontal: 7,
    paddingVertical: 2,
    borderRadius: 8,
  },
  hintChipText: {
    fontSize: 9,
    fontWeight: '900',
    color: Colors.mintDeep,
    letterSpacing: 0.4,
  },
  handIcon: {
    marginLeft: 6,
  },
});
