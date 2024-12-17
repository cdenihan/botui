import 'package:stpvelox/core/utils/sudo_process.dart';

class RebootDevice {
  Future<void> call() async {
    await SudoProcess.run('reboot', []);
  }
}