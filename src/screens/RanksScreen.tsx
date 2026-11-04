import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../theme/colors';
import { ActiveTab, PlayerProfile } from '../types/game';
import { BottomNavBar } from '../components/navigation/BottomNavBar';
import { CoinBadge } from '../components/common/CoinBadge';

interface RanksScreenProps {
  coins: number;
  profile: PlayerProfile;
  maxLevel: number;
  totalStars: number;
  activeTab: ActiveTab;
  onSelectTab: (tab: ActiveTab) => void;
}

export const RanksScreen: React.FC<RanksScreenProps> = ({
  coins,
  profile,
  maxLevel,
  totalStars,
  activeTab,
  onSelectTab,
}) => {
  const competitors = [
    { name: 'Luna_SortMaster', level: 50, stars: 150, isUser: false },
    { name: 'Alex_Flow', level: 48, stars: 141, isUser: false },
    { name: 'PixelSamurai', level: 45, stars: 132, isUser: false },
    {
      name: `${profile.name} (You)`,
      level: maxLevel,
      stars: totalStars,
      isUser: true,
    },
    { name: 'EchoVial', level: 39, stars: 114, isUser: false },
    { name: 'CyanSplash', level: 35, stars: 102, isUser: false },
  ];

  // Sort dynamically by stars descending
  const sortedPlayers = [...competitors]
    .sort((a, b) => b.stars - a.stars || b.level - a.level)
    .map((p, idx) => ({
      ...p,
      rank: idx + 1,
      medal:
        idx === 0
          ? '🥇'
          : idx === 1
          ? '🥈'
          : idx === 2
          ? '🥉'
          : `#${idx + 1}`,
    }));

  return (
    <SafeAreaView style={styles.safeContainer}>
      {/* Header */}
      <View style={styles.headerRow}>
        <View>
          <Text style={styles.screenTitle}>Global Ranks</Text>
          <Text style={styles.screenSubtitle}>
            Top ColorFlow Masters • Your Stars: {totalStars} ⭐
          </Text>
        </View>
        <CoinBadge amount={coins} />
      </View>

      {/* Podium Top 3 */}
      <View style={styles.podiumContainer}>
        {/* Rank 2 */}
        <View style={styles.podiumColumn}>
          <Text style={styles.podiumMedal}>🥈</Text>
          <View style={[styles.avatarCircle, { borderColor: '#94A3B8' }]}>
            <Ionicons name="person" size={24} color="#64748B" />
          </View>
          <Text style={styles.podiumName} numberOfLines={1}>
            {sortedPlayers[1]?.name}
          </Text>
          <View
            style={[
              styles.podiumBlock,
              { height: 75, backgroundColor: '#E2E8F0' },
            ]}
          >
            <Text style={styles.podiumRankText}>2</Text>
          </View>
        </View>

        {/* Rank 1 (Tallest) */}
        <View style={styles.podiumColumn}>
          <Text style={styles.podiumMedal}>🥇</Text>
          <View style={[styles.avatarCircle, { borderColor: '#F59E0B' }]}>
            <Ionicons name="trophy" size={26} color="#D97706" />
          </View>
          <Text style={styles.podiumName} numberOfLines={1}>
            {sortedPlayers[0]?.name}
          </Text>
          <View
            style={[
              styles.podiumBlock,
              { height: 100, backgroundColor: '#FEF3C7' },
            ]}
          >
            <Text style={[styles.podiumRankText, { color: '#B45309' }]}>1</Text>
          </View>
        </View>

        {/* Rank 3 */}
        <View style={styles.podiumColumn}>
          <Text style={styles.podiumMedal}>🥉</Text>
          <View style={[styles.avatarCircle, { borderColor: '#D97706' }]}>
            <Ionicons name="person" size={24} color="#92400E" />
          </View>
          <Text style={styles.podiumName} numberOfLines={1}>
            {sortedPlayers[2]?.name}
          </Text>
          <View
            style={[
              styles.podiumBlock,
              { height: 60, backgroundColor: '#FED7AA' },
            ]}
          >
            <Text style={styles.podiumRankText}>3</Text>
          </View>
        </View>
      </View>

      {/* List */}
      <ScrollView
        contentContainerStyle={styles.scrollList}
        showsVerticalScrollIndicator={false}
      >
        {sortedPlayers.map((p) => (
          <View
            key={`rank-${p.rank}`}
            style={[
              styles.playerRow,
              p.isUser && styles.currentUserRow,
            ]}
          >
            <Text style={styles.rankNum}>{p.medal}</Text>

            <View style={styles.playerInfo}>
              <Text
                style={[
                  styles.playerName,
                  p.isUser && styles.currentUserName,
                ]}
              >
                {p.name}
              </Text>
              <Text style={styles.playerLevel}>Level {p.level} Reached</Text>
            </View>

            <View style={styles.starsBox}>
              <Ionicons name="star" size={14} color="#F59E0B" />
              <Text style={styles.starsText}>{p.stars}</Text>
            </View>
          </View>
        ))}
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
  screenSubtitle: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6B7280',
    marginTop: 2,
  },
  podiumContainer: {
    flexDirection: 'row',
    alignItems: 'flex-end',
    justifyContent: 'center',
    paddingTop: 16,
    paddingHorizontal: 20,
    gap: 12,
  },
  podiumColumn: {
    alignItems: 'center',
    width: 86,
  },
  podiumMedal: {
    fontSize: 20,
    marginBottom: 4,
  },
  avatarCircle: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: '#FFFFFF',
    borderWidth: 2,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 6,
  },
  podiumName: {
    fontSize: 11,
    fontWeight: '800',
    color: Colors.darkText,
    marginBottom: 6,
  },
  podiumBlock: {
    width: '100%',
    borderTopLeftRadius: 14,
    borderTopRightRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  podiumRankText: {
    fontSize: 20,
    fontWeight: '900',
    color: '#475569',
  },
  scrollList: {
    padding: 16,
    gap: 10,
  },
  playerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    padding: 14,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#ECE7FB',
  },
  currentUserRow: {
    backgroundColor: '#EEF2FF',
    borderColor: '#C7D2FE',
  },
  rankNum: {
    fontSize: 18,
    fontWeight: '900',
    width: 36,
  },
  playerInfo: {
    flex: 1,
  },
  playerName: {
    fontSize: 14,
    fontWeight: '800',
    color: Colors.darkText,
  },
  currentUserName: {
    color: '#3730A3',
  },
  playerLevel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6B7280',
    marginTop: 2,
  },
  starsBox: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 9999,
  },
  starsText: {
    fontSize: 12,
    fontWeight: '800',
    color: '#92400E',
    marginLeft: 4,
  },
});
