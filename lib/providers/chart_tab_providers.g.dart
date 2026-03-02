// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_tab_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveChartTab)
final activeChartTabProvider = ActiveChartTabProvider._();

final class ActiveChartTabProvider
    extends $NotifierProvider<ActiveChartTab, ChartTab> {
  ActiveChartTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeChartTabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeChartTabHash();

  @$internal
  @override
  ActiveChartTab create() => ActiveChartTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChartTab value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChartTab>(value),
    );
  }
}

String _$activeChartTabHash() => r'80e732d9c9f6488efe81975698b53467f33af7ee';

abstract class _$ActiveChartTab extends $Notifier<ChartTab> {
  ChartTab build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChartTab, ChartTab>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChartTab, ChartTab>,
              ChartTab,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(YearlyChart)
final yearlyChartProvider = YearlyChartProvider._();

final class YearlyChartProvider
    extends $StreamNotifierProvider<YearlyChart, MonthlyChartState> {
  YearlyChartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'yearlyChartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$yearlyChartHash();

  @$internal
  @override
  YearlyChart create() => YearlyChart();
}

String _$yearlyChartHash() => r'5705586b304d02771f73cdcea4c95b72c6bbc7a3';

abstract class _$YearlyChart extends $StreamNotifier<MonthlyChartState> {
  Stream<MonthlyChartState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MonthlyChartState>, MonthlyChartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MonthlyChartState>, MonthlyChartState>,
              AsyncValue<MonthlyChartState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(WeeklyChart)
final weeklyChartProvider = WeeklyChartProvider._();

final class WeeklyChartProvider
    extends $StreamNotifierProvider<WeeklyChart, MonthlyChartState> {
  WeeklyChartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyChartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyChartHash();

  @$internal
  @override
  WeeklyChart create() => WeeklyChart();
}

String _$weeklyChartHash() => r'2d938db45040cb4af361c11e2bc10029d70097f8';

abstract class _$WeeklyChart extends $StreamNotifier<MonthlyChartState> {
  Stream<MonthlyChartState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MonthlyChartState>, MonthlyChartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MonthlyChartState>, MonthlyChartState>,
              AsyncValue<MonthlyChartState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(WeeklyRaw)
final weeklyRawProvider = WeeklyRawProvider._();

final class WeeklyRawProvider
    extends $StreamNotifierProvider<WeeklyRaw, List<Map<String, dynamic>>> {
  WeeklyRawProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyRawProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyRawHash();

  @$internal
  @override
  WeeklyRaw create() => WeeklyRaw();
}

String _$weeklyRawHash() => r'0f8cf958454995406a0d66a62aa80a37b8e0a84b';

abstract class _$WeeklyRaw extends $StreamNotifier<List<Map<String, dynamic>>> {
  Stream<List<Map<String, dynamic>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<Map<String, dynamic>>>,
              List<Map<String, dynamic>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<Map<String, dynamic>>>,
                List<Map<String, dynamic>>
              >,
              AsyncValue<List<Map<String, dynamic>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TodayChart)
final todayChartProvider = TodayChartProvider._();

final class TodayChartProvider
    extends $StreamNotifierProvider<TodayChart, TodayState> {
  TodayChartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayChartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayChartHash();

  @$internal
  @override
  TodayChart create() => TodayChart();
}

String _$todayChartHash() => r'2f7948288f1d4cab7b363b2a1004989b4593a124';

abstract class _$TodayChart extends $StreamNotifier<TodayState> {
  Stream<TodayState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TodayState>, TodayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TodayState>, TodayState>,
              AsyncValue<TodayState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
