import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../theme/app_colors.dart';

/// Adaptive AdMob banner on supported mobile devices, with a styled AD fallback
/// while loading or on web/desktop/test environments.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _failedToLoad = false;
  bool _attemptedLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_attemptedLoad) {
      final adService = AdService.maybeOf(context);
      if (adService != null && adService.isRealAdsActive) {
        _attemptedLoad = true;
        final width = math.min(
          MediaQuery.sizeOf(context).width.truncate(),
          480,
        );
        _loadAdaptiveBanner(adService, width);
      }
    }
  }

  Future<void> _loadAdaptiveBanner(AdService adService, int width) async {
    AdSize adSize = AdSize.banner;
    if (width > 0) {
      try {
        final adaptive =
            await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          width,
        );
        if (adaptive != null) {
          adSize = adaptive;
        }
      } catch (_) {
        adSize = AdSize.banner;
      }
    }

    if (!mounted) return;

    final banner = adService.createBannerAd(
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _failedToLoad = false;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _isLoaded = false;
            _failedToLoad = true;
          });
        },
      ),
    );

    if (banner == null) {
      if (mounted) {
        setState(() {
          _failedToLoad = true;
        });
      }
      return;
    }

    _bannerAd = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adService = AdService.maybeOf(context);
    if (adService != null && adService.isRealAdsActive) {
      if (_isLoaded && _bannerAd != null) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          alignment: Alignment.center,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      }
      if (_failedToLoad) {
        return const SizedBox.shrink();
      }
      return const SizedBox(height: 50);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEBE8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAD6EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'AD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF363152),
                    ),
                  ),
                ),
                const Flexible(
                  child: Text(
                    'Water Sort 3D • Free Gift',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF28233C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => AudioService.maybeOf(context)?.playClick(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.coralDeep,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: const Text(
                'Install',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
