import React from 'react';
import { adMobService } from '../../services/adMob';

export const AdBanner: React.FC = () => {
  const Banner = adMobService.BannerComponent;
  return <Banner />;
};
