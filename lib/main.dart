import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:stpvelox/application/inactivity/inactivity_listener.dart';
import 'package:stpvelox/core/logging/logging.dart';
import 'package:stpvelox/core/service/battery_check_service.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/features/dashboard/presentation/screens/dashboard_screen.dart';

import 'core/di/injection.dart';
import 'core/utils/touch_calibrator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();

  // Initialize providers
  final overrides = await initializeProviders();

  runApp(ProviderScope(
    overrides: overrides,
    child: const StpVeloxApp(),
  ));
}

class CalibratedTapGestureRecognizer extends TapGestureRecognizer {
  final TouchCalibrator calibrator;

  CalibratedTapGestureRecognizer({required this.calibrator, super.debugOwner});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    final Offset calibratedLocalPosition =
        calibrator.applyCalibration(event.position);

    final PointerDownEvent calibratedEvent = event.copyWith(
      position: calibratedLocalPosition,
    );
    super.addAllowedPointer(calibratedEvent);
  }
}

class CalibratedGestureRecognizerFactory
    extends GestureRecognizerFactory<CalibratedTapGestureRecognizer> {
  final TouchCalibrator calibrator;

  CalibratedGestureRecognizerFactory({required this.calibrator});

  @override
  CalibratedTapGestureRecognizer constructor() {
    return CalibratedTapGestureRecognizer(calibrator: calibrator);
  }

  @override
  void initializer(CalibratedTapGestureRecognizer instance) {}
}

class StpVeloxApp extends HookConsumerWidget {
  const StpVeloxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryService = ref.watch(batteryCheckServiceProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        batteryService.start(context);
      });
      return () => batteryService.stop();
    }, []);

    return RawGestureDetector(
      //gestures: {
      //  TapGestureRecognizer: CalibratedGestureRecognizerFactory(calibrator: calibrator),
      //},
      child: InactivityListener(
        child: MaterialApp(
          title: 'stpvelox',
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.programs,
            scaffoldBackgroundColor: AppColors.background,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.programs,
              secondary: AppColors.settings,
              surface: AppColors.surface,
              error: Colors.redAccent,
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              onSurface: Colors.white,
              onError: Colors.white,
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white70),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 80),
                textStyle: const TextStyle(fontSize: 24),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.programs,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
