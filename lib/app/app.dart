import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'app_logger.dart';
import 'app_strings.dart';
import 'app_theme.dart';
import '../services/storage_service.dart';
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
    try {
      AppLogger.info('🚀 Starting Countdown App...');

      // Initialize timezone database
      tz.initializeTimeZones();

      await Get.putAsync(() => StorageService().init());

      AppLogger.info('✅ App initialized successfully');
      setState(() => _isInitialized = true);
    } catch (e, stackTrace) {
      AppLogger.fatal('❌ Failed to start app', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _isInitialized
          ? const HomeScreen()
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
