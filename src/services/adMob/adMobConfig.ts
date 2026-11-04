import { Platform } from 'react-native';

/**
 * Google AdMob Configuration
 *
 * NOTE: For development and testing, official Google Sample Ad Unit IDs are used.
 * Replace with your real production AdMob IDs once your account is created and approved:
 * https://admob.google.com/
 */
export const ADMOB_CONFIG = {
  // Official Sample Test Application IDs
  appId: {
    android: 'ca-app-pub-3940256099942544~3347511713',
    ios: 'ca-app-pub-3940256099942544~1458002511',
  },

  // Official Sample Test Banner Ad Unit IDs
  bannerAdUnitId: {
    android: 'ca-app-pub-3940256099942544/6300978111',
    ios: 'ca-app-pub-3940256099942544/2934735716',
  },

  // Official Sample Test Rewarded Video Ad Unit IDs
  rewardedAdUnitId: {
    android: 'ca-app-pub-3940256099942544/5224354917',
    ios: 'ca-app-pub-3940256099942544/1712485313',
  },

  // Official Sample Test Interstitial Ad Unit IDs
  interstitialAdUnitId: {
    android: 'ca-app-pub-3940256099942544/1033173712',
    ios: 'ca-app-pub-3940256099942544/4411468910',
  },
};

export const getBannerAdUnitId = (): string => {
  return Platform.OS === 'ios'
    ? ADMOB_CONFIG.bannerAdUnitId.ios
    : ADMOB_CONFIG.bannerAdUnitId.android;
};

export const getRewardedAdUnitId = (): string => {
  return Platform.OS === 'ios'
    ? ADMOB_CONFIG.rewardedAdUnitId.ios
    : ADMOB_CONFIG.rewardedAdUnitId.android;
};

export const getInterstitialAdUnitId = (): string => {
  return Platform.OS === 'ios'
    ? ADMOB_CONFIG.interstitialAdUnitId.ios
    : ADMOB_CONFIG.interstitialAdUnitId.android;
};
