import 'package:stpvelox/features/program/domain/entities/program.dart';

abstract class ProgramRepository {
  Future<List<String>> startProgram(String arg);

  Future<List<Program>> getPrograms();
}
