import 'package:stpvelox/domain/entities/program.dart';
import 'package:stpvelox/domain/service/program_lifecycle_manager.dart';

class StartProgram {
  final ProgramLifecycleManager programLifecycleManager;

  StartProgram({required this.programLifecycleManager});

  ProgramSession call(Program program) {
    return programLifecycleManager.startProgram(program);
  }
}
