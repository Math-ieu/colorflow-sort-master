import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { RewardedAdTrigger } from '../../types/game';
import { audioManager } from '../../utils/audio';

interface RewardedAdModalProps {
  visible: boolean;
  trigger: RewardedAdTrigger;
  onCompleteReward: () => void;
  onCancel: () => void;
}

const REWARD_INFO: Record<
  Exclude<RewardedAdTrigger, null>,
  { title: string; subtitle: string; icon: string; badge: string }
> = {
  extra_tube: {
    title: 'Unlock +1 Extra Tube',
    subtitle: 'Add an empty glass vial for this level',
    icon: 'flask-outline',
    badge: '+1 TUBE',
  },
  refill_undo: {
    title: 'Refill +3 Undo Moves',
    subtitle: 'Rewind tricky steps and rescue your board',
    icon: 'arrow-undo',
    badge: '+3 UNDOS',
  },
  claim_3x: {
    title: 'Triple Victory Coins!',
    subtitle: 'Boost your level reward from 50 to 150 Coins',
    icon: 'Sparkles',
    badge: '+150 COINS',
  },
  free_coins: {
    title: 'Free Treasure Chest',
    subtitle: 'Instant bonus coins for the Vessel Shop',
    icon: 'gift-outline',
    badge: '+100 COINS',
  },
};

export const RewardedAdModal: React.FC<RewardedAdModalProps> = ({
  visible,
  trigger,
  onCompleteReward,
  onCancel,
}) => {
  const [secondsLeft, setSecondsLeft] = useState(3);

  useEffect(() => {
    if (!visible || !trigger) return;
    setSecondsLeft(3);

    const interval = setInterval(() => {
      setSecondsLeft((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [visible, trigger]);

  if (!visible || !trigger) return null;

  const info = REWARD_INFO[trigger];
  const isReady = secondsLeft === 0;

  return (
    <View style={styles.overlay}>
      <View style={styles.adContainer}>
        {/* Top AdMob Header Bar */}
        <View style={styles.topBar}>
          <View style={styles.adBadge}>
            <Ionicons name="videocam" size={12} color="#FDE68A" />
            <Text style={styles.adBadgeText}>GOOGLE ADMOB • REWARDED</Text>
          </View>

          {isReady ? (
            <Pressable
              onPress={() => {
                audioManager.playWin();
                onCompleteReward();
              }}
              style={styles.closeReadyBtn}
            >
              <Ionicons name="checkmark-circle" size={16} color="#FFFFFF" />
              <Text style={styles.closeReadyText}>Reward Granted</Text>
            </Pressable>
          ) : (
            <View style={styles.timerPill}>
              <Text style={styles.timerText}>Reward in {secondsLeft}s</Text>
            </View>
          )}
        </View>

        {/* Video Showcase Area */}
        <View style={styles.videoViewport}>
          <View style={styles.glowCircle}>
            <Ionicons
              name={
                trigger === 'claim_3x'
                  ? 'trophy'
                  : (info.icon as any)
              }
              size={44}
              color="#FFE66D"
            />
          </View>
          <View style={styles.rewardPill}>
            <Text style={styles.rewardPillText}>{info.badge}</Text>
          </View>
          <Text style={styles.adTitle}>{info.title}</Text>
          <Text style={styles.adSubtitle}>{info.subtitle}</Text>

          {/* Progress Bar */}
          <View style={styles.progressTrack}>
            <View
              style={[
                styles.progressFill,
                { width: `${((3 - secondsLeft) / 3) * 100}%` },
              ]}
            />
          </View>
        </View>

        {/* Bottom Actions */}
        <View style={styles.footerRow}>
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onCancel();
            }}
            style={styles.cancelBtn}
          >
            <Text style={styles.cancelText}>Cancel</Text>
          </Pressable>

          <Pressable
            disabled={!isReady}
            onPress={() => {
              audioManager.playWin();
              onCompleteReward();
            }}
            style={[
              styles.claimBtn,
              !isReady && styles.claimBtnDisabled,
            ]}
          >
            <Ionicons
              name={isReady ? 'gift' : 'hourglass-outline'}
              size={16}
              color="#FFFFFF"
              style={{ marginRight: 6 }}
            />
            <Text style={styles.claimBtnText}>
              {isReady ? `CLAIM ${info.badge}` : `Wait ${secondsLeft}s...`}
            </Text>
          </Pressable>
        </View>
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
    backgroundColor: 'rgba(15, 12, 32, 0.85)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    zIndex: 200,
    ...Platform.select({
      web: {
        backdropFilter: 'blur(10px)',
      } as any,
    }),
  },
  adContainer: {
    width: '100%',
    maxWidth: 380,
    backgroundColor: '#1E1B3A',
    borderRadius: 32,
    padding: 20,
    borderWidth: 2,
    borderColor: '#3B346E',
  },
  topBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 18,
  },
  adBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
    gap: 5,
  },
  adBadgeText: {
    fontSize: 10,
    fontWeight: '900',
    color: '#E2E8F0',
    letterSpacing: 0.4,
  },
  timerPill: {
    backgroundColor: '#312E81',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
  },
  timerText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#A5B4FC',
  },
  closeReadyBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.emerald,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 999,
    gap: 4,
  },
  closeReadyText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  videoViewport: {
    backgroundColor: '#131129',
    borderRadius: 24,
    paddingVertical: 28,
    paddingHorizontal: 18,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#2D2856',
    marginBottom: 18,
  },
  glowCircle: {
    width: 84,
    height: 84,
    borderRadius: 42,
    backgroundColor: 'rgba(245, 158, 11, 0.16)',
    borderWidth: 2,
    borderColor: '#F59E0B',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  rewardPill: {
    backgroundColor: '#F59E0B',
    paddingHorizontal: 12,
    paddingVertical: 3,
    borderRadius: 999,
    marginBottom: 10,
  },
  rewardPillText: {
    fontSize: 11,
    fontWeight: '900',
    color: '#1E1B3A',
    letterSpacing: 0.6,
  },
  adTitle: {
    fontSize: 20,
    fontWeight: '900',
    color: '#FFFFFF',
    textAlign: 'center',
    marginBottom: 6,
  },
  adSubtitle: {
    fontSize: 12,
    fontWeight: '600',
    color: '#94A3B8',
    textAlign: 'center',
    marginBottom: 20,
  },
  progressTrack: {
    width: '100%',
    height: 8,
    backgroundColor: '#2D2856',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: Colors.mint,
    borderRadius: 4,
  },
  footerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  cancelBtn: {
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderRadius: 999,
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
  },
  cancelText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#94A3B8',
  },
  claimBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 14,
    borderRadius: 999,
    backgroundColor: Colors.emerald,
  },
  claimBtnDisabled: {
    backgroundColor: '#475569',
  },
  claimBtnText: {
    fontSize: 14,
    fontWeight: '900',
    color: '#FFFFFF',
  },
});
