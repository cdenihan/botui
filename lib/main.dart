import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stpvelox/application/inactivity/inactivity_listener.dart';
import 'package:stpvelox/core/logging/logging.dart';
import 'package:stpvelox/core/router/app_router.dart';
import 'package:stpvelox/core/service/error_message_service.dart';
import 'package:stpvelox/core/service/sensors/battery_voltage_sensor.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';
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
    final errorService = ref.watch(errorMessageServiceProvider.notifier);
    final router = ref.watch(appRouterProvider);

    // Initialize IMU accuracy sensor early so data is always available
    // Use ref.read to initialize without causing rebuilds on every value change
    ref.read(imuAccuracySensorProvider);

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
        errorService.start(context);
      });
      return () {
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
          title: 'BotUI',
          // debugShowCheckedModeBanner: false,
          routerConfig: router,
          builder: (context, child) {
            return _AppServicesStarter(
              child: Button10MonitorWidget(
                child: child ?? const SizedBox.shrink(),
              ),
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

final lowBatteryIgnoredProvider = NotifierProvider<_LowBatteryIgnored, bool>(_LowBatteryIgnored.new);

class _LowBatteryIgnored extends Notifier<bool> {
  @override
  bool build() => false;

  void ignore() => state = true;
}

class _AppServicesStarter extends ConsumerWidget {
  final Widget child;

  const _AppServicesStarter({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voltage = ref.watch(batteryVoltageSensorProvider);
    final ignored = ref.watch(lowBatteryIgnoredProvider);
    final isLow = voltage != null && voltage > 0 && voltage < 5.5;
    final showWarning = isLow && !ignored;

    return Stack(
      children: [
        child,
        if (showWarning) _LowBatteryOverlay(voltage: voltage),
      ],
    );
  }
}

class _LowBatteryOverlay extends ConsumerStatefulWidget {
  final double voltage;

  const _LowBatteryOverlay({required this.voltage});

  @override
  ConsumerState<_LowBatteryOverlay> createState() => _LowBatteryOverlayState();
}

class _LowBatteryOverlayState extends ConsumerState<_LowBatteryOverlay> {
  bool _ignoreConfirmPending = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: Material(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.battery_alert_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Low Battery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Battery voltage is ${widget.voltage.toStringAsFixed(2)}V.\n'
                  'The robot may restart at any time.\n'
                  'Please switch the battery now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 56,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _ignoreConfirmPending
                            ? () {
                                ref.read(lowBatteryIgnoredProvider.notifier).ignore();
                              }
                            : () {
                                setState(() => _ignoreConfirmPending = true);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _ignoreConfirmPending ? 'Confirm Ignore' : 'Ignore',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      height: 56,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () async {
                          final reboot = ref.read(rebootDeviceProvider);
                          await reboot.call(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Shutdown',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
