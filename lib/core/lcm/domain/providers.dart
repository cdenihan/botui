import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stpvelox/core/lcm/data/repositories/method_channel_lcm_repo.dart';
import 'package:stpvelox/core/lcm/data/repositories/mock_lcm_repo.dart';
import 'package:stpvelox/core/lcm/domain/repositories/lcm_repo.dart';
import 'package:stpvelox/core/lcm/domain/services/lcm_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
LcmRepo lcmRepo(Ref ref) {
  LcmRepo repo;
  if (kDebugMode) {
    repo = MockLcmRepo();
  } else {
    repo = MethodChannelLcmRepo();
  }
  ref.onDispose(() {
    repo.dispose();
  });

  return repo;
}

@Riverpod(keepAlive: true)
LcmService lcmService(Ref ref) {
  final repo = ref.watch(lcmRepoProvider);
  final service = LcmService(repo: repo);
  service.startPolling();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
