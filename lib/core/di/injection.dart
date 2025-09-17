import 'package:shared_preferences/shared_preferences.dart';
import 'package:stpvelox/core/utils/touch_calibrator.dart';

// Global SharedPreferences instance
SharedPreferences? _sharedPreferences;

// Getter for SharedPreferences
SharedPreferences get sharedPreferences {
  if (_sharedPreferences == null) {
    throw Exception('SharedPreferences not initialized. Call init() first.');
  }
  return _sharedPreferences!;
}

// Initialize core services that need to be available before Riverpod providers
Future<void> init() async {
  // Initialize SharedPreferences
  _sharedPreferences = await SharedPreferences.getInstance();

  // Initialize TouchCalibrator
  final touchCalibrator = TouchCalibrator();
  await touchCalibrator.loadCalibration();

  // Providers will handle their own dependency injection
}