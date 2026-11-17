import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

typedef RewardedAdOverride = Future<bool> Function({
  required VoidCallback onUserEarnedReward,
  VoidCallback? onAdFailedToLoad,
  VoidCallback? onAdDismissed,
});

typedef InterstitialAdOverride = Future<bool> Function({
  VoidCallback? onAdDismissed,
});

/// Central AdMob manager handling UMP GDPR consent, Banner ads, Rewarded ads,
/// and Interstitial ads.
///
/// Uses Google's official AdMob Test IDs in debug/profile/test builds (`!kReleaseMode`),
/// production Android IDs in release builds (`kReleaseMode`), and supports
/// `--dart-define` overrides:
/// - `ADMOB_BANNER_ANDROID_ID`
/// - `ADMOB_BANNER_IOS_ID`
/// - `ADMOB_REWARDED_ANDROID_ID`
/// - `ADMOB_REWARDED_IOS_ID`
/// - `ADMOB_INTERSTITIAL_ANDROID_ID`
/// - `ADMOB_INTERSTITIAL_IOS_ID`
class AdService extends ChangeNotifier {
  // Official Google AdMob Test Ad Unit IDs
  static const String _defaultAndroidBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _defaultIosBannerId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _defaultAndroidRewardedId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _defaultIosRewardedId =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _defaultAndroidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _defaultIosInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  // Production Google AdMob Ad Unit IDs for ColorFlow: Sort Master (Android)
  static const String _prodAndroidBannerId =
      'ca-app-pub-1406372626466870/9836837778';
  static const String _prodAndroidRewardedId =
      'ca-app-pub-1406372626466870/6497579755';
  static const String _prodAndroidInterstitialId =
      'ca-app-pub-1406372626466870/9207503579';

  static const String _envAndroidBannerId = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID_ID',
  );
  static const String _envIosBannerId = String.fromEnvironment(
    'ADMOB_BANNER_IOS_ID',
    defaultValue: _defaultIosBannerId,
  );
  static const String _envAndroidRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID_ID',
  );
  static const String _envIosRewardedId = String.fromEnvironment(
    'ADMOB_REWARDED_IOS_ID',
    defaultValue: _defaultIosRewardedId,
  );
  static const String _envAndroidInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ANDROID_ID',
  );
  static const String _envIosInterstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS_ID',
    defaultValue: _defaultIosInterstitialId,
  );

  final bool enableRealAds;
  final RewardedAdOverride? _rewardedOverride;
  final InterstitialAdOverride? _interstitialOverride;

  bool _initialized = false;
  bool _sdkInitialized = false;
  bool _isLoadingRewarded = false;
  bool _isShowingRewarded = false;
  bool _isLoadingInterstitial = false;
  bool _isShowingInterstitial = false;
  int _rewardedLoadAttempts = 0;
  int _interstitialLoadAttempts = 0;
  static const int _maxLoadRetries = 3;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  AdService({
    this.enableRealAds = true,
    RewardedAdOverride? rewardedOverride,
    InterstitialAdOverride? interstitialOverride,
  })  : _rewardedOverride = rewardedOverride,
        _interstitialOverride = interstitialOverride;

  /// Looks up [AdService] from [Provider] without throwing if absent in tests.
  static AdService? maybeOf(BuildContext context) {
    try {
      return Provider.of<AdService>(context, listen: false);
    } catch (_) {
      return null;
    }
  }

  /// True only when running on Android or iOS outside Web and Flutter test VMs.
  bool get isRealAdsActive {
    if (!enableRealAds || kIsWeb) return false;
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (!isMobile) return false;
    return !_isTestBinding();
  }

  static bool _isTestBinding() {
    try {
      final name = WidgetsBinding.instance.runtimeType.toString();
      return name.contains('Test');
    } catch (_) {
      return true;
    }
  }

  bool get isInitialized => _initialized;
  bool get isSdkInitialized => _sdkInitialized;
  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;
  bool get isBusyWithRewardedAd => _isLoadingRewarded || _isShowingRewarded;

  bool get isUsingTestIds =>
      bannerAdUnitId == _defaultAndroidBannerId ||
      bannerAdUnitId == _defaultIosBannerId ||
      rewardedAdUnitId == _defaultAndroidRewardedId ||
      rewardedAdUnitId == _defaultIosRewardedId ||
      interstitialAdUnitId == _defaultAndroidInterstitialId ||
      interstitialAdUnitId == _defaultIosInterstitialId;

  String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _envIosBannerId;
    }
    if (_envAndroidBannerId.isNotEmpty) return _envAndroidBannerId;
    return kReleaseMode ? _prodAndroidBannerId : _defaultAndroidBannerId;
  }

  String get rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _envIosRewardedId;
    }
    if (_envAndroidRewardedId.isNotEmpty) return _envAndroidRewardedId;
    return kReleaseMode ? _prodAndroidRewardedId : _defaultAndroidRewardedId;
  }

  String get interstitialAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _envIosInterstitialId;
    }
    if (_envAndroidInterstitialId.isNotEmpty) return _envAndroidInterstitialId;
    return kReleaseMode
        ? _prodAndroidInterstitialId
        : _defaultAndroidInterstitialId;
  }

  /// Runs UMP GDPR consent flow, initializes Google Mobile Ads SDK, and
  /// preloads Rewarded and Interstitial ads.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!isRealAdsActive) {
      notifyListeners();
      return;
    }

    try {
      final params = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          } catch (_) {}
          await _initializeMobileAds();
        },
        (_) async {
          await _initializeMobileAds();
        },
      );
    } catch (_) {
      await _initializeMobileAds();
    }
  }

  Future<void> _initializeMobileAds() async {
    if (_sdkInitialized || !isRealAdsActive) return;
    try {
      await MobileAds.instance.initialize();
      _sdkInitialized = true;
      notifyListeners();
      loadRewardedAd();
      loadInterstitialAd();
    } catch (_) {
      // Keep running gracefully when plugin channels are unavailable.
    }
  }

  /// Creates a [BannerAd] ready to load, or `null` when real ads are inactive.
  BannerAd? createBannerAd({
    AdSize size = AdSize.banner,
    required BannerAdListener listener,
  }) {
    if (!isRealAdsActive) return null;
    try {
      return BannerAd(
        adUnitId: bannerAdUnitId,
        request: const AdRequest(),
        size: size,
        listener: listener,
      );
    } catch (_) {
      return null;
    }
  }

  /// Preloads a [RewardedAd] into memory.
  void loadRewardedAd() {
    if (!isRealAdsActive || _isLoadingRewarded || _rewardedAd != null) {
      return;
    }

    _isLoadingRewarded = true;
    notifyListeners();

    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _rewardedLoadAttempts = 0;
            _isLoadingRewarded = false;
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedAd = null;
            _isLoadingRewarded = false;
            _rewardedLoadAttempts++;
            notifyListeners();
            if (_rewardedLoadAttempts <= _maxLoadRetries) {
              Future<void>.delayed(
                Duration(seconds: 2 * _rewardedLoadAttempts),
                loadRewardedAd,
              );
            }
          },
        ),
      );
    } catch (_) {
      _isLoadingRewarded = false;
      notifyListeners();
    }
  }

  /// Displays a rewarded video ad and triggers [onUserEarnedReward] only when
  /// the user earns the reward. Returns `false` when unavailable so the UI
  /// can fall back cleanly on unsupported platforms/tests.
  Future<bool> showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdFailedToLoad,
    VoidCallback? onAdDismissed,
  }) async {
    if (_rewardedOverride != null) {
      _isShowingRewarded = true;
      notifyListeners();
      try {
        return await _rewardedOverride!(
          onUserEarnedReward: onUserEarnedReward,
          onAdFailedToLoad: onAdFailedToLoad,
          onAdDismissed: onAdDismissed,
        );
      } finally {
        _isShowingRewarded = false;
        notifyListeners();
      }
    }

    if (!isRealAdsActive) {
      onAdFailedToLoad?.call();
      return false;
    }

    if (_isShowingRewarded) return false;

    RewardedAd? ad = _rewardedAd;
    _rewardedAd = null;
    ad ??= await _loadRewardedOnDemand();

    if (ad == null) {
      onAdFailedToLoad?.call();
      loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    _isShowingRewarded = true;
    notifyListeners();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd shownAd) {
        shownAd.dispose();
        _isShowingRewarded = false;
        notifyListeners();
        loadRewardedAd();
        onAdDismissed?.call();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd shownAd, AdError error) {
        shownAd.dispose();
        _isShowingRewarded = false;
        notifyListeners();
        loadRewardedAd();
        onAdFailedToLoad?.call();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView _, RewardItem __) {
          rewardEarned = true;
          onUserEarnedReward();
        },
      );
    } catch (_) {
      ad.dispose();
      _isShowingRewarded = false;
      notifyListeners();
      onAdFailedToLoad?.call();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  Future<RewardedAd?> _loadRewardedOnDemand() async {
    if (!isRealAdsActive) return null;

    final completer = Completer<RewardedAd?>();
    _isLoadingRewarded = true;
    notifyListeners();

    try {
      RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd loadedAd) {
            _isLoadingRewarded = false;
            _rewardedLoadAttempts = 0;
            notifyListeners();
            if (!completer.isCompleted) completer.complete(loadedAd);
          },
          onAdFailedToLoad: (LoadAdError _) {
            _isLoadingRewarded = false;
            notifyListeners();
            if (!completer.isCompleted) completer.complete(null);
          },
        ),
      );
    } catch (_) {
      _isLoadingRewarded = false;
      notifyListeners();
      if (!completer.isCompleted) completer.complete(null);
    }

    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _isLoadingRewarded = false;
        notifyListeners();
        return null;
      },
    );
  }

  /// Preloads an [InterstitialAd] into memory.
  void loadInterstitialAd() {
    if (!isRealAdsActive ||
        _isLoadingInterstitial ||
        _interstitialAd != null) {
      return;
    }

    _isLoadingInterstitial = true;
    notifyListeners();

    try {
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialLoadAttempts = 0;
            _isLoadingInterstitial = false;
            notifyListeners();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            _isLoadingInterstitial = false;
            _interstitialLoadAttempts++;
            notifyListeners();
            if (_interstitialLoadAttempts <= _maxLoadRetries) {
              Future<void>.delayed(
                Duration(seconds: 2 * _interstitialLoadAttempts),
                loadInterstitialAd,
              );
            }
          },
        ),
      );
    } catch (_) {
      _isLoadingInterstitial = false;
      notifyListeners();
    }
  }

  /// Shows a preloaded [InterstitialAd] if ready and never interrupts an active
  /// or loading rewarded ad session.
  Future<bool> showInterstitialAdIfReady({VoidCallback? onAdDismissed}) async {
    if (isBusyWithRewardedAd || _isShowingInterstitial) {
      return false;
    }

    if (_interstitialOverride != null) {
      _isShowingInterstitial = true;
      notifyListeners();
      try {
        return await _interstitialOverride!(onAdDismissed: onAdDismissed);
      } finally {
        _isShowingInterstitial = false;
        notifyListeners();
      }
    }

    if (!isRealAdsActive) return false;

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      return false;
    }
    _interstitialAd = null;

    final completer = Completer<bool>();
    _isShowingInterstitial = true;
    notifyListeners();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd shownAd) {
        shownAd.dispose();
        _isShowingInterstitial = false;
        notifyListeners();
        loadInterstitialAd();
        onAdDismissed?.call();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
      onAdFailedToShowFullScreenContent:
          (InterstitialAd shownAd, AdError error) {
        shownAd.dispose();
        _isShowingInterstitial = false;
        notifyListeners();
        loadInterstitialAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
      _isShowingInterstitial = false;
      notifyListeners();
      loadInterstitialAd();
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    super.dispose();
  }
}
