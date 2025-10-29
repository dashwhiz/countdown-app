import 'dart:io';
import 'package:flutter/foundation.dart';
import '../app/app_error_listeners.dart';
import '../app/app_progress_listeners.dart';

/// Wrapper on generic [result].
/// [success] is true if [result] was fetched successfully,
/// is false if [result] was fetched with failure. Also contains [exception]
/// in case of a failure.
class Operation<R> {
  const Operation({required this.success, this.result, this.exception});

  final bool success;
  final Object? exception;
  final R? result;
}

/// Wraps the [scope]'s execution in progress [progressListener]
/// and error [errorListener] scopes. Notifies the [progressListener] about
/// start and end of [scope], and in case of errors catches the exception and
/// notifies it via the [errorListener].
Future<Operation<R>> scope<R>({
  required Future<R> Function() scope,
  ProgressListener? progressListener,
  String? progressMessage,
  ErrorListener? errorListener,
  bool awaitForErrorListener = true,
}) async {
  Operation<R> result;
  try {
    progressListener?.show(message: progressMessage);

    result = Operation(success: true, result: await scope());

    progressListener?.hide();
  } catch (e, s) {
    debugPrintStack(stackTrace: s, label: e.toString());
    result = Operation(success: false, exception: e, result: null);
    progressListener?.hide();

    int code = ErrorListener.unknownErrorCode;
    String? message;

    if (e is SocketException) {
      code = ErrorListener.timeOutStatusCode;
    }

    if (errorListener != null) {
      if (awaitForErrorListener) {
        await errorListener.error(code: code, message: message);
      } else {
        // ignore: unawaited_futures
        errorListener.error(code: code, message: message);
      }
    }
  }
  return result;
}
