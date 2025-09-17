import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/program/application/program_providers.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/usecases/get_programs.dart';

class ProgramSelectionNotifier extends StateNotifier<AsyncValue<List<Program>>> {
  final GetPrograms getPrograms;

  ProgramSelectionNotifier({required this.getPrograms})
      : super(const AsyncValue.loading());

  Future<void> loadPrograms() async {
    state = const AsyncValue.loading();
    try {
      final programs = await getPrograms();
      state = AsyncValue.data(programs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final programSelectionProvider = StateNotifierProvider<
    ProgramSelectionNotifier, AsyncValue<List<Program>>>((ref) {
  final getPrograms = ref.watch(getProgramsProvider);
  return ProgramSelectionNotifier(getPrograms: getPrograms);
});
