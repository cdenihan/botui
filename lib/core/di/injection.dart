import 'package:get_it/get_it.dart';
import 'package:stpvelox/data/datasources/linux_network_manager.dart';
import 'package:stpvelox/data/datasources/program_remote_data_source.dart';
import 'package:stpvelox/data/datasources/sensors_remote_data_source.dart';
import 'package:stpvelox/data/datasources/settings_remote_data_source.dart';
import 'package:stpvelox/data/repositories/program_repository_impl.dart';
import 'package:stpvelox/data/repositories/sensor_repository_impl.dart';
import 'package:stpvelox/data/repositories/settings_repository_impl.dart';
import 'package:stpvelox/data/repositories/wifi_repository_impl.dart';
import 'package:stpvelox/domain/repositories/i_wifi_repository.dart';
import 'package:stpvelox/domain/repositories/program_repository.dart';
import 'package:stpvelox/domain/repositories/sensor_repository.dart';
import 'package:stpvelox/domain/repositories/settings_repository.dart';
import 'package:stpvelox/domain/service/program_lifecycle_manager.dart';
import 'package:stpvelox/domain/usecases/connect_to_wifi.dart';
import 'package:stpvelox/domain/usecases/forget_wifi.dart';
import 'package:stpvelox/domain/usecases/get_available_networks.dart';
import 'package:stpvelox/domain/usecases/get_device_info.dart';
import 'package:stpvelox/domain/usecases/get_programs.dart';
import 'package:stpvelox/domain/usecases/get_sensors.dart';
import 'package:stpvelox/domain/usecases/reboot.dart';
import 'package:stpvelox/domain/usecases/start_program.dart';
import 'package:stpvelox/presentation/blocs/program/program_bloc.dart';
import 'package:stpvelox/presentation/blocs/program_selection/program_selection_bloc.dart';
import 'package:stpvelox/presentation/blocs/sensor/sensor_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/settings_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings/wifi/wifi_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => SensorBloc(getSensors: sl()));
  sl.registerFactory(() => ProgramBloc(startProgram: sl(), rebootDevice: sl()));
  sl.registerFactory(() => SettingsBloc(repository: sl()));
  sl.registerFactory(() => ProgramSelectionBloc(getPrograms: sl()));
  sl.registerFactory(() => WifiBloc(
        connectToWifi: sl(),
        forgetWifi: sl(),
        getAvailableNetworks: sl(),
        getDeviceInfo: sl(),
      ));

  sl.registerLazySingleton(() => GetSensors(repository: sl()));
  sl.registerLazySingleton(() => GetPrograms(repository: sl()));
  sl.registerLazySingleton(() => StartProgram(programLifecycleManager: sl()));
  sl.registerLazySingleton(() => ConnectToWifi(repository: sl()));
  sl.registerLazySingleton(() => ForgetWifi(repository: sl()));
  sl.registerLazySingleton(() => GetAvailableNetworks(repository: sl()));
  sl.registerLazySingleton(() => GetDeviceInfo(repository: sl()));
  sl.registerLazySingleton(() => RebootDevice());
  sl.registerLazySingleton(() => ProgramLifecycleManager());
  sl.registerLazySingleton(() => LinuxNetworkManager());

  sl.registerLazySingleton<SensorRepository>(
      () => SensorRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProgramRepository>(
      () => ProgramRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<IWifiRepository>(
      () => WifiRepositoryImpl(networkManager: sl()));

  sl.registerLazySingleton<SensorsRemoteDataSource>(
      () => SensorsRemoteDataSourceImpl());
  sl.registerLazySingleton<ProgramRemoteDataSource>(
      () => ProgramRemoteDataSourceImpl(programsDirectoryPath: 'programs'));
  sl.registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImpl(reboot: sl()));
}
