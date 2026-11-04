import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Platform } from 'react-native';
import {
  ActiveTab,
  SavedProgress,
  RewardedAdTrigger,
  VesselSkinId,
  FluidPaletteId,
  PlayerSettings,
  PlayerProfile,
} from './src/types/game';
import { GameScreen } from './src/screens/GameScreen';
import { LevelsScreen } from './src/screens/LevelsScreen';
import { ShopScreen } from './src/screens/ShopScreen';
import { RanksScreen } from './src/screens/RanksScreen';
import { RewardedAdModal } from './src/components/modals/RewardedAdModal';
import { SettingsModal } from './src/components/modals/SettingsModal';
import { ProfileModal } from './src/components/modals/ProfileModal';
import { Colors } from './src/theme/colors';
import {
  loadProgress,
  saveProgress,
  resetProgress,
} from './src/utils/storage';
import { audioManager } from './src/utils/audio';
import { adMobService } from './src/services/adMob';

export default function App() {
  const [progress, setProgress] = useState<SavedProgress>(() => loadProgress());
  const [activeTab, setActiveTab] = useState<ActiveTab>('play');
  const [adTrigger, setAdTrigger] = useState<RewardedAdTrigger>(null);
  const [pendingWinData, setPendingWinData] = useState<{
    stars: 1 | 2 | 3;
    baseCoins: number;
  } | null>(null);
  const [extraTubeGrantSignal, setExtraTubeGrantSignal] = useState(0);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isProfileOpen, setIsProfileOpen] = useState(false);

  // Initialize AdMob on mount
  useEffect(() => {
    adMobService.initialize();
  }, []);

  // Sync audio state and persist progress whenever it changes
  useEffect(() => {
    audioManager.setEnabled(progress.settings.soundEnabled);
    saveProgress(progress);
  }, [progress]);

  const totalStars = Object.values(progress.levelStars).reduce(
    (sum, s) => sum + s,
    0
  );

  const handleLevelSelect = (lvl: number) => {
    setProgress((prev) => ({
      ...prev,
      currentLevel: lvl,
    }));
    setActiveTab('play');
  };

  const recordLevelVictory = (
    starsEarned: 1 | 2 | 3,
    coinsReward: number
  ) => {
    setProgress((prev) => {
      const lvl = prev.currentLevel;
      const prevStars = prev.levelStars[lvl] || 0;
      const nextStars = Math.max(prevStars, starsEarned);
      const nextLevel = lvl + 1;
      const nextMaxUnlocked = Math.max(prev.maxUnlockedLevel, nextLevel);
      const isNewFlawless = prevStars < 3 && starsEarned === 3;

      return {
        ...prev,
        currentLevel: nextLevel,
        maxUnlockedLevel: nextMaxUnlocked,
        coins: prev.coins + coinsReward,
        levelStars: {
          ...prev.levelStars,
          [lvl]: nextStars,
        },
        profile: {
          ...prev.profile,
          levelsCompleted: Math.max(prev.profile.levelsCompleted, lvl),
          flawlessWins: prev.profile.flawlessWins + (isNewFlawless ? 1 : 0),
        },
      };
    });
  };

  const grantRewardForTrigger = (
    trigger: RewardedAdTrigger,
    winData?: { stars: 1 | 2 | 3; baseCoins: number } | null
  ) => {
    if (trigger === 'extra_tube') {
      setExtraTubeGrantSignal((s) => s + 1);
    } else if (trigger === 'refill_undo') {
      setProgress((prev) => ({
        ...prev,
        undoCount: prev.undoCount + 3,
      }));
    } else if (trigger === 'claim_3x') {
      const data = winData || pendingWinData;
      if (data) {
        recordLevelVictory(data.stars, data.baseCoins * 3);
        setPendingWinData(null);
      }
    } else if (trigger === 'free_coins') {
      setProgress((prev) => ({
        ...prev,
        coins: prev.coins + 100,
      }));
    }
  };

  const handleRequestRewardedAd = async (
    trigger: RewardedAdTrigger,
    winData?: { stars: 1 | 2 | 3; baseCoins: number }
  ) => {
    if (!trigger) return;
    if (winData) setPendingWinData(winData);

    // Try native AdMob first on mobile devices
    const shown = await adMobService.showRewardedAd(() => {
      grantRewardForTrigger(trigger, winData);
    });

    // If native AdMob was not shown (web or not loaded yet), fall back to the interactive modal
    if (!shown) {
      setAdTrigger(trigger);
    }
  };

  const handleCompleteRewardedAd = () => {
    const currentTrigger = adTrigger;
    const currentWinData = pendingWinData;
    setAdTrigger(null);
    grantRewardForTrigger(currentTrigger, currentWinData);
  };

  const handleBuyOrEquip = (
    itemId: string,
    kind: 'vessel' | 'palette' | 'consumable',
    price: number
  ) => {
    setProgress((prev) => {
      const isOwned =
        kind !== 'consumable' && prev.purchasedItems.includes(itemId);

      // If already owned, simply equip it
      if (isOwned) {
        return {
          ...prev,
          equippedVesselSkin:
            kind === 'vessel'
              ? (itemId as VesselSkinId)
              : prev.equippedVesselSkin,
          equippedPalette:
            kind === 'palette'
              ? (itemId as FluidPaletteId)
              : prev.equippedPalette,
        };
      }

      // Check coins balance for purchase
      if (prev.coins < price) return prev;
      audioManager.playWin();

      if (kind === 'consumable') {
        return {
          ...prev,
          coins: prev.coins - price,
          undoCount: prev.undoCount + 10,
        };
      }

      return {
        ...prev,
        coins: prev.coins - price,
        purchasedItems: [...prev.purchasedItems, itemId],
        equippedVesselSkin:
          kind === 'vessel'
            ? (itemId as VesselSkinId)
            : prev.equippedVesselSkin,
        equippedPalette:
          kind === 'palette'
            ? (itemId as FluidPaletteId)
            : prev.equippedPalette,
      };
    });
  };

  const handleToggleSound = () => {
    setProgress((prev) => {
      const nextSound = !prev.settings.soundEnabled;
      audioManager.setEnabled(nextSound);
      return {
        ...prev,
        settings: {
          ...prev.settings,
          soundEnabled: nextSound,
        },
      };
    });
  };

  const handleUpdateSettings = (nextSettings: PlayerSettings) => {
    setProgress((prev) => ({
      ...prev,
      settings: nextSettings,
    }));
  };

  const handleUpdateProfile = (nextProfile: PlayerProfile) => {
    setProgress((prev) => ({
      ...prev,
      profile: nextProfile,
    }));
  };

  const handleResetProgress = () => {
    const fresh = resetProgress();
    setProgress(fresh);
    setActiveTab('play');
  };

  return (
    <View style={styles.appRoot}>
      <View style={styles.mobileShell}>
        {activeTab === 'play' && (
          <GameScreen
            activeTab={activeTab}
            onSelectTab={setActiveTab}
            currentLevelNumber={progress.currentLevel}
            coins={progress.coins}
            undoCount={progress.undoCount}
            equippedVesselSkin={progress.equippedVesselSkin}
            equippedPalette={progress.equippedPalette}
            settings={progress.settings}
            extraTubeGrantSignal={extraTubeGrantSignal}
            onUpdateUndoCount={(nextCount) =>
              setProgress((prev) => ({ ...prev, undoCount: nextCount }))
            }
            onRequestExtraTubeAd={() => handleRequestRewardedAd('extra_tube')}
            onRequestRefillUndoAd={() => handleRequestRewardedAd('refill_undo')}
            onRequestClaim3xAd={(stars, baseCoins) =>
              handleRequestRewardedAd('claim_3x', { stars, baseCoins })
            }
            onCompleteNextLevel1x={(stars, baseCoins) =>
              recordLevelVictory(stars, baseCoins)
            }
            onToggleSound={handleToggleSound}
            onOpenSettings={() => setIsSettingsOpen(true)}
            onOpenProfile={() => setIsProfileOpen(true)}
          />
        )}

        {activeTab === 'levels' && (
          <LevelsScreen
            currentLevel={progress.currentLevel}
            maxUnlockedLevel={progress.maxUnlockedLevel}
            levelStars={progress.levelStars}
            onSelectLevel={handleLevelSelect}
            activeTab={activeTab}
            onSelectTab={setActiveTab}
            coins={progress.coins}
          />
        )}

        {activeTab === 'shop' && (
          <ShopScreen
            coins={progress.coins}
            undoCount={progress.undoCount}
            purchasedItems={progress.purchasedItems}
            equippedVesselSkin={progress.equippedVesselSkin}
            equippedPalette={progress.equippedPalette}
            onBuyOrEquip={handleBuyOrEquip}
            onWatchFreeCoinsAd={() => handleRequestRewardedAd('free_coins')}
            activeTab={activeTab}
            onSelectTab={setActiveTab}
          />
        )}

        {activeTab === 'ranks' && (
          <RanksScreen
            coins={progress.coins}
            profile={progress.profile}
            maxLevel={progress.maxUnlockedLevel}
            totalStars={totalStars}
            activeTab={activeTab}
            onSelectTab={setActiveTab}
          />
        )}

        {/* Global Modals */}
        <RewardedAdModal
          visible={adTrigger !== null}
          trigger={adTrigger}
          onCompleteReward={handleCompleteRewardedAd}
          onCancel={() => {
            setAdTrigger(null);
            setPendingWinData(null);
          }}
        />

        <SettingsModal
          visible={isSettingsOpen}
          settings={progress.settings}
          onUpdateSettings={handleUpdateSettings}
          onResetProgress={handleResetProgress}
          onClose={() => setIsSettingsOpen(false)}
        />

        <ProfileModal
          visible={isProfileOpen}
          profile={progress.profile}
          maxLevel={progress.maxUnlockedLevel}
          totalStars={totalStars}
          coins={progress.coins}
          onUpdateProfile={handleUpdateProfile}
          onClose={() => setIsProfileOpen(false)}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  appRoot: {
    flex: 1,
    backgroundColor: '#EBE7F7',
    alignItems: 'center',
    justifyContent: 'center',
  },
  mobileShell: {
    width: '100%',
    maxWidth: 480,
    height: '100%',
    backgroundColor: Colors.canvas,
    overflow: 'hidden',
    position: 'relative',
    ...Platform.select({
      web: {
        boxShadow: '0 20px 60px rgba(25, 20, 50, 0.15)',
        height: '100vh',
      } as any,
    }),
  },
});
