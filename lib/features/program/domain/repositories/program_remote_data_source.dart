import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/data/datasource/program_remote_data_source_impl.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';

part 'program_remote_data_source.g.dart';

/// Root directory where program folders live on the Pi.
/// Exposed as a constant so the data source and the file watcher stay
/// pointed at the same location.
const String programsDirectoryPath = 'programs';

abstract class ProgramRemoteDataSource {
  Future<List<String>> executeProgram(String arg);

  Future<List<Program>> getPrograms();
}

@riverpod
ProgramRemoteDataSource programRemoteDataSource(Ref ref) {
  return ProgramRemoteDataSourceImpl(programsDirectoryPath: programsDirectoryPath);
}
