abstract class ProgramRemoteDataSource {
  Future<List<String>> executeProgram(String arg);
}

class ProgramRemoteDataSourceImpl implements ProgramRemoteDataSource {
  @override
  Future<List<String>> executeProgram(String arg) async {
    await Future.delayed(Duration(seconds: 3));
    if (arg.isEmpty) {
      throw Exception("No argument provided.");
    }
    return [
      "Program '$arg' started...",
      "Loading data...",
      "Error: Unable to reach server.",
    ];
  }
}