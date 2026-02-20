// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MonthlyChart)
final monthlyChartProvider = MonthlyChartProvider._();

final class MonthlyChartProvider
    extends $StreamNotifierProvider<MonthlyChart, MonthlyChartState> {
  MonthlyChartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyChartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyChartHash();

  @$internal
  @override
  MonthlyChart create() => MonthlyChart();
}

String _$monthlyChartHash() => r'db36d56acd33c331a8660862afc9fce5ac823c84';

abstract class _$MonthlyChart extends $StreamNotifier<MonthlyChartState> {
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
