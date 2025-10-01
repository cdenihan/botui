import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/utils/sudo_process.dart';

part 'reboot.g.dart';

@riverpod
RebootDevice rebootDevice(Ref ref) {
  return RebootDevice();
}

class RebootDevice {
  Future<void> call([bool isShutdown = false]) async {
    if (isShutdown) {
      await SudoProcess.run('shutdown', [' -h', 'now']);
    } else {
      await SudoProcess.run('reboot', []);
    }
  }
}
