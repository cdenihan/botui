// sensors/providers/sensor_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/sensors/domain/entities/sensor.dart';
import 'package:stpvelox/features/sensors/domain/usecases/get_sensors.dart';
import 'package:stpvelox/features/sensors/data/repositories/sensor_repository_impl.dart';
import 'package:stpvelox/features/sensors/data/datasource/sensors_remote_data_source.dart';

/// Remote data source provider
final sensorsRemoteDataSourceProvider = Provider<SensorsRemoteDataSource>(
      (ref) => SensorsRemoteDataSourceImpl(),
);

/// Repository provider
final sensorRepositoryProvider = Provider<SensorRepositoryImpl>(
      (ref) => SensorRepositoryImpl(
    remoteDataSource: ref.watch(sensorsRemoteDataSourceProvider),
  ),
);

/// Use case provider
final getSensorsUseCaseProvider = Provider<GetSensors>(
      (ref) => GetSensors(repository: ref.watch(sensorRepositoryProvider)),
);

/// Sensors FutureProvider
final sensorsProvider = FutureProvider<List<Sensor>>((ref) async {
  final getSensors = ref.watch(getSensorsUseCaseProvider);
  return getSensors.execute();
});
