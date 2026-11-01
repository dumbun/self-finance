// =============================================================================
// DRILL-DOWN
// Manual FutureProvider.family — sealed classes don't generate cleanly with
// @riverpod, and a manual provider is identical at runtime.
// =============================================================================

sealed class DrillTarget {
  const DrillTarget();
}

class DrillMonth extends DrillTarget {
  const DrillMonth({required this.month, required this.year});
  final int month;
  final int year;

  @override
  bool operator ==(Object other) =>
      other is DrillMonth && other.month == month && other.year == year;
  @override
  int get hashCode => Object.hash(runtimeType, month, year);
}

class DrillDay extends DrillTarget {
  const DrillDay({required this.txnDate, required this.payDate});
  final String txnDate; // dd/MM/yyyy  ← Transaction_Date format
  final String payDate; // yyyy-MM-dd  ← Payment_Date format

  @override
  bool operator ==(Object other) =>
      other is DrillDay && other.txnDate == txnDate && other.payDate == payDate;
  @override
  int get hashCode => Object.hash(runtimeType, txnDate, payDate);
}

class DrillItem {
  const DrillItem({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    required this.kind,
  });

  factory DrillItem.fromMap(Map<String, dynamic> m) => DrillItem(
    id: m['id']?.toString() ?? '',
    amount: (m['amount'] is num)
        ? (m['amount'] as num).toDouble()
        : double.tryParse(m['amount']?.toString() ?? '0.0') ?? 0.0,
    date: m['date']?.toString() ?? '',
    type: m['type']?.toString() ?? '',
    kind: m['kind']?.toString() ?? '',
  );

  final String id;
  final double amount;
  final String date;
  final String type;
  final String kind;

  bool get isReceived => kind == 'received';
}

// =============================================================================
// TODAY  —  different shape, needs its own state class
// =============================================================================

class TodayState {
  const TodayState({
    required this.disbursed,
    required this.disbursedCount,
    required this.received,
    required this.receivedCount,
    required this.net,
  });

  factory TodayState.empty() => const TodayState(
    disbursed: 0,
    disbursedCount: 0,
    received: 0,
    receivedCount: 0,
    net: 0,
  );

  factory TodayState.fromMap(Map<String, dynamic> m) => TodayState(
    disbursed: (m['disbursed'] as num?)?.toDouble() ?? 0.0,
    disbursedCount: (m['disbursedCount'] as num?)?.toInt() ?? 0,
    received: (m['received'] as num?)?.toDouble() ?? 0.0,
    receivedCount: (m['receivedCount'] as num?)?.toInt() ?? 0,
    net: (m['net'] as num?)?.toDouble() ?? 0.0,
  );

  final double disbursed;
  final int disbursedCount;
  final double received;
  final int receivedCount;
  final double net;
}

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
      month: map['month']?.toString() ?? '',
      disbursed: (map['disbursed'] as num?)?.toDouble() ?? 0.0,
      received: (map['received'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static List<ChartData> toList(List<Map<String, dynamic>> maps) {
    return maps.map(ChartData.fromMap).toList();
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
