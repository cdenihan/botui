import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/entities/program_session.dart';

part 'program_lifecycle_service.g.dart';


@riverpod
class ProgramLifecycleService extends _$ProgramLifecycleService {
  ProgramSession? _session;

  @override
  ProgramSession? build() {
    ref.onDispose(() {
      _session?.kill();
    });
    return null;
  }

  ProgramSession startProgram(Program program, Map<String, String> args) {
    _session = ProgramSession(program, args);
    return _session!;
  }

  Future<int> stopProgram() => _session?.kill() ?? Future.value(-1);
}
