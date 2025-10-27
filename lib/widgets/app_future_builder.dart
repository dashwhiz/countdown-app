import 'package:flutter/material.dart';
import 'app_loading.dart';

/// Callback to build data content when future completes successfully
typedef DataBuilder<T> = Widget Function(BuildContext context, T data);

/// Callback to build error content when future fails
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);

/// Callback to build progress/loading content while future is executing
typedef ProgressBuilder = Widget Function(BuildContext context);

/// Custom FutureBuilder that simplifies handling of loading, data, and error states
class AppFutureBuilder<T> extends StatelessWidget {
  const AppFutureBuilder({
    super.key,
    required this.future,
    required this.dataBuilder,
    this.progressBuilder,
    this.errorBuilder,
    this.loadingMessage,
  });

  final Future<T> future;
  final DataBuilder<T> dataBuilder;
  final ProgressBuilder? progressBuilder;
  final ErrorBuilder? errorBuilder;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        // Show loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return progressBuilder?.call(context) ??
              AppLoading(message: loadingMessage);
        }

        // Show error state
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'An error occurred',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
        }

        // Show data state - for void futures, connectionState.done is enough
        if (snapshot.connectionState == ConnectionState.done) {
          return dataBuilder(context, snapshot.data as T);
        }

        // Fallback to loading
        return progressBuilder?.call(context) ??
            AppLoading(message: loadingMessage);
      },
    );
  }
}
