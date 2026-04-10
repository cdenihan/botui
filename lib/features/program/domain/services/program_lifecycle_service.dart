import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/entities/program_session.dart';

part 'program_lifecycle_service.g.dart';

final _log = Logger('ProgramLifecycleService');

@riverpod
class ProgramLifecycleService extends _$ProgramLifecycleService {
  ProgramSession? _session;

  @override
  ProgramSession? build() {
    ref.onDispose(() {
      _log.warning('[onDispose] Provider disposed — killing session if running');
      _session?.kill();
    });
    return null;
  }

  Future<ProgramSession> startProgram(
    Program program,
    Map<String, String> args, {
    List<String> extraFlags = const [],
  }) async {
    _log.info('[startProgram] Starting: ${program.name} flags=$extraFlags');
    _session =
        await ProgramSession.create(program, args, extraFlags: extraFlags);
    state = _session;
    return _session!;
  }

  Future<int> stopProgram() async {
    _log.warning('[stopProgram] stopProgram() called — killing session');
    final result = await _session?.kill() ?? -1;
    _session = null;
    state = null;
    _log.info('[stopProgram] Session stopped, exit code: $result');
    return result;
  }
}
