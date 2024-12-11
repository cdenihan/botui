import 'package:stpvelox/domain/repositories/program_repository.dart';

class StartProgram {
  final ProgramRepository repository;

  StartProgram({required this.repository});

  Future<List<String>> execute(String arg) async {
    return await repository.startProgram(arg);
  }
}