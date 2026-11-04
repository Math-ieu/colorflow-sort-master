import React from 'react';
import { View, Text, StyleSheet, Pressable, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { Tactile3DButton } from '../common/Tactile3DButton';
import { audioManager } from '../../utils/audio';

interface BoosterDeckProps {
  undoCount: number;
  extraTubeUsed?: boolean;
  onUndo: () => void;
  onRefillUndoAd?: () => void;
  onAddTube: () => void;
  onRestart: () => void;
}

export const BoosterDeck: React.FC<BoosterDeckProps> = ({
  undoCount,
  extraTubeUsed = false,
  onUndo,
  onRefillUndoAd,
  onAddTube,
  onRestart,
}) => {
  return (
    <View style={styles.deckContainer}>
      {/* 1. Undo Booster (or Watch Ad for +3 Undos when empty) */}
      <View style={styles.boosterItem}>
        <Pressable
          onPress={() => {
            audioManager.playClick();
            if (undoCount > 0) {
              onUndo();
            } else if (onRefillUndoAd) {
              onRefillUndoAd();
            }
          }}
          style={({ pressed }) => [
            styles.roundBoosterBtn,
            undoCount === 0 && styles.refillAdBtnBorder,
            {
              opacity: pressed ? 0.8 : 1,
              transform: [{ scale: pressed ? 0.95 : 1 }],
            },
          ]}
        >
          {undoCount > 0 ? (
            <View style={styles.undoBadge}>
              <Text style={styles.undoBadgeText}>{undoCount}</Text>
            </View>
          ) : (
            <View style={styles.adRefillBadge}>
              <Text style={styles.adRefillBadgeText}>AD</Text>
            </View>
          )}

          <Ionicons
            name="arrow-undo"
            size={24}
            color={undoCount > 0 ? Colors.mintDeep : '#B45309'}
          />
        </Pressable>
        <Text style={styles.boosterLabel}>
          {undoCount > 0 ? 'Undo' : '+3 Undos'}
        </Text>
      </View>

      {/* 2. + Tube (AD) Tactile 3D Button (Max 1 per level) */}
      <View style={styles.centerBoosterItem}>
        <Tactile3DButton
          onPress={() => {
            if (!extraTubeUsed) {
              onAddTube();
            }
          }}
          disabled={extraTubeUsed}
          title=""
          color={extraTubeUsed ? '#D1D5DB' : '#C6A728'}
          shadeColor={extraTubeUsed ? '#9CA3AF' : '#8A7214'}
          height={58}
          extrusionDepth={extraTubeUsed ? 3 : 6}
          style={{ width: 156 }}
          rightBadge={
            <View style={styles.adButtonContent}>
              <Ionicons
                name={extraTubeUsed ? 'checkmark-circle' : 'add-circle-outline'}
                size={22}
                color={extraTubeUsed ? '#4B5563' : '#211B00'}
                style={{ marginRight: 4 }}
              />
              <Text
                style={[
                  styles.tubeTitleText,
                  extraTubeUsed && { color: '#4B5563' },
                ]}
              >
                Tube
              </Text>
              <View
                style={[
                  styles.adSmallPill,
                  extraTubeUsed && { backgroundColor: '#6B7280' },
                ]}
              >
                <Text
                  style={[
                    styles.adSmallPillText,
                    extraTubeUsed && { color: '#F3F4F6' },
                  ]}
                >
                  {extraTubeUsed ? '1/1' : 'AD'}
                </Text>
              </View>
            </View>
          }
        />
        <Text style={styles.boosterSubLabel}>
          {extraTubeUsed ? 'Max 1 / Level' : '+1 Slot'}
        </Text>
      </View>

      {/* 3. Restart Booster */}
      <View style={styles.boosterItem}>
        <Pressable
          onPress={() => {
            audioManager.playClick();
            onRestart();
          }}
          style={({ pressed }) => [
            styles.roundBoosterBtn,
            {
              opacity: pressed ? 0.8 : 1,
              transform: [{ scale: pressed ? 0.95 : 1 }],
            },
          ]}
        >
          <Ionicons name="reload" size={22} color={Colors.darkText} />
        </Pressable>
        <Text style={styles.boosterLabel}>Restart</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  deckContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 20,
    paddingVertical: 10,
    paddingHorizontal: 16,
  },
  boosterItem: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  centerBoosterItem: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  roundBoosterBtn: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    borderWidth: 1.5,
    borderColor: '#ECE7FA',
    ...Platform.select({
      web: {
        boxShadow:
          '0 6px 16px rgba(30, 30, 46, 0.08), inset 0 1px 0 rgba(255, 255, 255, 0.9)',
      } as any,
      default: {
        shadowColor: '#1E1E2E',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
      },
    }),
  },
  refillAdBtnBorder: {
    borderColor: '#F59E0B',
    backgroundColor: '#FFFBEB',
  },
  undoBadge: {
    position: 'absolute',
    top: -4,
    right: -4,
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: Colors.mintDeep,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#FFFFFF',
    zIndex: 5,
  },
  undoBadgeText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '800',
  },
  adRefillBadge: {
    position: 'absolute',
    top: -4,
    right: -6,
    paddingHorizontal: 5,
    paddingVertical: 2,
    borderRadius: 8,
    backgroundColor: '#F59E0B',
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
    zIndex: 5,
  },
  adRefillBadgeText: {
    color: '#FFFFFF',
    fontSize: 9,
    fontWeight: '900',
  },
  boosterLabel: {
    fontSize: 13,
    fontWeight: '800',
    color: '#4B3F3E',
    marginTop: 6,
  },
  boosterSubLabel: {
    fontSize: 12,
    fontWeight: '700',
    color: '#6D5E00',
    marginTop: 6,
  },
  adButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  tubeTitleText: {
    fontSize: 17,
    fontWeight: '900',
    color: '#211B00',
    marginRight: 6,
  },
  adSmallPill: {
    backgroundColor: '#382E00',
    paddingHorizontal: 5,
    paddingVertical: 1,
    borderRadius: 4,
  },
  adSmallPillText: {
    fontSize: 10,
    fontWeight: '900',
    color: '#FFE36A',
  },
});
