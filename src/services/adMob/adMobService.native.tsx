import React, { useEffect, useState } from 'react';
import { View, StyleSheet } from 'react-native';
import mobileAds, {
  BannerAd,
  BannerAdSize,
  RewardedAd,
  RewardedAdEventType,
  AdEventType,
  TestIds,
} from 'react-native-google-mobile-ads';
import { AdMobService } from './types';
import { getBannerAdUnitId, getRewardedAdUnitId } from './adMobConfig';

class NativeAdMobService implements AdMobService {
  isInitialized = false;
  private rewardedAd: RewardedAd | null = null;
  private isRewardedLoaded = false;
  private onEarnedRewardCallback: (() => void) | null = null;
  private onDismissCallback: (() => void) | null = null;

  async initialize(): Promise<void> {
    try {
      await mobileAds().initialize();
      this.isInitialized = true;
      this.loadRewardedAd();
    } catch (error) {
      console.warn('[AdMob] Failed to initialize mobileAds:', error);
    }
  }

  private loadRewardedAd(): void {
    const unitId = __DEV__ ? TestIds.REWARDED : getRewardedAdUnitId();
    this.rewardedAd = RewardedAd.createForAdRequest(unitId, {
      requestNonPersonalizedAdsOnly: false,
    });

    this.rewardedAd.addAdEventListener(RewardedAdEventType.LOADED, () => {
      this.isRewardedLoaded = true;
    });

    this.rewardedAd.addAdEventListener(RewardedAdEventType.EARNED_REWARD, () => {
      this.onEarnedRewardCallback?.();
    });

    this.rewardedAd.addAdEventListener(AdEventType.CLOSED, () => {
      this.isRewardedLoaded = false;
      this.onDismissCallback?.();
      this.onEarnedRewardCallback = null;
      this.onDismissCallback = null;
      // Preload next rewarded ad
      this.loadRewardedAd();
    });

    this.rewardedAd.load();
  }

  async showRewardedAd(
    onEarnedReward: () => void,
    onDismiss?: () => void
  ): Promise<boolean> {
    if (this.rewardedAd && this.isRewardedLoaded) {
      this.onEarnedRewardCallback = onEarnedReward;
      this.onDismissCallback = onDismiss || null;
      try {
        await this.rewardedAd.show();
        return true;
      } catch (e) {
        console.warn('[AdMob] Error showing rewarded ad:', e);
        return false;
      }
    } else {
      // Re-trigger load
      this.loadRewardedAd();
      return false;
    }
  }

  BannerComponent: React.FC = () => {
    const [adFailed, setAdFailed] = useState(false);
    const unitId = __DEV__ ? TestIds.BANNER : getBannerAdUnitId();

    if (adFailed) {
      return null;
    }

    return (
      <View style={styles.bannerWrapper}>
        <BannerAd
          unitId={unitId}
          size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER}
          requestOptions={{
            requestNonPersonalizedAdsOnly: false,
          }}
          onAdFailedToLoad={(err) => {
            console.warn('[AdMob Banner] Failed to load:', err);
            setAdFailed(true);
          }}
        />
      </View>
    );
  };
}

const styles = StyleSheet.create({
  bannerWrapper: {
    width: '100%',
    alignItems: 'center',
    justifyContent: 'center',
    marginVertical: 4,
  },
});

export const adMobService: AdMobService = new NativeAdMobService();
