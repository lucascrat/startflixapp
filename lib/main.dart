import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/custom_http_client.dart';

import 'screens/main_tab_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plans_screen.dart';
import 'services/ad_service.dart';
import 'services/download_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Downloader
  if (!kIsWeb) {
    await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true, // option: set to false to disable ignoring ssl checking (default: false)
    );
  }

  // Initialize Download Service (Listeners)
  await DownloadService().initialize();

  // Initialize AdMob
  await AdService.initialize();

  // Limit Memory Cache footprint for images to avoid OutOfMemory on low-end devices
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      150 * 1024 * 1024; // 150 MB
  PaintingBinding.instance.imageCache.maximumSize = 500; // Total 500 images

  // Initialization of Supabase
  bool isSupabaseInitialized = false;
  if (AppConstants.supabaseUrl != 'YOUR_SUPABASE_URL') {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      httpClient: CustomHttpClient(),
    );
    isSupabaseInitialized = true;
  }

  runApp(StartFlixApp(isSupabaseInitialized: isSupabaseInitialized));
}

class StartFlixApp extends StatefulWidget {
  final bool isSupabaseInitialized;

  const StartFlixApp({super.key, required this.isSupabaseInitialized});

  @override
  State<StartFlixApp> createState() => _StartFlixAppState();
}

class _StartFlixAppState extends State<StartFlixApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial attempt to show App Open Ad
    Future.delayed(const Duration(seconds: 2), () {
      AdService().showAppOpenAdIfAvailable();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the app comes back to foreground, try to show the Open Ad
    if (state == AppLifecycleState.resumed) {
      AdService().showAppOpenAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StartFlix Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: Colors.black, // Pure black for premium feel
        focusColor: AppColors.primaryRed.withOpacity(
          0.5,
        ), // Visible focus for TV
        textTheme: GoogleFonts.outfitTextTheme(
          // Modern premium font
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryRed,
          secondary: AppColors.primaryRed,
          surface: Color(0xFF141414), // Netflix-like surface
        ),
      ),
      builder: (context, child) {
        // Ensure consistent font scaling for TV
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(
              mediaQueryData.size.shortestSide > 600 ? 1.2 : 1.0,
            ),
          ),
          child: Shortcuts(
            shortcuts: <LogicalKeySet, Intent>{
              LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
            },
            child: child!,
          ),
        );
      },
      home: widget.isSupabaseInitialized ? const AuthGate() : const MainTabScreen(),
      routes: {'/plans': (context) => const PlansScreen()},
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryRed),
                  SizedBox(height: 20),
                  Text(
                    'STARTFLIX',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return const MainTabScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
