// application/settings_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/core/di/injection.dart' as di;
import 'package:stpvelox/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:stpvelox/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:stpvelox/features/settings/domain/entities/setting.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';

// Data source provider using global SharedPreferences
final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSourceImpl>((ref) {
  return SettingsRemoteDataSourceImpl(
    reboot: RebootDevice(),
    sharedPreferences: di.sharedPreferences,
  );
});

// Repository provider
final settingsRepositoryProvider = Provider<SettingsRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource: remoteDataSource);
});

// AsyncNotifier for settings
class SettingsNotifier extends AsyncNotifier<List<Setting>> {
  late final SettingsRepositoryImpl repository;

  @override
  Future<List<Setting>> build() async {
    repository = ref.read(settingsRepositoryProvider);
    return loadSettings();
  }

  Future<List<Setting>> loadSettings() async {
    return await repository.getSettings();
  }

  Future<void> tapSetting(Setting setting, BuildContext context) async {
    try {
      state = const AsyncValue.loading();
      await setting.onTap(context);
      state = AsyncValue.data(await repository.getSettings());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Settings provider
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, List<Setting>>(SettingsNotifier.new);
