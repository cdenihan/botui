import 'package:stpvelox/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:stpvelox/features/settings/domain/entities/setting.dart';
import 'package:stpvelox/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Setting>> getSettings() async {
    return await remoteDataSource.fetchSettings();
  }
}
