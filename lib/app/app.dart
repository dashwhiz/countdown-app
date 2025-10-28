import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app_logger.dart';
import 'app_strings.dart';
import 'app_theme.dart';
import '../services/storage_service.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';

class CountdownApp extends StatefulWidget {
  const CountdownApp({super.key});

  @override
  State<CountdownApp> createState() => _CountdownAppState();
}

class _CountdownAppState extends State<CountdownApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    try {
      AppLogger.info('🚀 Starting Countdown App...');

      // Initialize timezone database
      tz.initializeTimeZones();

      // Initialize storage service
      await Get.putAsync(() => StorageService().init());

      AppLogger.info('✅ App initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.fatal('❌ Failed to start app', e, stackTrace);
    }

    // Wait minimum 3 seconds for branding/splash
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 3000) {
      await Future.delayed(
        Duration(milliseconds: 3000 - elapsed.inMilliseconds),
      );
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _isInitialized ? const HomeScreen() : const SplashScreen(),
    );
  }
}
