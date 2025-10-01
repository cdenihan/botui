import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/data/datasource/program_remote_data_source_impl.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';

part 'program_remote_data_source.g.dart';

abstract class ProgramRemoteDataSource {
  Future<List<String>> executeProgram(String arg);

  Future<List<Program>> getPrograms();
}

@riverpod
ProgramRemoteDataSource programRemoteDataSource(Ref ref) {
  return ProgramRemoteDataSourceImpl(programsDirectoryPath: 'programs');
}
