import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/core/di/injection.dart' as di;
import 'package:stpvelox/core/utils/colors.dart';
import 'package:stpvelox/presentation/blocs/program_bloc.dart';
import 'package:stpvelox/presentation/blocs/sensor_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings_bloc.dart';
import 'package:stpvelox/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const StpVeloxApp());
}

class StpVeloxApp extends StatelessWidget {
  const StpVeloxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SensorBloc>(
          create: (_) => di.sl<SensorBloc>(),
        ),
        BlocProvider<ProgramBloc>(
          create: (_) => di.sl<ProgramBloc>(),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>(),
        ),
      ],
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
    );
  }
}
