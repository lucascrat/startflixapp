import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Ad Unit IDs
  static const String _bannerAdUnitId =
      'ca-app-pub-6105194579101073/4248632461';
  static const String _interstitialAdUnitId =
      'ca-app-pub-6105194579101073/4092627248';
  static const String _nativeAdUnitId =
      'ca-app-pub-6105194579101073/5274580152';
  static const String _rewardedAdUnitId =
      'ca-app-pub-6105194579101073/3162330167';
  static const String _appOpenAdUnitId =
      'ca-app-pub-6105194579101073/4611143202';

  // Cached ads
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenLoadTime;
  DateTime? _lastAppOpenAdShown;
  DateTime? _lastInterstitialShown; // Time tracking for interstitials

  // Initialization
  static bool _isInitialized = false;

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      print('AdMob initialization skipped on Web');
      _isInitialized = true;
      return;
    }
    await MobileAds.instance.initialize();
    _isInitialized = true;
    print('AdMob initialized successfully');

    // Pre-load ads
    AdService()._loadInterstitialAd();
    AdService()._loadRewardedAd();
    AdService().loadAppOpenAd(); // Pre-load AppOpen
  }

  /// Create a Banner Ad widget
  static Widget createBannerAd({AdSize size = AdSize.banner}) {
    return _BannerAdWidget(size: size);
  }

  /// Create a large banner ad widget
  static Widget createLargeBannerAd() {
    return _BannerAdWidget(size: AdSize.largeBanner);
  }

  /// Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('Interstitial ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd(); // Reload for next time
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          print('Rewarded ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd(); // Reload
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Show Interstitial Ad with Frequency Capping (3 minutes)
  Future<bool> showInterstitialAd({bool force = false}) async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      print('Interstitial ad not ready');
      return false;
    }

    // Check frequency cap (3 minutes) unless forced
    if (!force && _lastInterstitialShown != null) {
      final difference = DateTime.now().difference(_lastInterstitialShown!);
      if (difference.inMinutes < 3) {
        print('Interstitial frequency cap active. Wait ${3 - difference.inMinutes}m more.');
        return false;
      }
    }

    await _interstitialAd!.show();
    _lastInterstitialShown = DateTime.now();
    return true;
  }

  /// Show Rewarded Ad
  Future<void> showRewardedAd({
    required Function(RewardItem reward) onRewardEarned,
    required VoidCallback onAdClosed,
    required VoidCallback onAdFailed,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      print('Rewarded ad not ready, attempting to load and show...');
      _loadRewardedAd();
      onAdFailed();
      return;
    }

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onRewardEarned(reward);
      },
    );

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        onAdClosed();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdReady = false;
        onAdFailed();
        _loadRewardedAd();
      },
    );
  }

  /// Check if rewarded ad is ready
  bool get isRewardedReady => _isRewardedAdReady;

  /// Check if interstitial is ready
  bool get isInterstitialReady => _isInterstitialAdReady;

  /// Load App Open Ad
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          print('AppOpenAd loaded');
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  /// Show App Open Ad
  void showAppOpenAdIfAvailable() {
    // If not loaded yet, or already showing one, just try to load (if null)
    if (_appOpenAd == null) {
      loadAppOpenAd();
      return;
    }

    if (_isShowingAppOpenAd) return;

    // Prevent infinite loop by not showing if shown recently (e.g. less than 15 seconds ago)
    if (_lastAppOpenAdShown != null &&
        DateTime.now().difference(_lastAppOpenAdShown!) <
            const Duration(seconds: 15)) {
      return;
    }

    // Google recommends only keeping an AppOpenAd cached for up to 4 hours.
    if (_appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) >
            const Duration(hours: 4)) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAppOpenAd();
      return;
    }

    _isShowingAppOpenAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        _lastAppOpenAdShown = DateTime.now();
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (ad) {
        _lastAppOpenAdShown = DateTime.now();
      },
    );
    _appOpenAd!.show();
  }

  /// Get Native Ad Unit ID
  static String get nativeAdUnitId => _nativeAdUnitId;
}

/// Banner Ad Widget
class _BannerAdWidget extends StatefulWidget {
  final AdSize size;

  const _BannerAdWidget({required this.size});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _loadAdaptiveAd();
  }

  Future<void> _loadAdaptiveAd() async {
    // Get the adaptive size
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) {
      print('Unable to get adaptive banner size. Using default.');
      _createStandardBanner();
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6105194579101073/4248632461',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Adaptive banner ad failed to load: $error');
          ad.dispose();
          _createStandardBanner(); // Fallback
        },
      ),
    );

    _bannerAd!.load();
  }

  void _createStandardBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6105194579101073/4248632461',
      size: widget.size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isLoaded || _bannerAd == null) {
      return SizedBox(
        height: widget.size.height.toDouble(),
        width: double.infinity,
      );
    }

    return Container(
      alignment: Alignment.center,
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Native Ad Widget
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('Native ad failed to load: $error');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: const Color(0xFF1A1A1A),
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFFE50914),
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
      ),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isLoaded || _nativeAd == null) {
      return const SizedBox(height: 100);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 100,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
