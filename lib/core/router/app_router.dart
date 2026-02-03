import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Dashboard
import 'package:stpvelox/features/dashboard/presentation/screens/dashboard_screen.dart';

// Programs
import 'package:stpvelox/features/program/presentation/screens/program_selection_screen.dart';
import 'package:stpvelox/features/program/presentation/screens/program_action_screen.dart';
import 'package:stpvelox/features/program/presentation/screens/program_screen.dart';
import 'package:stpvelox/features/program/presentation/screens/calibrate_program_screen.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';

// Sensors
import 'package:stpvelox/features/sensors/presentation/screens/sensor_selection_screen.dart';
import 'package:stpvelox/features/sensors/presentation/screens/sensor_category_screen.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor_category.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';

// Settings
import 'package:stpvelox/features/settings/presentation/pages/settings_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/touch_calibration_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/screen_rotation_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_status_screen.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_tile_page.dart';
import 'package:stpvelox/features/settings/presentation/pages/service_log_screen.dart';

// WiFi
import 'package:stpvelox/features/wifi/presentation/pages/wifi_home_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_scan_list_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_detail_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_manual_connect_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/wifi_enterprise_credential_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/device_info_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/access_point_status_screen.dart';
import 'package:stpvelox/features/wifi/presentation/pages/lan_only_status_screen.dart';
import 'package:stpvelox/features/wifi/domain/presentation/screens/saved_networks_screen.dart';
import 'package:stpvelox/features/wifi/domain/presentation/screens/access_point_config_screen.dart';
import 'package:stpvelox/features/wifi/domain/enities/wifi_network.dart';

// Other
import 'package:stpvelox/presentation/screens/robot_face_screen.dart';
import 'package:stpvelox/features/flappy_wombat/presentation/screen/flappy_wombat_game.dart';
import 'package:stpvelox/features/dev_menu/presentation/screens/dev_menu_screen.dart';
import 'package:stpvelox/features/tilt_maze/presentation/screens/tilt_maze_screen.dart';

part 'app_router.g.dart';

/// Route paths as constants
abstract class AppRoutes {
  // Dashboard
  static const dashboard = '/';

  // Sensors
  static const sensors = '/sensors';
  static const sensorCategory = '/sensors/category';
  static const sensorScreen = '/sensors/screen';

  // Programs
  static const programs = '/programs';
  static const programAction = '/programs/action';
  static const programRun = '/programs/run';
  static const programCalibrate = '/programs/calibrate';

  // Settings
  static const settings = '/settings';
  static const touchCalibration = '/settings/touch-calibration';
  static const screenRotation = '/settings/screen-rotation';
  static const serviceStatus = '/settings/services';
  static const serviceTile = '/settings/services/tile';
  static const serviceLog = '/settings/services/log';

  // WiFi
  static const wifi = '/wifi';
  static const wifiScan = '/wifi/scan';
  static const wifiDetail = '/wifi/detail';
  static const wifiManualConnect = '/wifi/manual-connect';
  static const wifiEnterprise = '/wifi/enterprise';
  static const wifiSavedNetworks = '/wifi/saved';
  static const wifiAccessPointConfig = '/wifi/ap-config';
  static const wifiAccessPointStatus = '/wifi/ap-status';
  static const wifiLanStatus = '/wifi/lan-status';
  static const wifiDeviceInfo = '/wifi/device-info';

  // Calibration (pushed dynamically from LCM)
  static const calibrationScreen = '/calibration';

  // Screensaver
  static const robotFace = '/robot-face';

  // Dev menu & easter eggs
  static const devMenu = '/dev-menu';
  static const flappyWombat = '/flappy-wombat';
  static const tiltMaze = '/tilt-maze';
}

/// Check if the current route is the dashboard
bool isDashboardRoute(String location) {
  return location == AppRoutes.dashboard || location == '/';
}

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: true,
    routes: [
      // Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => DashboardScreen(),
      ),

      // Sensors
      GoRoute(
        path: AppRoutes.sensors,
        name: 'sensors',
        builder: (context, state) => const SensorSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.sensorCategory,
        name: 'sensorCategory',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SensorCategoryScreen(
            category: extra['category'] as SensorCategory,
            sensor: extra['sensors'] as List<Sensor>,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sensorScreen,
        name: 'sensorScreen',
        builder: (context, state) {
          final screen = state.extra as Widget;
          return screen;
        },
      ),

      // Programs
      GoRoute(
        path: AppRoutes.programs,
        name: 'programs',
        builder: (context, state) => ProgramSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.programAction,
        name: 'programAction',
        builder: (context, state) {
          final program = state.extra as Program;
          return ProgramActionScreen(program: program);
        },
      ),
      GoRoute(
        path: AppRoutes.programRun,
        name: 'programRun',
        builder: (context, state) {
          final program = state.extra as Program;
          return ProgramScreen(program: program);
        },
      ),
      GoRoute(
        path: AppRoutes.programCalibrate,
        name: 'programCalibrate',
        builder: (context, state) {
          final program = state.extra as Program;
          return CalibrateProgramScreen(program: program);
        },
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.touchCalibration,
        name: 'touchCalibration',
        builder: (context, state) => const TouchCalibrationScreen(),
      ),
      GoRoute(
        path: AppRoutes.screenRotation,
        name: 'screenRotation',
        builder: (context, state) => const ScreenRotationScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceStatus,
        name: 'serviceStatus',
        builder: (context, state) => const ServiceStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.serviceTile,
        name: 'serviceTile',
        builder: (context, state) {
          final service = state.extra as Map<String, String>;
          return ServiceTilePage(service: service);
        },
      ),
      GoRoute(
        path: AppRoutes.serviceLog,
        name: 'serviceLog',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ServiceLogScreen(
            serviceName: extra['serviceName'] as String,
            displayName: extra['displayName'] as String,
          );
        },
      ),

      // WiFi
      GoRoute(
        path: AppRoutes.wifi,
        name: 'wifi',
        builder: (context, state) => const WifiHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiScan,
        name: 'wifiScan',
        builder: (context, state) => const WifiScanListScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiDetail,
        name: 'wifiDetail',
        builder: (context, state) {
          final network = state.extra as WifiNetwork;
          return WifiDetailScreen(network: network);
        },
      ),
      GoRoute(
        path: AppRoutes.wifiManualConnect,
        name: 'wifiManualConnect',
        builder: (context, state) => const WifiManualConnectScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiEnterprise,
        name: 'wifiEnterprise',
        builder: (context, state) {
          final ssid = state.extra as String;
          return WifiEnterpriseCredentialScreen(ssid: ssid);
        },
      ),
      GoRoute(
        path: AppRoutes.wifiSavedNetworks,
        name: 'wifiSavedNetworks',
        builder: (context, state) => const SavedNetworksScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiAccessPointConfig,
        name: 'wifiAccessPointConfig',
        builder: (context, state) => const AccessPointConfigScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiAccessPointStatus,
        name: 'wifiAccessPointStatus',
        builder: (context, state) => const AccessPointStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiLanStatus,
        name: 'wifiLanStatus',
        builder: (context, state) => const LanOnlyStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.wifiDeviceInfo,
        name: 'wifiDeviceInfo',
        builder: (context, state) => const DeviceInfoScreen(),
      ),

      // Dynamic calibration screen (pushed from LCM)
      GoRoute(
        path: AppRoutes.calibrationScreen,
        name: 'calibrationScreen',
        builder: (context, state) {
          final screen = state.extra as Widget;
          return screen;
        },
      ),

      // Screensaver
      GoRoute(
        path: AppRoutes.robotFace,
        name: 'robotFace',
        builder: (context, state) => const RobotFaceScreen(),
      ),

      // Dev menu & easter eggs
      GoRoute(
        path: AppRoutes.devMenu,
        name: 'devMenu',
        builder: (context, state) => const DevMenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.flappyWombat,
        name: 'flappyWombat',
        builder: (context, state) => const FlappyWombatGame(),
      ),
      GoRoute(
        path: AppRoutes.tiltMaze,
        name: 'tiltMaze',
        builder: (context, state) => const TiltMazeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri}'),
      ),
    ),
  );
}
