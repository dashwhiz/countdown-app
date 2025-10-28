import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app_logger.dart';
import 'app_strings.dart';
import 'app_theme.dart';
import '../services/storage_service.dart';
import '../services/appwrite_service.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/init_error_screen.dart';

enum InitState { loading, success, error }

class CountdownApp extends StatefulWidget {
  const CountdownApp({super.key});

  @override
  State<CountdownApp> createState() => _CountdownAppState();
}

class _CountdownAppState extends State<CountdownApp> {
  InitState _initState = InitState.loading;

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

      // Initialize Appwrite service
      await Get.putAsync(() => AppwriteService().init());

      AppLogger.info('✅ App initialized successfully');

      // Wait minimum 3 seconds for branding/splash
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(
          Duration(milliseconds: 3000 - elapsed.inMilliseconds),
        );
      }

      if (mounted) {
        setState(() => _initState = InitState.success);
      }
    } catch (e, stackTrace) {
      AppLogger.fatal('❌ Failed to start app', e, stackTrace);

      // Still wait for minimum splash duration before showing error
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 3000) {
        await Future.delayed(
          Duration(milliseconds: 3000 - elapsed.inMilliseconds),
        );
      }

      if (mounted) {
        setState(() => _initState = InitState.error);
      }
    }
  }

  void _retryInitialization() {
    setState(() => _initState = InitState.loading);
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _getScreenForState(),
    );
  }

  Widget _getScreenForState() {
    switch (_initState) {
      case InitState.loading:
        return const SplashScreen();
      case InitState.success:
        return const HomeScreen();
      case InitState.error:
        return InitErrorScreen(onRetry: _retryInitialization);
    }
  }
}
