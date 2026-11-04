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
import {
  ActiveTab,
  VesselSkinId,
  FluidPaletteId,
} from '../types/game';
import { BottomNavBar } from '../components/navigation/BottomNavBar';
import { CoinBadge } from '../components/common/CoinBadge';
import { audioManager } from '../utils/audio';

interface ShopScreenProps {
  coins: number;
  undoCount: number;
  purchasedItems: string[];
  equippedVesselSkin: VesselSkinId;
  equippedPalette: FluidPaletteId;
  onBuyOrEquip: (
    itemId: string,
    kind: 'vessel' | 'palette' | 'consumable',
    price: number
  ) => void;
  onWatchFreeCoinsAd: () => void;
  activeTab: ActiveTab;
  onSelectTab: (tab: ActiveTab) => void;
}

interface ShopCatalogItem {
  id: string;
  name: string;
  category: string;
  kind: 'vessel' | 'palette' | 'consumable';
  price: number;
  icon: string;
  color: string;
  description: string;
}

const SHOP_ITEMS: ShopCatalogItem[] = [
  {
    id: 'tube-classic',
    name: 'Classic Lab Vials',
    category: 'Vessel Skin',
    kind: 'vessel',
    price: 0,
    icon: 'flask-outline',
    color: '#6366F1',
    description: 'Standard rounded borosilicate laboratory tubes',
  },
  {
    id: 'tube-crystal',
    name: 'Crystal Flacons',
    category: 'Vessel Skin',
    kind: 'vessel',
    price: 250,
    icon: 'diamond-outline',
    color: '#0EA5E9',
    description: 'Beveled diamond edges with icy cyan refraction',
  },
  {
    id: 'tube-gold',
    name: 'Royal Golden Tubes',
    category: 'Vessel Skin',
    kind: 'vessel',
    price: 800,
    icon: 'sparkles',
    color: Colors.goldShade,
    description: '24k gold rimmed flasks with warm amber sheen',
  },
  {
    id: 'tube-cyber',
    name: 'Cyber Prism Vials',
    category: 'Vessel Skin',
    kind: 'vessel',
    price: 550,
    icon: 'cube-outline',
    color: '#9333EA',
    description: 'Futuristic sharp-cut vials with neon violet border',
  },
  {
    id: 'palette-classic',
    name: 'Vibrant Pastel Fluids',
    category: 'Liquid Palette',
    kind: 'palette',
    price: 0,
    icon: 'water-outline',
    color: Colors.mint,
    description: 'Original Stitch tactile pastel liquid colors',
  },
  {
    id: 'theme-neon',
    name: 'Neon Glow Fluids',
    category: 'Liquid Palette',
    kind: 'palette',
    price: 400,
    icon: 'color-palette-outline',
    color: Colors.coral,
    description: 'High-contrast cyber-luminescent liquid pigments',
  },
  {
    id: 'palette-ocean',
    name: 'Ocean & Gems Palette',
    category: 'Liquid Palette',
    kind: 'palette',
    price: 450,
    icon: 'planet-outline',
    color: '#0284C7',
    description: 'Deep ruby, sapphire, jade & amethyst tones',
  },
  {
    id: 'booster-pack',
    name: 'Undo Master (+10)',
    category: 'Power-up Pack',
    kind: 'consumable',
    price: 150,
    icon: 'arrow-undo',
    color: Colors.gold,
    description: 'Instantly adds +10 Undo moves to your inventory',
  },
];

export const ShopScreen: React.FC<ShopScreenProps> = ({
  coins,
  undoCount,
  purchasedItems,
  equippedVesselSkin,
  equippedPalette,
  onBuyOrEquip,
  onWatchFreeCoinsAd,
  activeTab,
  onSelectTab,
}) => {
  return (
    <SafeAreaView style={styles.safeContainer}>
      {/* Header */}
      <View style={styles.headerRow}>
        <View>
          <Text style={styles.screenTitle}>Vessel & Liquid Shop</Text>
          <Text style={styles.screenSubtitle}>
            Customize tubes, palettes & power-ups (Undos: {undoCount})
          </Text>
        </View>
        <CoinBadge amount={coins} />
      </View>

      <ScrollView
        contentContainerStyle={styles.scrollList}
        showsVerticalScrollIndicator={false}
      >
        {/* Free Coins Rewarded Video Banner */}
        <View style={styles.freeCoinsBanner}>
          <View style={styles.freeCoinsLeft}>
            <View style={styles.giftCircle}>
              <Ionicons name="gift" size={24} color="#78350F" />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.freeTitle}>Free Coin Chest</Text>
              <Text style={styles.freeSub}>
                Watch a short video to claim +100 Coins
              </Text>
            </View>
          </View>
          <Pressable
            onPress={() => {
              audioManager.playClick();
              onWatchFreeCoinsAd();
            }}
            style={({ pressed }) => [
              styles.watchAdBtn,
              { opacity: pressed ? 0.85 : 1 },
            ]}
          >
            <Ionicons name="play-circle" size={16} color="#FFFFFF" />
            <Text style={styles.watchAdBtnText}>+100</Text>
          </Pressable>
        </View>

        {/* Catalog Items */}
        {SHOP_ITEMS.map((item) => {
          const isOwned =
            item.kind !== 'consumable' && purchasedItems.includes(item.id);
          const isEquipped =
            (item.kind === 'vessel' && equippedVesselSkin === item.id) ||
            (item.kind === 'palette' && equippedPalette === item.id);
          const canAfford = coins >= item.price;

          return (
            <View
              key={item.id}
              style={[
                styles.shopCard,
                isEquipped && styles.equippedCardBorder,
              ]}
            >
              <View
                style={[
                  styles.itemIconBox,
                  { backgroundColor: item.color + '22' },
                ]}
              >
                <Ionicons
                  name={item.icon as any}
                  size={26}
                  color={item.color}
                />
              </View>

              <View style={styles.cardDetails}>
                <Text style={styles.itemCategory}>{item.category}</Text>
                <Text style={styles.itemName}>{item.name}</Text>
                <Text style={styles.itemDesc}>{item.description}</Text>
              </View>

              <Pressable
                onPress={() => {
                  audioManager.playClick();
                  onBuyOrEquip(item.id, item.kind, item.price);
                }}
                disabled={isEquipped || (!isOwned && !canAfford)}
                style={({ pressed }) => [
                  styles.buyBtn,
                  isEquipped && styles.equippedBtn,
                  isOwned && !isEquipped && styles.equipReadyBtn,
                  !isOwned && !canAfford && styles.disabledBtn,
                  { opacity: pressed ? 0.8 : 1 },
                ]}
              >
                {isEquipped ? (
                  <Text style={styles.equippedText}>EQUIPPED</Text>
                ) : isOwned ? (
                  <Text style={styles.equipReadyText}>EQUIP</Text>
                ) : (
                  <View style={styles.priceRow}>
                    <Ionicons name="logo-usd" size={13} color="#FFFFFF" />
                    <Text style={styles.buyText}>{item.price}</Text>
                  </View>
                )}
              </Pressable>
            </View>
          );
        })}
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
  scrollList: {
    padding: 16,
    gap: 12,
    paddingBottom: 24,
  },
  freeCoinsBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#FEF3C7',
    borderRadius: 22,
    padding: 14,
    borderWidth: 1.5,
    borderColor: '#F59E0B',
  },
  freeCoinsLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginRight: 10,
  },
  giftCircle: {
    width: 46,
    height: 46,
    borderRadius: 16,
    backgroundColor: '#FDE68A',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 12,
  },
  freeTitle: {
    fontSize: 15,
    fontWeight: '900',
    color: '#78350F',
  },
  freeSub: {
    fontSize: 11,
    fontWeight: '600',
    color: '#92400E',
    marginTop: 1,
  },
  watchAdBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#D97706',
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 999,
    gap: 4,
  },
  watchAdBtnText: {
    fontSize: 13,
    fontWeight: '900',
    color: '#FFFFFF',
  },
  shopCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 24,
    padding: 14,
    borderWidth: 1.5,
    borderColor: '#ECE7FB',
    ...Platform.select({
      web: {
        boxShadow: '0 4px 12px rgba(30, 30, 50, 0.05)',
      } as any,
    }),
  },
  equippedCardBorder: {
    borderColor: Colors.mint,
    backgroundColor: '#F0FDFA',
  },
  itemIconBox: {
    width: 52,
    height: 52,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  cardDetails: {
    flex: 1,
    marginRight: 8,
  },
  itemCategory: {
    fontSize: 10,
    fontWeight: '800',
    color: '#9CA3AF',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  itemName: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.darkText,
    marginTop: 1,
  },
  itemDesc: {
    fontSize: 11,
    fontWeight: '500',
    color: '#6B7280',
    marginTop: 2,
  },
  buyBtn: {
    backgroundColor: Colors.mintDeep,
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 9999,
    minWidth: 82,
    alignItems: 'center',
  },
  equippedBtn: {
    backgroundColor: '#CCFBF1',
    borderWidth: 1,
    borderColor: Colors.mint,
  },
  equipReadyBtn: {
    backgroundColor: '#4F46E5',
  },
  disabledBtn: {
    backgroundColor: '#D1D5DB',
  },
  buyText: {
    fontSize: 13,
    fontWeight: '900',
    color: '#FFFFFF',
    marginLeft: 2,
  },
  equippedText: {
    fontSize: 11,
    fontWeight: '900',
    color: Colors.mintDeep,
  },
  equipReadyText: {
    fontSize: 11,
    fontWeight: '900',
    color: '#FFFFFF',
  },
  priceRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
});
