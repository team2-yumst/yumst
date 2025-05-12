// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'managers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voteManagerHash() => r'd6fb4051f1df4c1515075d8f5393303a325bde5a';

/// See also [voteManager].
@ProviderFor(voteManager)
final voteManagerProvider = Provider<VoteManager>.internal(
  voteManager,
  name: r'voteManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$voteManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoteManagerRef = ProviderRef<VoteManager>;
String _$scrapManagerHash() => r'02f6cfa243016b2665334faaab792d90473d7d2d';

/// See also [scrapManager].
@ProviderFor(scrapManager)
final scrapManagerProvider = Provider<ScrapManager>.internal(
  scrapManager,
  name: r'scrapManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scrapManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScrapManagerRef = ProviderRef<ScrapManager>;
String _$managerInitializerHash() =>
    r'70b987e558574f0cee34a7b608054c39a52a40f0';

/// See also [ManagerInitializer].
@ProviderFor(ManagerInitializer)
final managerInitializerProvider =
    AsyncNotifierProvider<ManagerInitializer, bool>.internal(
  ManagerInitializer.new,
  name: r'managerInitializerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$managerInitializerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ManagerInitializer = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
