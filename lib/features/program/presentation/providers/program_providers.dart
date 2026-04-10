import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/features/program/domain/entities/program.dart';
import 'package:stpvelox/features/program/domain/repositories/program_remote_data_source.dart';

part 'program_providers.g.dart';

/// How long to wait after the last filesystem event before reloading.
/// A `raccoon sync` writes dozens of files in rapid succession; debouncing
/// collapses the burst into a single reload.
const Duration _watcherDebounce = Duration(milliseconds: 400);

@riverpod
class ProgramSelection extends _$ProgramSelection {
  StreamSubscription<FileSystemEvent>? _watcherSub;
  Timer? _debounceTimer;

  @override
  FutureOr<List<Program>> build() {
    _startWatching();
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _watcherSub?.cancel();
    });
    return [];
  }

  /// Reload the programs list, showing the loading spinner. Use this for the
  /// initial load from a screen `useEffect`; subsequent refreshes triggered by
  /// the file watcher use [_refreshSilently] so the grid does not flicker.
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

  /// Reload without flipping to the loading state so the UI does not flash.
  /// On error we keep the previous data rather than clobbering it, because a
  /// mid-sync snapshot can transiently fail to parse and we do not want that
  /// to yank the list out from under the user.
  Future<void> _refreshSilently() async {
    try {
      final dataSource = ref.read(programRemoteDataSourceProvider);
      final programs = await dataSource.getPrograms();
      state = AsyncValue.data(programs);
    } catch (error, stackTrace) {
      developer.log(
        'Silent refresh failed, keeping previous data',
        name: 'ProgramSelection',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start a recursive watcher on the programs directory. Any change inside
  /// any project (new file, deleted file, `.raccoon/sync_state.json` rewrite)
  /// schedules a debounced reload. If the directory does not exist or the
  /// platform cannot watch it, this is a silent no-op — the list still works,
  /// it just will not auto-refresh.
  void _startWatching() {
    final dir = Directory(programsDirectoryPath);
    if (!dir.existsSync()) {
      // Data source creates it on first getPrograms(); nothing to watch yet.
      return;
    }
    try {
      _watcherSub = dir
          .watch(recursive: true, events: FileSystemEvent.all)
          .listen(
        _onFsEvent,
        onError: (Object e, StackTrace st) {
          developer.log(
            'Programs watcher error',
            name: 'ProgramSelection',
            error: e,
            stackTrace: st,
          );
        },
      );
    } on FileSystemException catch (e) {
      developer.log(
        'Could not start programs watcher (falling back to manual refresh only)',
        name: 'ProgramSelection',
        error: e,
      );
    }
  }

  void _onFsEvent(FileSystemEvent event) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_watcherDebounce, _refreshSilently);
  }
}
