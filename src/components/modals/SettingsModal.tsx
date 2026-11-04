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
import { PlayerSettings } from '../../types/game';
import { audioManager } from '../../utils/audio';

interface SettingsModalProps {
  visible: boolean;
  settings: PlayerSettings;
  onUpdateSettings: (next: PlayerSettings) => void;
  onResetProgress: () => void;
  onClose: () => void;
}

export const SettingsModal: React.FC<SettingsModalProps> = ({
  visible,
  settings,
  onUpdateSettings,
  onResetProgress,
  onClose,
}) => {
  if (!visible) return null;

  const toggleSetting = (key: keyof PlayerSettings) => {
    audioManager.playClick();
    const next = {
      ...settings,
      [key]: !settings[key],
    };
    if (key === 'soundEnabled') {
      audioManager.setEnabled(next.soundEnabled);
    }
    onUpdateSettings(next);
  };

  return (
    <View style={styles.overlay}>
      <View style={styles.card}>
        {/* Header */}
        <View style={styles.headerRow}>
          <View style={styles.titleRow}>
            <View style={styles.iconCircle}>
              <Ionicons name="settings" size={20} color={Colors.coralDeep} />
            </View>
            <Text style={styles.title}>Game Settings</Text>
          </View>
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onClose();
            }}
            style={styles.closeBtn}
          >
            <Ionicons name="close" size={20} color={Colors.darkText} />
          </Pressable>
        </View>

        {/* Toggles List */}
        <View style={styles.optionsList}>
          {/* 1. Sound Effects */}
          <Pressable
            onPress={() => toggleSetting('soundEnabled')}
            style={styles.optionRow}
          >
            <View style={styles.optionLeft}>
              <View style={[styles.optIcon, { backgroundColor: '#CCFBF1' }]}>
                <Ionicons
                  name={settings.soundEnabled ? 'volume-high' : 'volume-mute'}
                  size={20}
                  color={Colors.mintDeep}
                />
              </View>
              <View>
                <Text style={styles.optTitle}>ASMR Fluid Sounds</Text>
                <Text style={styles.optSubtitle}>
                  Harmonic liquid pouring & crystal chimes
                </Text>
              </View>
            </View>
            <View
              style={[
                styles.togglePill,
                settings.soundEnabled && styles.toggleActive,
              ]}
            >
              <View
                style={[
                  styles.toggleThumb,
                  settings.soundEnabled && styles.toggleThumbActive,
                ]}
              />
            </View>
          </Pressable>

          {/* 2. Haptics */}
          <Pressable
            onPress={() => toggleSetting('hapticsEnabled')}
            style={styles.optionRow}
          >
            <View style={styles.optionLeft}>
              <View style={[styles.optIcon, { backgroundColor: '#EDE9FE' }]}>
                <Ionicons name="pulse" size={20} color="#6D28D9" />
              </View>
              <View>
                <Text style={styles.optTitle}>Tactile Haptics</Text>
                <Text style={styles.optSubtitle}>
                  Subtle feedback on tube lift & seal
                </Text>
              </View>
            </View>
            <View
              style={[
                styles.togglePill,
                settings.hapticsEnabled && styles.toggleActive,
              ]}
            >
              <View
                style={[
                  styles.toggleThumb,
                  settings.hapticsEnabled && styles.toggleThumbActive,
                ]}
              />
            </View>
          </Pressable>

          {/* 3. Color-Blind Symbols */}
          <Pressable
            onPress={() => toggleSetting('colorBlindMode')}
            style={styles.optionRow}
          >
            <View style={styles.optionLeft}>
              <View style={[styles.optIcon, { backgroundColor: '#FEF3C7' }]}>
                <Ionicons name="eye-outline" size={20} color="#B45309" />
              </View>
              <View>
                <Text style={styles.optTitle}>Color-Blind Symbols</Text>
                <Text style={styles.optSubtitle}>
                  Display geometric shapes (● ▲ ★ ◆) on liquids
                </Text>
              </View>
            </View>
            <View
              style={[
                styles.togglePill,
                settings.colorBlindMode && styles.toggleActive,
              ]}
            >
              <View
                style={[
                  styles.toggleThumb,
                  settings.colorBlindMode && styles.toggleThumbActive,
                ]}
              />
            </View>
          </Pressable>
        </View>

        {/* Reset Progress Action */}
        <Pressable
          onPress={() => {
            audioManager.playClick();
            onResetProgress();
            onClose();
          }}
          style={styles.resetBtn}
        >
          <Ionicons name="trash-outline" size={16} color="#DC2626" />
          <Text style={styles.resetText}>Reset Saved Progress (Start Level 1)</Text>
        </Pressable>

        {/* Done Button */}
        <Pressable
          onPress={() => {
            audioManager.playClick();
            onClose();
          }}
          style={styles.doneBtn}
        >
          <Text style={styles.doneText}>Save & Resume</Text>
        </Pressable>
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
    backgroundColor: 'rgba(25, 20, 45, 0.55)',
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
    zIndex: 150,
    ...Platform.select({
      web: {
        backdropFilter: 'blur(8px)',
      } as any,
    }),
  },
  card: {
    width: '100%',
    maxWidth: 380,
    backgroundColor: '#FFFFFF',
    borderRadius: 32,
    padding: 22,
    borderWidth: 1.5,
    borderColor: '#ECE7FB',
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 18,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  iconCircle: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: '#FEE2E2',
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 20,
    fontWeight: '900',
    color: Colors.darkText,
  },
  closeBtn: {
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  optionsList: {
    gap: 12,
    marginBottom: 18,
  },
  optionRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#F8F7FC',
    padding: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ECE8FB',
  },
  optionLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginRight: 10,
  },
  optIcon: {
    width: 40,
    height: 40,
    borderRadius: 14,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  optTitle: {
    fontSize: 14,
    fontWeight: '800',
    color: Colors.darkText,
  },
  optSubtitle: {
    fontSize: 11,
    fontWeight: '600',
    color: '#6B7280',
    marginTop: 2,
  },
  togglePill: {
    width: 48,
    height: 28,
    borderRadius: 14,
    backgroundColor: '#D1D5DB',
    padding: 3,
    justifyContent: 'center',
  },
  toggleActive: {
    backgroundColor: Colors.mintDeep,
  },
  toggleThumb: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: '#FFFFFF',
  },
  toggleThumbActive: {
    alignSelf: 'flex-end',
  },
  resetBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 11,
    borderRadius: 16,
    backgroundColor: '#FEF2F2',
    borderWidth: 1,
    borderColor: '#FECACA',
    marginBottom: 12,
    gap: 6,
  },
  resetText: {
    fontSize: 12,
    fontWeight: '800',
    color: '#DC2626',
  },
  doneBtn: {
    backgroundColor: Colors.coralDeep,
    paddingVertical: 14,
    borderRadius: 999,
    alignItems: 'center',
  },
  doneText: {
    fontSize: 14,
    fontWeight: '900',
    color: '#FFFFFF',
  },
});
