class ChartData {
  final String month;
  final double disbursed;
  final double received;

  ChartData({
    required this.month,
    required this.disbursed,
    required this.received,
  });

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      month: map['month'] as String,
      disbursed: (map['disbursed'] as num).toDouble(),
      received: (map['received'] as num).toDouble(),
    );
  }

  static List<ChartData> toList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => ChartData.fromMap(map)).toList();
  }
}

class MonthlyChartState {
  final List<ChartData> data;
  final double maxValue;
  final double totalDisbursed;
  final double totalReceived;

  MonthlyChartState({
    required this.data,
    required this.maxValue,
    required this.totalDisbursed,
    required this.totalReceived,
  });

  factory MonthlyChartState.empty() {
    return MonthlyChartState(
      data: [],
      maxValue: 0,
      totalDisbursed: 0,
      totalReceived: 0,
    );
  }
}
