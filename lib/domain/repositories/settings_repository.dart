import 'package:stpvelox/domain/entities/setting.dart';

abstract class SettingsRepository {
  Future<List<Setting>> getSettings();
  Future<void> updateSetting(String label);
}
