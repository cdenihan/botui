import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class InactivityNotifier extends StateNotifier<bool> {
  InactivityNotifier(this._timeout) : super(false) {
    _startTimer(); // start immediately
  }

  final Duration _timeout;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      state = true; // User inactive
    });
  }

  /// Call this whenever the user interacts (tap, scroll, etc.)
  void userActivityDetected() {
    state = false;
    _startTimer(); // reset timer
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final inactivityProvider =
StateNotifierProvider<InactivityNotifier, bool>((ref) {
  return InactivityNotifier(const Duration(seconds: 30)); // adjust duration
});