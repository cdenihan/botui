import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/domain/service/program_lifecycle_manager.dart';

class StartProgram {
  final ProgramLifecycleManager programLifecycleManager;

  StartProgram({required this.programLifecycleManager});

  void call(Program program) {
    programLifecycleManager.startProgram(program);
  }
}
