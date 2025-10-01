import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String host = "127.0.0.1";
const int port = 9995;

// --- STATES ---
abstract class CalibrationState {
  const CalibrationState();
}

class CalibrationInitial extends CalibrationState {}

class CalibrationInProgress extends CalibrationState {
  final String message;
  final String? frameBase64;
  const CalibrationInProgress(this.message, {this.frameBase64});
}

class CalibrationComplete extends CalibrationState {}

// --- NOTIFIER ---
class CalibrationNotifier extends Notifier<CalibrationState> {
  Timer? _frameTimer;
  int _step = 0;

  @override
  CalibrationState build() {
    ref.onDispose(() => _frameTimer?.cancel());
    return CalibrationInitial();
  }

  void startCalibration() {
    _frameTimer?.cancel();
    _frameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      updateFrame();
    });
    _step = 0;
    state = const CalibrationInProgress("Please click the potato");
  }

  Future<void> updateFrame() async {
    final frame = await _getFrame();
    if (state is CalibrationInProgress) {
      final current = state as CalibrationInProgress;
      state = CalibrationInProgress(current.message, frameBase64: frame);
    }
  }

  Future<void> calibratePotato(Offset tapPosition) async {
    await _sendCommand(
        "CAL_POTATO ${tapPosition.dx.toInt()} ${tapPosition.dy.toInt()}");
    state = const CalibrationInProgress("Potato calibrated. Now click the red pom.");
    _step = 1;
  }

  Future<void> calibratePomRed(Offset tapPosition) async {
    await _sendCommand(
        "CAL_POM_RED ${tapPosition.dx.toInt()} ${tapPosition.dy.toInt()}");
    state = const CalibrationInProgress("Red pom calibrated. Now click the orange pom.");
    _step = 2;
  }

  Future<void> calibratePomOrange(Offset tapPosition) async {
    await _sendCommand(
        "CAL_POM_ORANGE ${tapPosition.dx.toInt()} ${tapPosition.dy.toInt()}");
    state = const CalibrationInProgress("Orange pom calibrated. Now click the yellow pom.");
    _step = 3;
  }

  Future<void> calibratePomYellow(Offset tapPosition) async {
    await _sendCommand(
        "CAL_POM_YELLOW ${tapPosition.dx.toInt()} ${tapPosition.dy.toInt()}");
    state = const CalibrationInProgress(
        "Yellow pom calibrated. Press Done if satisfied or Retry.");
  }

  void completeCalibration() {
    _frameTimer?.cancel();
    state = CalibrationComplete();
  }

  void retryCalibration() {
    _frameTimer?.cancel();
    startCalibration();
  }

  // --- HELPERS ---
  Future<String> _sendCommand(String command) async {
    try {
      Socket socket = await Socket.connect(host, port);
      socket.write("$command\n");
      await socket.flush();
      final response =
      await socket.cast<List<int>>().transform(utf8.decoder).join();
      socket.destroy();
      return response;
    } catch (e) {
      return "ERROR: $e";
    }
  }

  Future<String?> _getFrame() async {
    try {
      Socket socket = await Socket.connect(host, port);
      socket.write("GET_FRAME\n");
      await socket.flush();

      final completer = Completer<String>();
      socket.listen(
            (data) {
          completer.complete(utf8.decode(data));
        },
        onError: (error) {
          if (!completer.isCompleted) completer.completeError(error);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete("");
        },
        cancelOnError: true,
      );

      String response;
      try {
        response = await completer.future.timeout(const Duration(seconds: 1));
      } catch (_) {
        socket.destroy();
        return null;
      }

      socket.destroy();
      if (response.startsWith("FRAME ")) {
        String base64Data = response.substring(6).trim();
        while (base64Data.length % 4 != 0) {
          base64Data += '=';
        }
        return base64Data;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

}

// --- PROVIDER ---
final calibrationProvider =
    NotifierProvider<CalibrationNotifier, CalibrationState>(
  CalibrationNotifier.new,
);
