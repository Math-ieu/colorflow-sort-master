import React from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import { Colors } from '../../theme/colors';

interface CoinBadgeProps {
  amount: number;
}

export const CoinBadge: React.FC<CoinBadgeProps> = ({ amount }) => {
  return (
    <View style={styles.container}>
      {/* 3D Gold Coin Icon */}
      <View style={styles.coinOuter}>
        <View style={styles.coinInner}>
          <Text style={styles.coinGlyph}>$</Text>
        </View>
      </View>
      <Text style={styles.amountText}>{amount.toLocaleString('en-US')}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    paddingVertical: 5,
    paddingHorizontal: 12,
    borderRadius: 9999,
    borderWidth: 1,
    borderColor: '#EFEAFC',
    ...Platform.select({
      web: {
        boxShadow: '0 2px 8px rgba(30, 30, 46, 0.06)',
      } as any,
      default: {
        shadowColor: '#1E1E2E',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.06,
        shadowRadius: 3,
        elevation: 2,
      },
    }),
  },
  coinOuter: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: Colors.goldShade,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 6,
  },
  coinInner: {
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: Colors.gold,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#FDE68A',
  },
  coinGlyph: {
    fontSize: 11,
    fontWeight: '900',
    color: '#78350F',
    marginTop: -1,
  },
  amountText: {
    fontSize: 14,
    fontWeight: '800',
    color: Colors.darkText,
  },
});
