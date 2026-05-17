import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../models/media_item.dart';
import '../services/m3u_service.dart';
import '../services/auth_service.dart';
import '../services/download_service.dart';
import '../services/ad_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_player_screen.dart';
import 'series_detail_screen.dart';

// Helper to get table with schema (Consolidated to startflix schema)
SupabaseQueryBuilder _fromTable(String table) {
  return Supabase.instance.client.schema('startflix').from(table);
}

class HomeScreen extends StatefulWidget {
  final int? fixedTabIndex; // 0 = Channels, 1 = Movies, 2 = Series
  final List<MediaItem>? preloadedItems;
  final bool adsEnabled; // Whether ads should be shown for this user

  const HomeScreen({super.key, this.fixedTabIndex, this.preloadedItems, this.adsEnabled = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final M3uService _m3uService = M3uService();
  final AuthService _authService = AuthService();
  late TabController _tabController;

  List<MediaItem> _items = [];
  Map<String, List<MediaItem>> _groupedItems = {};

  // Categorized Lists
  List<MediaItem> _allTvChannels = [];
  List<MediaItem> _allMovies = [];
  List<MediaItem> _allSeries = [];

  // Pre-computed series lookup map for O(1) episode finding
  Map<String, List<MediaItem>> _seriesEpisodesMap = {};

  // Logic to determine active tab based on fixedTabIndex
  int get _currentIndex => widget.fixedTabIndex ?? _tabController.index;

  bool _isLoading = true;

  // Loading progress tracking
  double _loadingProgress = 0.0;
  String _loadingPhase = 'Conectando...';
  int _loadedChannels = 0;
  int _loadedMovies = 0;
  int _loadedSeries = 0;

  bool _isBlocked = false;
  String _blockMessage = '';
  bool _isJustRewarded = false; // Flag to allow immediate access after ad

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    if (widget.fixedTabIndex == null) {
      _tabController.addListener(_onTabChanged);
    }
    _loadUserContent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Show App Open Ad when returning to the app
      AdService().showAppOpenAdIfAvailable();
    }
  }

  void _showRewardedAdForAccess() {
    setState(() {
      _loadingPhase = 'Carregando vídeo...';
      _isLoading = true;
    });

    AdService().showRewardedAd(
      onRewardEarned: (reward) async {
        final user = AuthService().currentUser;
        if (user != null) {
          final newRewardTime = DateTime.now().add(const Duration(hours: 6)); 
          await AuthService().updateProfile(
            id: user.id,
            rewardedUntil: newRewardTime,
          );
          // Set blocked to false immediately upon earning reward
          if (mounted) {
            setState(() {
              _isBlocked = false;
              _isJustRewarded = true; // Temporary bypass
            });
          }
        }
      },
      onAdClosed: () {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
          _loadUserContent(); // Refresh content and access state
        }
      },
      onAdFailed: () {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erro ao carregar vídeo. Tente novamente mais tarde.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _updateViewForTab();
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadUserContent() async {
    try {
      if (widget.preloadedItems != null && widget.preloadedItems!.isNotEmpty) {
        // In fixed tab mode, items are already categorized by MainTabScreen.
        // Use them directly without re-categorizing.
        if (mounted) {
          setState(() {
            if (widget.fixedTabIndex == 0) {
              _allTvChannels = widget.preloadedItems!;
            } else if (widget.fixedTabIndex == 1) {
              _allMovies = widget.preloadedItems!;
            } else if (widget.fixedTabIndex == 2) {
              _allSeries = widget.preloadedItems!;
              _buildSeriesEpisodesMap();
            }
            _items = widget.preloadedItems!;
          });
        }
        _updateViewForTab();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _loadingProgress = 0.1;
          _loadingPhase = 'Verificando acesso...';
        });
      }

      final prefs = await SharedPreferences.getInstance();
      final bool isCodeAccess = prefs.getBool('is_code_access') ?? false;
      final String? tempM3uUrl = prefs.getString('temp_m3u_url');

      if (isCodeAccess && tempM3uUrl != null) {
        print('HomeScreen: Using quick access code list.');
        await _loadContent(tempM3uUrl);
        return;
      }

      final user = AuthService().currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (mounted) {
        setState(() {
          _loadingProgress = 0.2;
          _loadingPhase = 'Carregando configurações...';
        });
      }

      final profile = await _authService.getUserProfile();

      if (profile == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // 1. Check if user is active
      final bool isActive = profile['is_active'] ?? true;
      if (!isActive) {
        // Release any held signal to return it to the stock
        await _m3uService.releaseSignal();

        if (mounted) {
          setState(() {
            _isBlocked = true;
            _blockMessage =
                'Sua conta está desativada. Entre em contato com o suporte para mais informações.';
            _isLoading = false;
          });
        }
        return;
      }

      // 2. Check if subscription has expired
      // If admin granted signal permission, treat subscription as valid
      final bool hasSignal = profile['has_signal'] ?? false;
      final String? expiryStr = profile['expiration_date'];
      bool isExpired = !hasSignal;
      if (!hasSignal && expiryStr != null) {
        final DateTime expiryDate = DateTime.parse(expiryStr);
        if (expiryDate.isAfter(DateTime.now())) {
          isExpired = false;
        }
      }

      if (isExpired) {
        // User has NO active paid plan. Check rewarded system.
        final String? rewardedUntilStr = profile['rewarded_until'];

        if (rewardedUntilStr == null) {
          // First time they are expired without any rewarded usage! Give 30 mins free.
          final DateTime newRewardTime = DateTime.now().add(
            const Duration(minutes: 30),
          );
          await _authService.updateProfile(
            id: user.id,
            rewardedUntil: newRewardTime,
          );
          // Proceed loading m3u
        } else {
          final DateTime rewardedUntil = DateTime.parse(rewardedUntilStr).toUtc();
          if (rewardedUntil.isBefore(DateTime.now().toUtc())) {
            // Reward expired! 
            // We no longer block here. We allow them to browse, but block playback.
            print("HomeScreen: User reward expired at $rewardedUntil, allowing browse but will block playback.");
          }
        }
      }

      String? url = profile['m3u_url'];

      // If user has no manual m3u_url, try to acquire a Dynamic Signal (Stock list)
      if (url == null || url.isEmpty) {
        print('HomeScreen: No manual M3U URL, checking for dynamic signal...');
        if (mounted) {
          setState(() {
            _loadingProgress = 0.25;
            _loadingPhase = 'Buscando sinal liberado...';
          });
        }
        url = await _m3uService.getUserM3uUrl();
        if (url != null) {
          print('HomeScreen: Dynamic signal acquired: $url');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Sinal do estoque Mídia liberado e conectado!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('HomeScreen: No dynamic signal found.');
        }
      }

      // If user has no list and no signal, try to get default list from database
      if (url == null || url.isEmpty) {
        if (mounted) {
          setState(() {
            _loadingProgress = 0.3;
            _loadingPhase = 'Buscando lista padrão...';
          });
        }
        url = await _getDefaultM3uUrl();
      }

      if (url != null && url.isNotEmpty) {
        print('HomeScreen: Found URL to load: $url');
        if (mounted) {
          setState(() {
            _loadingProgress = 0.4;
            _loadingPhase = 'Baixando lista M3U...';
          });
        }
        await _loadContent(url);
      } else {
        print('HomeScreen: No URL found for user.');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error loading content: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _getDefaultM3uUrl() async {
    try {
      final response = await Supabase.instance.client
          .schema('startflix')
          .from('default_m3u_lists')
          .select('m3u_url')
          .eq('is_active', true)
          .order('priority', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return response['m3u_url'] as String?;
      }
    } catch (e) {
      print('Error getting default M3U: $e');
    }
    return null;
  }

  Future<void> _loadContent(String url) async {
    try {
      if (mounted) {
        setState(() {
          _loadingProgress = 0.5;
          _loadingPhase = 'Verificando cache...';
        });
      }

      // 1. Tentar carregar do cache primeiro
      final cachedItems = await _m3uService.getCachedM3uItems(url);
      if (cachedItems != null && cachedItems.isNotEmpty) {
        print("HomeScreen: Usando lista em cache para agilizar...");
        _processItemsSequentially(cachedItems);
        return;
      }

      if (mounted) {
        setState(() {
          _loadingProgress = 0.5;
          _loadingPhase = 'Processando conteúdo...';
        });
      }

      final items = await _m3uService.parseM3uUrl(url);

      if (!mounted) return;

      // 2. Salvar no cache para a próxima vez
      await _m3uService.cacheM3uItems(url, items);

      _processItemsSequentially(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _processItemsSequentially(List<MediaItem> items) async {
    if (!mounted) return;

    // Process items with progress updates
    final totalItems = items.length;
    int processed = 0;

    List<MediaItem> channels = [];
    List<MediaItem> movies = [];
    List<MediaItem> series = [];

    // Chunk size for processing to keep UI responsive without excessive overhead
    const int chunkSize = 2000;

    for (int i = 0; i < totalItems; i++) {
      final item = items[i];
      if (item.isSeries) {
        series.add(item);
      } else if (item.isMovie) {
        movies.add(item);
      } else {
        channels.add(item);
      }

      processed++;

      // Update progress in chunks
      if (processed % chunkSize == 0 || processed == totalItems) {
        if (!mounted) return;
        final processProgress = 0.5 + (processed / totalItems) * 0.4;
        setState(() {
          _loadingProgress = processProgress;
          _loadedChannels = channels.length;
          _loadedMovies = movies.length;
          _loadedSeries = series.length;
          _loadingPhase = processProgress < 0.7
              ? 'Lendo Canais...'
              : (processProgress < 0.85
                    ? 'Lendo Filmes...'
                    : 'Lendo Séries...');
        });
        // Yield to UI thread
        await Future.delayed(Duration.zero);
      }
    }

    if (!mounted) return;

    try {
      setState(() {
        _loadingProgress = 0.95;
        _loadingPhase = 'Organizando categorias...';
      });

      // Clear memory references of the raw items if possible?
      // Actually we need them for _items.

      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        setState(() {
          _items = items;
          _allTvChannels = channels;
          _allMovies = movies;
          _allSeries = series;
          _loadingProgress = 1.0;
          _loadingPhase = 'Pronto!';
        });

        _buildSeriesEpisodesMap();
        _updateViewForTab();

        setState(() {
          _isLoading = false;
        });

        // Show interstitial ad after content loads (only if ads are enabled)
        if (widget.adsEnabled && !kIsWeb) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              AdService().showInterstitialAd();
            }
          });
        }
      }
    } catch (e) {
      print("Error in final processing: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Pre-compute a map of series title -> list of episodes for O(1) lookups
  void _buildSeriesEpisodesMap() {
    _seriesEpisodesMap = {};
    for (var item in _allSeries) {
      _seriesEpisodesMap.putIfAbsent(item.title, () => []).add(item);
    }
  }

  /// Returns the source list for the currently active tab index
  List<MediaItem> _getCurrentSourceList() {
    if (_currentIndex == 0) return _allTvChannels;
    if (_currentIndex == 1) return _allMovies;
    if (_currentIndex == 2) return _allSeries;
    return _allTvChannels;
  }

  void _updateViewForTab() {
    List<MediaItem> sourceList = [];
    if (_currentIndex == 0) {
      sourceList = _allTvChannels;
    } else if (_currentIndex == 1) {
      sourceList = _allMovies;
    } else if (_currentIndex == 2) {
      sourceList = _allSeries;
    }

    _groupedItems = {};

    if (_currentIndex == 2) {
      // Series - show unique series
      final Map<String, Set<String>> addedSeriesPerGroup = {};

      for (var item in sourceList) {
        final group = item.group ?? 'Outros';
        if (!_groupedItems.containsKey(group)) {
          _groupedItems[group] = [];
          addedSeriesPerGroup[group] = {};
        }

        if (!addedSeriesPerGroup[group]!.contains(item.title)) {
          _groupedItems[group]!.add(item);
          addedSeriesPerGroup[group]!.add(item.title);
        }
      }
    } else {
      for (var item in sourceList) {
        final group = item.group ?? 'Outros';
        if (!_groupedItems.containsKey(group)) {
          _groupedItems[group] = [];
        }
        _groupedItems[group]!.add(item);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen with progress
    if (_isLoading) {
      // Show interstitial ad when content is ready
      // Disabled for now because it might pop up in the background
      /*
      if (_loadingProgress >= 0.9) {
        AdService().showInterstitialAd();
      }
      */

      return LoadingScreen(
        progress: _loadingProgress,
        currentPhase: _loadingPhase,
        channelsCount: _loadedChannels,
        moviesCount: _loadedMovies,
        seriesCount: _loadedSeries,
      );
    }

    if (_isBlocked) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
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
              Text(
                'ACESSO BLOQUEADO',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
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
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              if (_blockMessage.contains('4 HORAS'))
                Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                      ),
                      onPressed: _showRewardedAdForAccess,
                      label: Text(
                        'GANHAR 4H GRÁTIS',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Navigate to plans or refresh
                  Navigator.pushNamed(context, '/plans');
                },
                child: Text(
                  'RENOVAR AGORA',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                child: const Text(
                  'SAIR DA CONTA',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    String title = 'Ao Vivo & VOD';
    if (widget.fixedTabIndex == 0) title = 'Canais de TV';
    if (widget.fixedTabIndex == 1) title = 'Filmes';
    if (widget.fixedTabIndex == 2) title = 'Séries';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.fixedTabIndex != null
          ? null // Hide AppBar if in fixed tab mode (Canais, Filmes, Series)
          : AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              title: Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryRed,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.tv, size: 20),
                    text: 'Canais (${_allTvChannels.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.movie, size: 20),
                    text: 'Filmes (${_allMovies.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.video_library, size: 20),
                    text: 'Séries (${_getUniqueSeriesCount()})',
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _loadingProgress = 0.0;
                      _loadingPhase = 'Atualizando...';
                      _loadedChannels = 0;
                      _loadedMovies = 0;
                      _loadedSeries = 0;
                    });
                    _loadUserContent();
                  },
                ),
              ],
            ),
      body: Column(
        children: [
          // Banner Ad at top (Only if ads are enabled for this user)
          if (widget.fixedTabIndex != null)
            SizedBox(
              height: MediaQuery.of(context).padding.top + 10,
            ), // Safe area spacer if no AppBar
          if (widget.adsEnabled) AdService.createBannerAd(),

          // Main content
          Expanded(
            child: _getCurrentSourceList().isEmpty
                ? _buildEmptyState()
                : (widget.fixedTabIndex != null
                      ? _buildContentList()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildContentList(),
                            _buildContentList(),
                            _buildContentList(),
                          ],
                        )),
          ),
        ],
      ),
    );
  }

  int _getUniqueSeriesCount() {
    final uniqueTitles = <String>{};
    for (var item in _allSeries) {
      uniqueTitles.add(item.title);
    }
    return uniqueTitles.length;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.live_tv, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Nenhum conteúdo disponível',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Sua lista M3U está vazia ou não configurada',
            style: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    if (_groupedItems.isEmpty) {
      return Center(
        child: Text(
          'Nenhum conteúdo nesta categoria',
          style: GoogleFonts.outfit(color: Colors.grey),
        ),
      );
    }

    final sortedKeys = _groupedItems.keys.toList();
    sortedKeys.sort((a, b) {
      final aUp = a.toUpperCase();
      final bUp = b.toUpperCase();

      // Prioritize Lançamentos/Lancamentos
      if (aUp.contains('LANÇAMENTO') || aUp.contains('LANCAMENTO')) return -1;
      if (bUp.contains('LANÇAMENTO') || bUp.contains('LANCAMENTO')) return 1;

      // Prioritize 4K
      if (aUp.contains('4K')) return -1;
      if (bUp.contains('4K')) return 1;

      // Alphabetical for the rest
      return a.compareTo(b);
    });

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final items = _groupedItems[key]!;
        return _buildCategorySection(key, items);
      },
    );
  }

  Widget _buildCategorySection(String title, List<MediaItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryRed,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MovieCard(item: item, onTap: () => _onItemTap(item));
            },
          ),
        ),
      ],
    );
  }

  void _onItemTap(MediaItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final bool isCodeAccess = prefs.getBool('is_code_access') ?? false;

    if (!isCodeAccess) {
      final profile = await _authService.getUserProfile();
      if (profile == null) return;

      // Check if subscription or reward is active
      final bool isPaidActive = profile['expiration_date'] != null &&
          DateTime.parse(profile['expiration_date']).toUtc().isAfter(DateTime.now().toUtc());

      final bool isRewardActive = (profile['rewarded_until'] != null &&
          DateTime.parse(profile['rewarded_until']).toUtc().isAfter(DateTime.now().toUtc())) || _isJustRewarded;

      if (!isPaidActive && !isRewardActive) {
        // Access expired! Show floating card (dialog)
        _showFloatingAdCard(item);
        return;
      }
    }

    if (item.isSeries) {
      // Use pre-computed map for O(1) lookup instead of O(n) linear search
      final episodes =
          _seriesEpisodesMap[item.title] ??
          _allSeries.where((e) => e.title == item.title).toList();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SeriesDetailScreen(
            seriesName: item.title,
            episodes: episodes,
            logoUrl: item.logoUrl,
          ),
        ),
      );
    } else {
      _showPlayDialog(item);
    }
  }

  void _showFloatingAdCard(MediaItem item) async {
    final int rewardMinutes = await _authService.getAdRewardDuration();
    final String rewardText = rewardMinutes >= 60 
      ? '${(rewardMinutes / 60).floor()}h${rewardMinutes % 60 > 0 ? (rewardMinutes % 60).toString() + 'm' : ''}'
      : '${rewardMinutes}m';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster Header
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: item.logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(item.logoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.lock_clock_outlined, color: AppColors.primaryRed, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Acesso Limitado',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sua assinatura expirou. Assista um vídeo curto para liberar todo o conteúdo por $rewardText!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showRewardedAdAndUnlock(item, rewardMinutes);
                      },
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                      label: Text(
                        'LIBERAR $rewardText AGORA',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Mais tarde', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardedAdAndUnlock(MediaItem item, int durationMinutes) {
    setState(() {
      _isLoading = true;
      _loadingPhase = 'Carregando vídeo...';
    });

    AdService().showRewardedAd(
      onRewardEarned: (reward) async {
        final user = AuthService().currentUser;
        if (user != null) {
          final newRewardTime = DateTime.now().add(Duration(minutes: durationMinutes));
          await AuthService().updateProfile(
            id: user.id,
            rewardedUntil: newRewardTime,
          );
          // Reward earned, update local state immediately
          if (mounted) {
            setState(() {
              _isJustRewarded = true;
            });
          }
          print('Reward earned and profile updated for user ${user.id}. Access granted until $newRewardTime');
        }
      },
      onAdClosed: () async {
        if (mounted) {
          setState(() {
            _loadingPhase = 'Liberando acesso...';
          });
          
          // Re-verify profile one more time to ensure state is clean
          await _loadUserContent();
          
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            // After ad and refresh, retry the item tap which should now succeed
            _onItemTap(item);
          }
        }
      },
      onAdFailed: () {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar anúncio. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _showPlayDialog(MediaItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            Row(
              children: [
                // Thumbnail
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                    image: item.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(item.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.logoUrl == null
                      ? const Icon(Icons.movie, color: Colors.grey, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.group ?? 'VOD',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Play button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(videoUrl: item.url),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.white,
                ),
                label: Text(
                  'Assistir Agora',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Download button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _downloadItem(item);
                },
                icon: const Icon(Icons.download, size: 24),
                label: Text(
                  'Baixar para Assistir Offline',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadItem(MediaItem item) async {
    final downloadService = DownloadService();

    // Request permissions
    final hasPermission = await downloadService.requestPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de armazenamento necessária'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show download started
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Baixando: ${item.title}'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Start download
    final taskId = await downloadService.startDownload(item);

    if (mounted) {
      if (taskId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Download iniciado em segundo plano! Acompanhe na aba Downloads.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao iniciar download.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
