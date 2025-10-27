import 'package:flutter/material.dart';
import '../app/app_strings.dart';
import '../widgets/app_dialog.dart';

/// Abstract class which should display error on [error] function call.
///
/// Contains default error codes [unknownErrorCode], [offlineStatusCode], [timeOutStatusCode]
abstract class ErrorListener {
  /// Code is used for unknown error cases.
  static const unknownErrorCode = -1;

  /// Code is used to identify network errors when device has no connection.
  static const offlineStatusCode = -2;

  /// Code is used to identify network timeout or slow connection cases.
  static const timeOutStatusCode = -3;

  /// Derived class should implement this method and display the error.
  Future<void> error({int? code, String? message});
}

typedef ErrorCallback = Future<void> Function({int? code, String? message});

class ErrorListenerCallback extends ErrorListener {
  ErrorListenerCallback(this.callback);

  ErrorCallback callback;

  @override
  Future<void> error({int? code, String? message}) =>
      callback(code: code, message: message);
}

/// MessagedErrorListener provides general mapping between error codes and messages.
/// If the message is not provided via [error] method, this class will try to find
/// a message via provided code.
abstract class MessagedErrorListener extends ErrorListener {
  MessagedErrorListener(this.context);

  final BuildContext context;

  /// Handles mapping between [code] and [message] if the message is null.
  @override
  Future<void> error({int? code, String? message}) async {
    code ??= ErrorListener.unknownErrorCode;
    await onShowError(code, message ?? defineMessageFromCode(code));
  }

  /// Derived class should override this method and display error message
  Future<void> onShowError(int code, String message);

  static String defineMessageFromCode(int? code) {
    if (code == ErrorListener.offlineStatusCode) {
      return 'Please check your internet connection';
    } else if (code == ErrorListener.timeOutStatusCode) {
      return 'Connection timeout. Please try again';
    }

    return 'An unexpected error occurred';
  }
}

/// Displays default app dialog via [AppDialog.showError].
class DialogErrorListener extends MessagedErrorListener {
  DialogErrorListener(super.context);

  @override
  Future<void> onShowError(int code, String message) async {
    await AppDialog.showError(
      context,
      message: message,
      title: AppStrings.errorTitle,
    );
  }
}
