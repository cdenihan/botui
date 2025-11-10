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

  Future<ProgramSession> startProgram(Program program, Map<String, String> args) async {
    _session = await ProgramSession.create(program, args);
    state = _session;
    return _session!;
  }

  Future<int> stopProgram() async {
    final result = await _session?.kill() ?? -1;
    _session = null;
    state = null;
    return result;
  }
}
