import React from 'react';
import { AdMobService } from './types';
import { WebAdBanner } from '../../components/navigation/WebAdBanner';

class WebAdMobService implements AdMobService {
  isInitialized = true;

  async initialize(): Promise<void> {
    // No-op on Web, ready immediately
    this.isInitialized = true;
  }

  async showRewardedAd(
    _onEarnedReward: () => void,
    _onDismiss?: () => void
  ): Promise<boolean> {
    // Returns false so the App can show its interactive 3s Web simulation modal
    return false;
  }

  BannerComponent: React.FC = () => {
    return <WebAdBanner />;
  };
}

export const adMobService: AdMobService = new WebAdMobService();
