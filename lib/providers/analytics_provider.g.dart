// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live dashboard analytics driven by drift streams.
/// No manual refresh needed - this updates automatically on DB changes.

@ProviderFor(analytics)
final analyticsProvider = AnalyticsProvider._();

/// Live dashboard analytics driven by drift streams.
/// No manual refresh needed - this updates automatically on DB changes.

final class AnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalyticsState>,
          AnalyticsState,
          Stream<AnalyticsState>
        >
    with $FutureModifier<AnalyticsState>, $StreamProvider<AnalyticsState> {
  /// Live dashboard analytics driven by drift streams.
  /// No manual refresh needed - this updates automatically on DB changes.
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
  $StreamProviderElement<AnalyticsState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AnalyticsState> create(Ref ref) {
    return analytics(ref);
  }
}

String _$analyticsHash() => r'f7fb86b2adde9db1bb24f85d963d4e11faf0568e';

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

String _$totalCustomersHash() => r'd2f1b541fea06d4374a037ea06634bfbc92fca84';

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

String _$activeLoansHash() => r'ddc87a1edba0e6e8aa1b162ba9e755e6816475c2';

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

String _$outstandingAmountHash() => r'8c9e5c47bbafda1308066b9c209469b34210c3a9';

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

String _$interestEarnedHash() => r'0fdb59ba6a08f10c366f5752e8e47920d4c26c36';

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

String _$totalDisbursedHash() => r'a8f799b2da831b289ecd9af2bc5530ebeccde06c';

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

String _$paymentsReceivedHash() => r'7ba265d43d30b48f3b75e6dc2422824479d4ecf0';
