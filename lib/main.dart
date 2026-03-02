import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stpvelox/application/inactivity/inactivity_listener.dart';
import 'package:stpvelox/core/logging/logging.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/service/battery_check_service.dart';
import 'package:stpvelox/core/service/error_message_service.dart';
import 'package:stpvelox/core/service/button10_monitor_widget.dart';
import 'package:stpvelox/core/service/sensors/imu_accuracy_sensor.dart';
import 'package:stpvelox/core/utils/colors/colors.dart';
import 'package:stpvelox/features/screen_renderer/application/screen_renderer_provider.dart';

import 'core/di/injection.dart';
import 'core/utils/touch_calibrator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();

  // Initialize providers
  final (sharedPreferences, touchCalibrator) = await initializeProviders();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      touchCalibratorProvider.overrideWithValue(touchCalibrator),
    ],
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

final _log = Logger('StpVeloxApp');

class StpVeloxApp extends HookConsumerWidget {
  const StpVeloxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryService = ref.watch(batteryCheckServiceProvider.notifier);
    final errorService = ref.watch(errorMessageServiceProvider.notifier);
    final router = ref.watch(appRouterProvider);

    // Initialize IMU accuracy sensor early so data is always available
    ref.watch(imuAccuracySensorProvider);

    // Handle dynamic UI screen navigation at app level so the listener
    // survives route changes (go_router swaps routes, unmounting previous ones).
    ref.listen<Map<String, dynamic>?>(screenRenderProviderProvider, (previous, next) {
      final currentLocation = router.routerDelegate.currentConfiguration.fullPath;
      final isDashboard = isDashboardRoute(currentLocation);
      final isCalibrationRoute = currentLocation == AppRoutes.calibrationScreen;

      final wasOpen = previous != null;
      final shouldBeOpen = next != null;

      if (!wasOpen && shouldBeOpen && isDashboard) {
        _log.info('[DynamicUI] Opening dynamic UI screen');
        router.go(AppRoutes.calibrationScreen);
      } else if (wasOpen && !shouldBeOpen && isCalibrationRoute) {
        _log.info('[DynamicUI] Closing dynamic UI screen, returning to dashboard');
        router.go(AppRoutes.dashboard);
      }
    });

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        batteryService.start(context);
        errorService.start(context);
      });
      return () {
        batteryService.stop();
        errorService.stop();
      };
    }, []);

    final calibrator = ref.watch(touchCalibratorProvider);

    return RawGestureDetector(
      gestures: {
        CalibratedTapGestureRecognizer:
            CalibratedGestureRecognizerFactory(calibrator: calibrator),
      },
      child: InactivityListener(
        child: MaterialApp.router(
          title: 'stpvelox',
          // debugShowCheckedModeBanner: false,
          routerConfig: router,
          builder: (context, child) {
            return Button10MonitorWidget(
              child: child ?? const SizedBox.shrink(),
            );
          },
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
        ),
      ),
    );
  }
}
