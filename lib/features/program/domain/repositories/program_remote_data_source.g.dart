// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_remote_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programRemoteDataSource)
const programRemoteDataSourceProvider = ProgramRemoteDataSourceProvider._();

final class ProgramRemoteDataSourceProvider extends $FunctionalProvider<
    ProgramRemoteDataSource,
    ProgramRemoteDataSource,
    ProgramRemoteDataSource> with $Provider<ProgramRemoteDataSource> {
  const ProgramRemoteDataSourceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'programRemoteDataSourceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$programRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProgramRemoteDataSource> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProgramRemoteDataSource create(Ref ref) {
    return programRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramRemoteDataSource>(value),
    );
  }
}

String _$programRemoteDataSourceHash() =>
    r'deea43a072190f5c9d312071673440e3d1dcf40f';
