import React from 'react';
import { View, Text, StyleSheet, Pressable } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { ActiveTab } from '../../types/game';
import { Colors } from '../../theme/colors';
import { audioManager } from '../../utils/audio';

interface BottomNavBarProps {
  activeTab: ActiveTab;
  onSelectTab: (tab: ActiveTab) => void;
}

export const BottomNavBar: React.FC<BottomNavBarProps> = ({
  activeTab,
  onSelectTab,
}) => {
  const tabs: { key: ActiveTab; label: string; icon: any; iconFilled: any }[] = [
    {
      key: 'play',
      label: 'Play',
      icon: 'game-controller-outline',
      iconFilled: 'game-controller',
    },
    {
      key: 'levels',
      label: 'Levels',
      icon: 'map-outline',
      iconFilled: 'map',
    },
    {
      key: 'shop',
      label: 'Shop',
      icon: 'storefront-outline',
      iconFilled: 'storefront',
    },
    {
      key: 'ranks',
      label: 'Ranks',
      icon: 'podium-outline',
      iconFilled: 'podium',
    },
  ];

  return (
    <View style={styles.navContainer}>
      {tabs.map((tab) => {
        const isActive = activeTab === tab.key;
        const color = isActive ? Colors.coralDeep : '#584140';

        return (
          <Pressable
            key={tab.key}
            onPress={() => {
              audioManager.playClick();
              onSelectTab(tab.key);
            }}
            style={styles.tabItem}
          >
            <Ionicons
              name={isActive ? tab.iconFilled : tab.icon}
              size={22}
              color={color}
            />
            <Text style={[styles.tabLabel, { color }]}>{tab.label}</Text>
          </Pressable>
        );
      })}
    </View>
  );
};

const styles = StyleSheet.create({
  navContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#ECE9F7',
    paddingVertical: 8,
    paddingBottom: 14,
  },
  tabItem: {
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
    paddingVertical: 2,
    cursor: 'pointer' as any,
  },
  tabLabel: {
    fontSize: 11,
    fontWeight: '700',
    marginTop: 4,
  },
});
