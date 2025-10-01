import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class InactivityNotifier extends Notifier<bool> {
  Timer? _timer;
  static const _timeout = Duration(seconds: 30);

  @override
  bool build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return false;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      state = true; // user inactive
    });
  }

  // Call on any user interaction
  void userActivityDetected() {
    state = false;
    _startTimer();
  }
}

final inactivityProvider = NotifierProvider<InactivityNotifier, bool>(
  InactivityNotifier.new,
);
