import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/service/battery_check_service.dart';
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/presentation/screens/robot_face_screen.dart';

import 'core/di/injection.dart' as di;
import 'core/utils/touch_calibrator.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ProviderScope(child: StpVeloxApp()));
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

class StpVeloxApp extends StatefulWidget {
  const StpVeloxApp({super.key});

  @override
  State<StpVeloxApp> createState() => _StpVeloxAppState();
}

class _StpVeloxAppState extends State<StpVeloxApp> {
  late final BatteryCheckService _batteryCheckService;

  @override
  void initState() {
    super.initState();
    _batteryCheckService = BatteryCheckService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _batteryCheckService.setContext(context);
    });
  }

  @override
  void dispose() {
    _batteryCheckService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      //gestures: {
      //  TapGestureRecognizer: CalibratedGestureRecognizerFactory(calibrator: calibrator),
      //},
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
        home: const RobotFaceScreen(),
      ),
    );
  }
}
