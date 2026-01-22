import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/payment_model.dart';

part 'requried_payments_provider.g.dart';

@riverpod
class AsyncRequriedPayment extends _$AsyncRequriedPayment {
  Future<List<Payment>> _fetchPaymentData({required int transactionId}) async {
    final data = await BackEnd.fetchRequriedPaymentsOfTransaction(
      transactionId: transactionId,
    );
    return data;
  }

  @override
  FutureOr<List<Payment>> build(transactionId) {
    // Load initial todo list from the remote repository
    return _fetchPaymentData(transactionId: transactionId);
  }

  Future<int> addPayment({required double amountpaid}) async {
    int responce = 0;
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      final Payment payment = Payment(
        transactionId: transactionId,
        paymentDate: Utility.presentDate().toIso8601String(),
        amountpaid: amountpaid,
        type: 'cash',
        createdDate: Utility.presentDate().toIso8601String(),
      );
      responce = await BackEnd.addPayment(payment: payment);
      return _fetchPaymentData(transactionId: transactionId);
    });

    return responce;
  }
}
