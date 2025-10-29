import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/app_loading.dart';

/// Abstract class which provides functionality to [show] and [hide] progress
class ProgressListener {
  ProgressListener();

  final ValueNotifier<bool> _started = ValueNotifier(false);

  ValueListenable<bool> get started => _started;

  bool get isStarted => started.value;

  // Shows progress with a given message
  @mustCallSuper
  void show({String? message}) {
    _started.value = true;
  }

  // Hides message
  @mustCallSuper
  void hide() {
    _started.value = false;
  }
}

/// Derived class of [ProgressListener], shows the actual progress after a given
/// [delay], progress is not shown if interval between calling [show] and [hide]
/// is less than [delay]
class DelayedProgressListener extends ProgressListener {
  DelayedProgressListener({this.delay = 300});

  final int delay;
  bool _isStarted = false;
  bool _isDelayFinished = false;

  final ValueNotifier<bool> _startedDelayed = ValueNotifier(false);

  ValueListenable<bool> get startedDelayed => _startedDelayed;
  bool get isStartedDelayed => _startedDelayed.value;

  @override
  void show({String? message}) async {
    super.show(message: message);
    _isStarted = true;
    _isDelayFinished = false;
    if (delay != 0) {
      await Future.delayed(Duration(milliseconds: delay));
    }
    _isDelayFinished = true;
    if (_isStarted) {
      _startedDelayed.value = true;
      showDelayed(message: message);
    }
  }

  @override
  void hide() async {
    super.hide();
    _isStarted = false;
    if (_isDelayFinished) {
      _startedDelayed.value = false;
      hideDelayed();
    }
  }

  /// Derived class should override this method to show progress
  void showDelayed({String? message}) {}

  /// Derived class should override this method to hide progress
  void hideDelayed() {}
}

/// Derived class from [DelayedProgressListener], displays AppLoading
class DefaultProgressListener extends DelayedProgressListener {
  DefaultProgressListener(
    this.context, {
    super.delay = 0,
  });

  final BuildContext context;

  @override
  void showDelayed({String? message}) {
    AppLoading.show(context, message: message);
  }

  @override
  void hideDelayed() {
    AppLoading.hide(context);
  }
}
