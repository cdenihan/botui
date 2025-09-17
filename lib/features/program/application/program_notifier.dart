import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/services/program_lifecycle_manager.dart';
import 'package:stpvelox/features/program/domain/usecases/start_program.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';
import 'program_providers.dart';

class ProgramNotifier extends StateNotifier<ProgramSession?> {
  final StartProgram startProgram;
  final RebootDevice rebootDevice;

  ProgramNotifier({required this.startProgram, required this.rebootDevice})
      : super(null);

  void start(Program program, Map<String, String> args) {
    final session = startProgram(program, args);
    state = session;
  }

  Future<void> stop() async {
    if (state != null) {
      await state!.kill();
      state = null;
    }
  }

  void reboot() {
    rebootDevice();
  }
}

final programProvider = StateNotifierProvider<ProgramNotifier, ProgramSession?>(
      (ref) {
    final startProgram = ref.watch(startProgramProvider);
    final rebootDevice = ref.watch(rebootDeviceProvider);
    return ProgramNotifier(startProgram: startProgram, rebootDevice: rebootDevice);
  },
);
