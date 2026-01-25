import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/transaction_model.dart';

class TransactionsMoreThanSixMothsWidget extends StatelessWidget {
  const TransactionsMoreThanSixMothsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trx>>(
      future: BackEnd.fetchTransactionsOlderThanSixMonths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final transactions = snapshot.data;

        if (transactions == null || transactions.isEmpty) {
          return const Center(child: Text('No transactions found'));
        }

        return SizedBox(
          height: 100.sp,
          child: Expanded(
            child: ListView.separated(
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final trx = transactions[index];

                return ListTile(
                  leading: Icon(
                    trx.transacrtionType == 'CREDIT'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: trx.transacrtionType == 'CREDIT'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    '₹ ${trx.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Date: ${trx.transacrtionDate}\nRemaining: ₹ ${trx.remainingAmount}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
