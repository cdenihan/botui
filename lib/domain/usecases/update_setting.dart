import 'package:stpvelox/domain/repositories/settings_repository.dart';

class UpdateSetting {
  final SettingsRepository repository;

  UpdateSetting({required this.repository});

  Future<void> execute(String label) async {
    await repository.updateSetting(label);
  }
}