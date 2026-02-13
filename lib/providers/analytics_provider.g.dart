// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Analytics)
final analyticsProvider = AnalyticsProvider._();

final class AnalyticsProvider
    extends $NotifierProvider<Analytics, AnalyticsState> {
  AnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsHash();

  @$internal
  @override
  Analytics create() => Analytics();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsState>(value),
    );
  }
}

String _$analyticsHash() => r'77ccf7e8745ef81ad653aa53cf53435ac4f8a2ce';

abstract class _$Analytics extends $Notifier<AnalyticsState> {
  AnalyticsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AnalyticsState, AnalyticsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AnalyticsState, AnalyticsState>,
              AnalyticsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(totalCustomers)
final totalCustomersProvider = TotalCustomersProvider._();

final class TotalCustomersProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  TotalCustomersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalCustomersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalCustomersHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalCustomers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalCustomersHash() => r'2b81a3c6331f32d3876dd62baf0c13aee12ffdc0';

@ProviderFor(activeLoans)
final activeLoansProvider = ActiveLoansProvider._();

final class ActiveLoansProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ActiveLoansProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeLoansProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeLoansHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeLoans(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeLoansHash() => r'd6e4c30f290e26dcff7fb222bea21820937b525d';

@ProviderFor(outstandingAmount)
final outstandingAmountProvider = OutstandingAmountProvider._();

final class OutstandingAmountProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  OutstandingAmountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outstandingAmountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outstandingAmountHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return outstandingAmount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$outstandingAmountHash() => r'23e4b0fa2ceb8967d594c1ff6f782a636ccfc37f';

@ProviderFor(interestEarned)
final interestEarnedProvider = InterestEarnedProvider._();

final class InterestEarnedProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  InterestEarnedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interestEarnedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interestEarnedHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return interestEarned(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$interestEarnedHash() => r'1366dfac12aacf20cfd7b10746dbc96c005d7686';

@ProviderFor(totalDisbursed)
final totalDisbursedProvider = TotalDisbursedProvider._();

final class TotalDisbursedProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  TotalDisbursedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalDisbursedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalDisbursedHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalDisbursed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalDisbursedHash() => r'7fef2694e289770b336ce3285b723df300e98e52';

@ProviderFor(paymentsReceived)
final paymentsReceivedProvider = PaymentsReceivedProvider._();

final class PaymentsReceivedProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  PaymentsReceivedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsReceivedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsReceivedHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return paymentsReceived(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$paymentsReceivedHash() => r'fc7a692601c942c77a62a1ea1883cc2368cdb7ee';
