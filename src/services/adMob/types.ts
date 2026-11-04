import React from 'react';

export interface AdMobService {
  isInitialized: boolean;
  initialize: () => Promise<void>;
  showRewardedAd: (onEarnedReward: () => void, onDismiss?: () => void) => Promise<boolean>;
  BannerComponent: React.FC;
}
