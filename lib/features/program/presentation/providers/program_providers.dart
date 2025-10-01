import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/entities/program_session.dart';
import 'package:stpvelox/features/program/domain/repositories/program_remote_data_source.dart';
import 'package:stpvelox/features/program/domain/services/program_lifecycle_service.dart';

part 'program_providers.g.dart';

@riverpod
class ProgramSelection extends _$ProgramSelection {
  @override
  FutureOr<List<Program>> build() {
    return [];
  }

  Future<void> loadPrograms() async {
    state = const AsyncValue.loading();
    try {
      final dataSource = ref.read(programRemoteDataSourceProvider);
      final programs = await dataSource.getPrograms();
      state = AsyncValue.data(programs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}