
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/domain/entities/calibration_session.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';

part 'calibration_lifecycle_service.g.dart';

@riverpod
class CalibrationLifecycleService extends _$CalibrationLifecycleService {
  CalibrationSession? _session;

  @override
  CalibrationSession? build() {
    ref.onDispose(() {
      _session?.kill();
    });
    return null;
  }

  Future<CalibrationSession> startCalibration(
    Program program, {
    bool aggressive = false,
  }) async {
    // Stop any existing calibration session first
    await stopCalibration();

    _session = await CalibrationSession.create(program, aggressive: aggressive);
    state = _session;
    return _session!;
  }

  Future<int> stopCalibration() async {
    final result = await _session?.kill() ?? -1;
    _session = null;
    state = null;
    return result;
  }
}

