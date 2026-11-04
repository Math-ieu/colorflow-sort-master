import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Pressable,
  TextInput,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../theme/colors';
import { PlayerProfile } from '../../types/game';
import { audioManager } from '../../utils/audio';

interface ProfileModalProps {
  visible: boolean;
  profile: PlayerProfile;
  maxLevel: number;
  totalStars: number;
  coins: number;
  onUpdateProfile: (next: PlayerProfile) => void;
  onClose: () => void;
}

const AVATAR_OPTIONS = [
  { id: 'ColorWand', icon: 'color-wand', color: Colors.coralDeep },
  { id: 'Diamond', icon: 'diamond', color: Colors.mintDeep },
  { id: 'Trophy', icon: 'trophy', color: '#D97706' },
  { id: 'Flash', icon: 'flash', color: '#7C3AED' },
  { id: 'Rocket', icon: 'rocket', color: '#059669' },
];

export const ProfileModal: React.FC<ProfileModalProps> = ({
  visible,
  profile,
  maxLevel,
  totalStars,
  coins,
  onUpdateProfile,
  onClose,
}) => {
  const [nameInput, setNameInput] = useState(profile.name);
  const [selectedAvatar, setSelectedAvatar] = useState(profile.avatarIcon);

  if (!visible) return null;

  const activeAvatarObj =
    AVATAR_OPTIONS.find((a) => a.id === selectedAvatar) || AVATAR_OPTIONS[0];

  const handleSave = () => {
    audioManager.playClick();
    onUpdateProfile({
      ...profile,
      name: nameInput.trim() || 'FlowMaster',
      avatarIcon: selectedAvatar,
    });
    onClose();
  };

  return (
    <View style={styles.overlay}>
      <View style={styles.card}>
        {/* Header */}
        <View style={styles.headerRow}>
          <Text style={styles.title}>Player Profile</Text>
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

        {/* Avatar Showcase */}
        <View style={styles.avatarHeader}>
          <View
            style={[
              styles.bigAvatar,
              {
                borderColor: activeAvatarObj.color,
                backgroundColor: activeAvatarObj.color + '18',
              },
            ]}
          >
            <Ionicons
              name={activeAvatarObj.icon as any}
              size={36}
              color={activeAvatarObj.color}
            />
          </View>
          <Text style={styles.rankBadge}>RANK #4 GLOBAL MASTER</Text>
        </View>

        {/* Avatar Picker */}
        <View style={styles.avatarRow}>
          {AVATAR_OPTIONS.map((av) => {
            const isSel = av.id === selectedAvatar;
            return (
              <Pressable
                key={av.id}
                onPress={() => {
                  audioManager.playClick();
                  setSelectedAvatar(av.id);
                }}
                style={[
                  styles.smallAvatarBtn,
                  isSel && {
                    borderColor: av.color,
                    backgroundColor: av.color + '18',
                  },
                ]}
              >
                <Ionicons name={av.icon as any} size={18} color={av.color} />
              </Pressable>
            );
          })}
        </View>

        {/* Editable Player Name */}
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>DISPLAY NAME</Text>
          <TextInput
            value={nameInput}
            onChangeText={setNameInput}
            maxLength={18}
            placeholder="Enter nickname"
            style={styles.textInput}
          />
        </View>

        {/* Live Stats Grid */}
        <View style={styles.statsGrid}>
          <View style={styles.statBox}>
            <Ionicons name="water" size={18} color={Colors.coralDeep} />
            <Text style={styles.statValue}>{maxLevel}</Text>
            <Text style={styles.statName}>Max Level</Text>
          </View>

          <View style={styles.statBox}>
            <Ionicons name="star" size={18} color="#F59E0B" />
            <Text style={styles.statValue}>{totalStars}</Text>
            <Text style={styles.statName}>Total Stars</Text>
          </View>

          <View style={styles.statBox}>
            <Ionicons name="trophy" size={18} color={Colors.mintDeep} />
            <Text style={styles.statValue}>{profile.flawlessWins}</Text>
            <Text style={styles.statName}>3★ Clears</Text>
          </View>

          <View style={styles.statBox}>
            <Ionicons name="logo-usd" size={18} color="#D97706" />
            <Text style={styles.statValue}>{coins}</Text>
            <Text style={styles.statName}>Coins</Text>
          </View>
        </View>

        {/* Save Button */}
        <Pressable onPress={handleSave} style={styles.saveBtn}>
          <Text style={styles.saveBtnText}>Save Profile</Text>
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
    marginBottom: 12,
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
  avatarHeader: {
    alignItems: 'center',
    marginBottom: 14,
  },
  bigAvatar: {
    width: 74,
    height: 74,
    borderRadius: 37,
    borderWidth: 3,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  rankBadge: {
    fontSize: 10,
    fontWeight: '900',
    color: Colors.mintDeep,
    backgroundColor: '#CCFBF1',
    paddingHorizontal: 10,
    paddingVertical: 3,
    borderRadius: 999,
    letterSpacing: 0.5,
  },
  avatarRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 10,
    marginBottom: 16,
  },
  smallAvatarBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#F8F7FC',
    borderWidth: 1.5,
    borderColor: '#E5E7EB',
    justifyContent: 'center',
    alignItems: 'center',
  },
  inputGroup: {
    marginBottom: 16,
  },
  inputLabel: {
    fontSize: 10,
    fontWeight: '800',
    color: '#6B7280',
    marginBottom: 4,
    letterSpacing: 0.5,
  },
  textInput: {
    backgroundColor: '#F8F7FC',
    borderWidth: 1.5,
    borderColor: '#E2E0F2',
    borderRadius: 16,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 15,
    fontWeight: '800',
    color: Colors.darkText,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
    marginBottom: 18,
  },
  statBox: {
    width: '47%',
    backgroundColor: '#F8F7FC',
    borderRadius: 18,
    paddingVertical: 12,
    paddingHorizontal: 10,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ECE8FB',
  },
  statValue: {
    fontSize: 18,
    fontWeight: '900',
    color: Colors.darkText,
    marginTop: 4,
  },
  statName: {
    fontSize: 11,
    fontWeight: '600',
    color: '#6B7280',
  },
  saveBtn: {
    backgroundColor: Colors.mintDeep,
    paddingVertical: 14,
    borderRadius: 999,
    alignItems: 'center',
  },
  saveBtnText: {
    fontSize: 14,
    fontWeight: '900',
    color: '#FFFFFF',
  },
});
