import 'package:stpvelox/features/settings/domain/entities/setting.dart';

abstract class SettingsRepository {
  Future<List<Setting>> getSettings();
}
