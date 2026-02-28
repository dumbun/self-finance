// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'date_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DateNotifier)
final dateProvider = DateNotifierProvider._();

final class DateNotifierProvider
    extends $NotifierProvider<DateNotifier, DateTime?> {
  DateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dateNotifierHash();

  @$internal
  @override
  DateNotifier create() => DateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$dateNotifierHash() => r'5dfbe5e7c608d26e2e81b8286a8af692ec370436';

abstract class _$DateNotifier extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
