import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import '../services/m3u_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'plans_screen.dart';
import 'client_area_screen.dart';
import 'admin_screen.dart';
import 'local_player_screen.dart';
import 'login_screen.dart';
import '../models/media_item.dart';
import '../services/ad_service.dart';

// Top-level — required for compute() (no closures, no instance state)
Map<String, List<MediaItem>> _splitItemsByCategory(List<MediaItem> items) {
  final channels = <MediaItem>[];
  final movies = <MediaItem>[];
  final series = <MediaItem>[];
  for (final item in items) {
    if (item.isSeries) {
      series.add(item);
    } else if (item.isMovie) {
      movies.add(item);
    } else {
      channels.add(item);
    }
  }
  return {'channels': channels, 'movies': movies, 'series': series};
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isAdmin = false;
  bool _hasM3U = true;
  bool _isLoading = true;
  bool _isBlocked = false;
  bool _isCodeAccess = false;
  bool _isLocalAccess = false; // True when using DNS/user/pass local mode
  bool _adsEnabled = true;
  String _blockMessage = '';

  // Data lists
  List<MediaItem> _channels = [];
  List<MediaItem> _movies = [];
  List<MediaItem> _series = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkUserStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    M3uService().releaseSignal();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      M3uService.stopHeartbeat();
      M3uService().releaseSignal();
      if (mounted) {
        setState(() {
          _channels = [];
          _movies = [];
          _series = [];
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      // Re-check status and re-load to acquire signal again if needed
      print('MainTabScreen: Re-acquiring signal on resume');
      if (mounted) setState(() => _isLoading = true);
      _checkUserStatus();
    }
  }

  Future<void> _checkUserStatus() async {
    // Check if user entered via access code (no Supabase auth needed)
    final prefs = await SharedPreferences.getInstance();
    final bool isCodeAccess = prefs.getBool('is_code_access') ?? false;

    // ── Local access (DNS/user/pass) ──────────────────────────────────────
    final bool isLocalAccess = prefs.getBool('is_local_access') ?? false;
    if (isLocalAccess) {
      if (mounted) {
        setState(() {
          _isLocalAccess = true;
          _isCodeAccess = false;
          _isAdmin = false;
          _isBlocked = false;
          _adsEnabled = false;
          _hasM3U = true;
          _currentIndex = 0;
        });
        await _loadM3uData();
      }
      return;
    }

    if (isCodeAccess) {
      if (mounted) {
        setState(() {
          _isCodeAccess = true;
          _isLocalAccess = false;
          _isAdmin = false;
          _isBlocked = false;
          _adsEnabled = true;
          _hasM3U = true;
        });
        await _loadM3uData();
      }
      return;
    }

    final profile = await AuthService().getUserProfile();
    final isAdmin = await AuthService().isUserAdmin();

    bool isBlocked = false;
    String blockMessage = '';
    bool adsEnabled = true;

    if (!isAdmin && profile != null) {
      // Read ads preference
      adsEnabled = profile['ads_enabled'] ?? true;

      final bool isActive = profile['is_active'] ?? true;
      if (!isActive) {
        isBlocked = true;
        blockMessage =
            'Sua conta está desativada. Entre em contato com o suporte para mais informações.';
      } else {
        // If admin explicitly granted signal permission, skip expiry check
        final bool hasSignal = profile['has_signal'] ?? false;

        if (!hasSignal) {
          // 1. Check Expiration
          final String? expiryStr = profile['expiration_date'];
          if (expiryStr == null) {
            // User never had a subscription
            isBlocked = true;
            blockMessage =
                'Você ainda não possui uma assinatura ativa. Assine um plano ou assista um vídeo para liberar o acesso.';
          } else {
            final DateTime expiryDate = DateTime.parse(expiryStr);
            if (expiryDate.isBefore(DateTime.now())) {
              isBlocked = true;
              blockMessage =
                  'Sua assinatura expirou em ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}. Por favor, renove seu plano para continuar assistindo.';
            }
          }
        }

        // 2. Check for temporary reward unblock (bypass)
        final String? rewardedUntilStr = profile['rewarded_until'];
        if (rewardedUntilStr != null) {
          final DateTime rewardedUntil = DateTime.parse(rewardedUntilStr);
          if (rewardedUntil.isAfter(DateTime.now())) {
            print(
              'MainTabScreen: User is temporarily unblocked until $rewardedUntil',
            );
            isBlocked = false;
            blockMessage = '';
          }
        }
      }
    }

    final hasM3U = await _checkHasM3U(profile);

    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
        _isBlocked = isBlocked;
        _blockMessage = blockMessage;
        _adsEnabled = adsEnabled;
        _isCodeAccess = false;
        _hasM3U = hasM3U || isAdmin;
      });

      if (_hasM3U && !isBlocked) {
        await _loadM3uData(hasSignal: profile?['has_signal'] == true);
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _checkHasM3U(Map<String, dynamic>? profile) async {
    try {
      if (profile != null &&
          profile['m3u_url'] != null &&
          (profile['m3u_url'] as String).isNotEmpty) {
        return true;
      }

      // We don't acquire here anymore, just check if the user HAS signal permission
      final bool hasSignalPermission = profile?['has_signal'] ?? false;
      return hasSignalPermission;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadM3uData({bool hasSignal = false}) async {
    try {
      final m3uService = M3uService();
      String? url;
      SignalStatus? signalStatus;

      // acquireSignal() handles both authenticated users and code-access users.
      final result = await m3uService.acquireSignal();
      signalStatus = result.status;
      url = result.url;

      // Users with signal permission (or code-access) must not fall back to
      // the generic default list — show a specific message when unavailable.
      if ((url == null || url.isEmpty) && (hasSignal || _isCodeAccess)) {
        final stockExhausted = signalStatus == SignalStatus.stockExhausted;
        if (mounted) {
          setState(() {
            _isBlocked = true;
            _blockMessage = stockExhausted
                ? 'Todas as linhas estão ocupadas no momento. Aguarde alguns instantes e tente novamente.'
                : 'Seu sinal está sendo configurado. Aguarde alguns instantes e tente novamente.';
            _isLoading = false;
          });
        }
        return;
      }

      // Fallback to default list only for users without any signal permission.
      if (url == null || url.isEmpty) {
        url = await _getDefaultM3uUrl();
      }

      if (url == null || url.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Heartbeat keeps the signal alive while the app is active.
      // fire-and-forget: no await needed, timer runs in background.
      m3uService.startHeartbeat();

      // Stale-while-revalidate: show cached content instantly,
      // then refresh in background if the cache is older than 24h.
      final String resolvedUrl = url; // non-null guaranteed by checks above
      final staleItems = await m3uService.getStaleCachedItems(resolvedUrl);
      if (staleItems != null && staleItems.isNotEmpty) {
        await _categorizeItems(staleItems);
        if (mounted) setState(() => _isLoading = false);

        final fresh = await m3uService.isCacheFresh(resolvedUrl);
        if (!fresh) {
          m3uService.parseM3uUrl(resolvedUrl).then((freshItems) async {
            if (freshItems.isNotEmpty) {
              m3uService.cacheM3uItems(resolvedUrl, freshItems);
              if (mounted) await _categorizeItems(freshItems);
            }
          }).catchError((_) {});
        }
        return;
      }

      // No cache — fetch and display (shows loading spinner)
      final items = await m3uService.parseM3uUrl(resolvedUrl);
      if (items.isNotEmpty) {
        await m3uService.cacheM3uItems(resolvedUrl, items);
        await _categorizeItems(items);
      }
    } catch (e) {
      print('MainTabScreen: Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _getDefaultM3uUrl() async {
    // Basic implementation of default list fetch
    try {
      final response = await Supabase.instance.client
          .schema('startflix')
          .from('default_m3u_lists')
          .select('m3u_url')
          .eq('is_active', true)
          .order('priority', ascending: false)
          .limit(1)
          .maybeSingle();
      return response?['m3u_url'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<void> _categorizeItems(List<MediaItem> items) async {
    final result = await compute(_splitItemsByCategory, items);
    if (mounted) {
      setState(() {
        _channels = result['channels']!;
        _movies = result['movies']!;
        _series = result['series']!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not loading and user is not admin and has no M3U, show LocalPlayerScreen
    // But we still want to show the bottom bar if the user is logged in
    final bool showMainUI = _hasM3U || _isAdmin;

    // Check if we are on a TV (or large screen) to potentially show a Side Bar instead?
    // For now, let's stick to BottomBar but make it TV friendly (larger).
    final isTv =
        MediaQuery.of(context).size.shortestSide > 600 ||
        MediaQuery.of(context).size.width > 900;

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              )
            : (_isBlocked
                  ? _buildBlockedScreen()
                  : (showMainUI
                        ? _buildMainContent()
                        : LocalPlayerScreen())), // Fallback for users with no list
        bottomNavigationBar: _buildBottomBar(isTv),
        floatingActionButton: _isAdmin
            ? FloatingActionButton(
                backgroundColor: AppColors.primaryRed,
                mini: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminScreen()),
                  );
                },
                child: const Icon(Icons.admin_panel_settings, size: 22),
              )
            : null,
      ),
    );
  }

  Widget _buildMainContent() {
    // Local access: only Canais / Filmes / Séries — no TMDB, no plans
    if (_isLocalAccess) {
      return IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(fixedTabIndex: 0, preloadedItems: _channels, adsEnabled: false),
          HomeScreen(fixedTabIndex: 1, preloadedItems: _movies, adsEnabled: false),
          HomeScreen(fixedTabIndex: 2, preloadedItems: _series, adsEnabled: false),
        ],
      );
    }

    return IndexedStack(
      index: _currentIndex,
      children: [
        DiscoverScreen(),
        HomeScreen(fixedTabIndex: 0, preloadedItems: _channels, adsEnabled: _adsEnabled),
        HomeScreen(fixedTabIndex: 1, preloadedItems: _movies, adsEnabled: _adsEnabled),
        HomeScreen(fixedTabIndex: 2, preloadedItems: _series, adsEnabled: _adsEnabled),
        PlansScreen(),
        ClientAreaScreen(),
      ],
    );
  }

  Widget _buildBlockedScreen() {
    // Only block Canais, Filmes, Series and Discover (maybe?)
    // If they are on Plans or Profile, let them see it.
    if (_currentIndex == 4 || _currentIndex == 5) {
      return IndexedStack(
        index: _currentIndex,
        children: [
          Container(), // 0
          Container(), // 1
          Container(), // 2
          Container(), // 3
          const PlansScreen(),
          const ClientAreaScreen(),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, AppColors.primaryRed.withOpacity(0.1)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.block_flipped,
            color: AppColors.primaryRed,
            size: 80,
          ),
          const SizedBox(height: 30),
          const Text(
            'ACESSO BLOQUEADO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _blockMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              setState(() => _currentIndex = 4); // Go to Plans
            },
            child: const Text(
              'RENOVAR AGORA',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 25),
          // --- Rewards Section ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ACESSO TEMPORÁRIO',
                      style: GoogleFonts.outfit(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Assista um vídeo completo e libere o acesso total ao app por 1 hora gratuitamente!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _showRewardedAd();
                  },
                  icon: const Icon(Icons.video_library),
                  label: const Text('ASSISTIR E LIBERAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRewardedAd() {
    AdService().showRewardedAd(
      onRewardEarned: (reward) async {
        final user = AuthService().currentUser;
        if (user != null) {
          final oneHourLater = DateTime.now().add(const Duration(hours: 1));
          await AuthService().updateProfile(
            id: user.id,
            rewardedUntil: oneHourLater,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sucesso! App liberado por 1 hora.'),
                backgroundColor: Colors.green,
              ),
            );
            _checkUserStatus(); // Refresh state
          }
        }
      },
      onAdClosed: () {},
      onAdFailed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Vídeo não disponível no momento ou não carregou. Tente novamente.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Future<void> _logoutLocalAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_local_access');
    await prefs.remove('local_dns');
    await prefs.remove('local_username');
    await prefs.remove('local_password');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget _buildBottomBar(bool isTv) {
    if (_isLocalAccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: isTv ? 80 : null,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: const Border(top: BorderSide(color: Colors.white10)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.primaryRed,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedFontSize: isTv ? 16 : 14,
              unselectedFontSize: isTv ? 14 : 12,
              iconSize: isTv ? 32 : 24,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.tv_outlined), activeIcon: Icon(Icons.tv), label: 'Canais',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined), activeIcon: Icon(Icons.movie), label: 'Filmes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_outlined),
                  activeIcon: Icon(Icons.video_library),
                  label: 'Séries',
                ),
              ],
            ),
          ),
          // Logout strip
          GestureDetector(
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF141414),
                  title: const Text('Sair do Acesso Local', style: TextStyle(color: Colors.white)),
                  content: const Text(
                    'Deseja voltar à tela de login?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );
              if (ok == true) _logoutLocalAccess();
            },
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 14, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(width: 6),
                  Text(
                    'Acesso Local — Toque para sair',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      height: isTv ? 80 : null,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: isTv ? 16 : 14,
        unselectedFontSize: isTv ? 14 : 12,
        iconSize: isTv ? 32 : 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv_outlined), activeIcon: Icon(Icons.tv), label: 'Canais',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined), activeIcon: Icon(Icons.movie), label: 'Filmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            activeIcon: Icon(Icons.video_library),
            label: 'Séries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline), activeIcon: Icon(Icons.star), label: 'Planos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
