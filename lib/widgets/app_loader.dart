import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../app/app_colors.dart';

class AppLoader {
  static bool _isShowing = false;

  static void show(BuildContext context) {
    if (_isShowing) return;

    _isShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SpinKitFadingCircle(
              color: AppColors.primary,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;

    _isShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  static Future<T?> wrap<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    show(context);
    try {
      return await operation();
    } finally {
      hide(context);
    }
  }
}
