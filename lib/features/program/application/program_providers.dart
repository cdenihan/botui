import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stpvelox/features/program/data/datasource/program_remote_data_source.dart';
import 'package:stpvelox/features/program/data/repositories/program_repository_impl.dart';
import 'package:stpvelox/features/program/domain/repositories/program_repository.dart';
import 'package:stpvelox/features/program/domain/services/program_lifecycle_manager.dart';
import 'package:stpvelox/features/program/domain/usecases/start_program.dart';
import 'package:stpvelox/features/program/usecases/get_programs.dart';
import 'package:stpvelox/features/settings/domain/usecases/reboot.dart';

// Data source provider
final programRemoteDataSourceProvider = Provider<ProgramRemoteDataSource>((ref) {
  return ProgramRemoteDataSourceImpl(programsDirectoryPath: 'programs');
});

// Repository provider
final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  final remoteDataSource = ref.watch(programRemoteDataSourceProvider);
  return ProgramRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use case provider
final getProgramsProvider = Provider<GetPrograms>((ref) {
  final repository = ref.watch(programRepositoryProvider);
  return GetPrograms(repository: repository);
});

// Program lifecycle manager provider
final programLifecycleManagerProvider = Provider<ProgramLifecycleManager>((ref) {
  return ProgramLifecycleManager();
});

// Start program use case provider
final startProgramProvider = Provider<StartProgram>((ref) {
  final lifecycleManager = ref.watch(programLifecycleManagerProvider);
  return StartProgram(programLifecycleManager: lifecycleManager);
});

// Reboot device provider
final rebootDeviceProvider = Provider<RebootDevice>((ref) {
  return RebootDevice();
});
