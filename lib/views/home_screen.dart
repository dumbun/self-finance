import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/models/transaction_model.dart';
import 'package:self_finance/providers/customers_provider.dart';
import 'package:self_finance/providers/transactions_history_provider.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/center_title_text_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(20.0.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderWidget(),
          SizedBox(height: 20.sp),
          SizedBox(
            width: 20.sp,
          ),

          //// testing
          ElevatedButton(
              onPressed: () async {
                const Customer customer = Customer(
                  address: "ieeja",
                  customerName: "vamshi",
                  guardianName: "Krishna",
                  mobileNumber: 912813221,
                );
                final response = await ref
                    .read(asyncCustomersProvider.notifier)
                    .addCustomer(customer: customer);
                print(response);
                if (response == 0) {
                  print("error");
                }
                if (response != 0) {
                  TransactionsHistory transaction = TransactionsHistory(
                    custId: response,
                    itemName: "gold",
                    photoItem: "test",
                    photoProof: "test",
                    rateOfInterest: 2.0,
                    takenAmount: 20000,
                    takenDate: DateTime.now().toString(),
                    transactionType: 1,
                  );

                  final tresponse = await ref
                      .read(asyncTransactionsHistoryProvider.notifier)
                      .addTrasaction(transaction: transaction);
                  print("tresponse = $tresponse");
                }
              },
              child: Text("help")),

          Consumer(
            builder: (context, ref, child) {
              return ref.watch(asyncCustomersProvider).when(
                  data: (c) {
                    return Text(c.length.toString());
                  },
                  error: (_, __) {
                    return const Text("data");
                  },
                  loading: () => Text("l"));
            },
          )
        ],
      ),
    );
  }

  Consumer _buildHeaderWidget() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(asyncUserProvider).when(
              data: (data) {
                return CenterTitleTextWidget(
                  user: data[0],
                  showUserProfile: true,
                );
              },
              error: (error, stackTrace) => const Text("Welcome"),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}
