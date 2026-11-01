import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_finance/models/chart_model.dart';
import 'package:self_finance/providers/chart_tab_providers.dart';
import 'package:self_finance/widgets/drill_sheet_widget.dart';

void main() {
  group('DrillItem and Chart Model Sound Typing Tests', () {
    test('DrillItem.fromMap correctly handles String UUIDs and numeric amounts', () {
      final mapWithUuid = {
        'id': '01a17228-9012-73e1-a381-dd2c6e4d6b35',
        'amount': 5000.50,
        'date': '25-10-2026',
        'type': 'Active',
        'kind': 'disbursed',
      };

      final item = DrillItem.fromMap(mapWithUuid);
      expect(item.id, '01a17228-9012-73e1-a381-dd2c6e4d6b35');
      expect(item.amount, 5000.50);
      expect(item.date, '25-10-2026');
      expect(item.isReceived, isFalse);
    });

    test('DrillItem.fromMap safely handles legacy int IDs and int amounts', () {
      final mapWithInt = {
        'id': 1234,
        'amount': 2000,
        'date': '25-10-2026',
        'type': 'Paid',
        'kind': 'received',
      };

      final item = DrillItem.fromMap(mapWithInt);
      expect(item.id, '1234');
      expect(item.amount, 2000.0);
      expect(item.date, '25-10-2026');
      expect(item.isReceived, isTrue);
    });

    test('TodayState.fromMap and ChartData.fromMap safely parse dynamic types', () {
      final todayMap = {
        'disbursed': 1000,
        'disbursedCount': 2,
        'received': 500,
        'receivedCount': 1,
        'net': 500,
      };
      final today = TodayState.fromMap(todayMap);
      expect(today.disbursed, 1000.0);
      expect(today.disbursedCount, 2);
      expect(today.received, 500.0);
      expect(today.receivedCount, 1);
      expect(today.net, 500.0);

      final chartMap = {
        'month': 'Oct',
        'disbursed': 3500,
        'received': 1200,
      };
      final chart = ChartData.fromMap(chartMap);
      expect(chart.month, 'Oct');
      expect(chart.disbursed, 3500.0);
      expect(chart.received, 1200.0);
    });
  });

  group('DrillSheet Widget Tests', () {
    testWidgets('renders DrillSheet correctly with String UUID items without error', (tester) async {
      const target = DrillMonth(month: 10, year: 2026);
      const items = [
        DrillItem(
          id: '01a17228-9012-73e1-a381-dd2c6e4d6b35',
          amount: 5000,
          date: '25-10-2026',
          type: 'Active',
          kind: 'disbursed',
        ),
        DrillItem(
          id: '01a17228-9012-73e1-a381-dd2c6e4d6b36',
          amount: 1500,
          date: '25-10-2026',
          type: 'Paid',
          kind: 'received',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            drillDownProvider(target).overrideWith((ref) => Future.value(items)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DrillSheet(
                target: target,
                title: 'October 2026',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Transactions · October 2026'), findsOneWidget);
      expect(find.text('Loan Disbursed'), findsOneWidget);
      expect(find.text('Payment Received'), findsOneWidget);
      expect(find.textContaining('01a17228'), findsNWidgets(2));
    });
  });
}
