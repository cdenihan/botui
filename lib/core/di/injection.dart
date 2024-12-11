import 'package:get_it/get_it.dart';
import 'package:stpvelox/data/datasources/program_remote_data_source.dart';
import 'package:stpvelox/data/datasources/sensors_remote_data_source.dart';
import 'package:stpvelox/data/datasources/settings_remote_data_source.dart';
import 'package:stpvelox/data/repositories/program_repository_impl.dart';
import 'package:stpvelox/data/repositories/sensor_repository_impl.dart';
import 'package:stpvelox/data/repositories/settings_repository_impl.dart';
import 'package:stpvelox/domain/repositories/program_repository.dart';
import 'package:stpvelox/domain/repositories/sensor_repository.dart';
import 'package:stpvelox/domain/repositories/settings_repository.dart';
import 'package:stpvelox/domain/usecases/get_sensors.dart';
import 'package:stpvelox/domain/usecases/start_program.dart';
import 'package:stpvelox/domain/usecases/update_setting.dart';
import 'package:stpvelox/presentation/blocs/program_bloc.dart';
import 'package:stpvelox/presentation/blocs/sensor_bloc.dart';
import 'package:stpvelox/presentation/blocs/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => SensorBloc(getSensors: sl()));
  sl.registerFactory(() => ProgramBloc(startProgram: sl()));
  sl.registerFactory(() => SettingsBloc(updateSetting: sl()));

  sl.registerLazySingleton(() => GetSensors(repository: sl()));
  sl.registerLazySingleton(() => StartProgram(repository: sl()));
  sl.registerLazySingleton(() => UpdateSetting(repository: sl()));

  sl.registerLazySingleton<SensorRepository>(
          () => SensorRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProgramRepository>(
          () => ProgramRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<SettingsRepository>(
          () => SettingsRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<SensorsRemoteDataSource>(
          () => SensorsRemoteDataSourceImpl());
  sl.registerLazySingleton<ProgramRemoteDataSource>(
          () => ProgramRemoteDataSourceImpl());
  sl.registerLazySingleton<SettingsRemoteDataSource>(
          () => SettingsRemoteDataSourceImpl());

}