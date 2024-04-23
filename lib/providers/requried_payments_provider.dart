import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/payment_model.dart';

part 'requried_payments_provider.g.dart';

@riverpod
class AsyncRequriedPayment extends _$AsyncRequriedPayment {
  Future<List<Payment>> _fetchPaymentData({required int transactionId}) async {
    final data = await BackEnd.fetchRequriedPaymentsOfTransaction(transactionId: transactionId);
    return data;
  }

  @override
  FutureOr<List<Payment>> build(transactionId) {
    // Load initial todo list from the remote repository
    return _fetchPaymentData(transactionId: transactionId);
  }

  Future<int> addPayment({required Payment payment}) async {
    int responce = 0;
    // Set the state to loading
    state = const AsyncValue.loading();
    // Add the new todo and reload the todo list from the remote repository
    state = await AsyncValue.guard(() async {
      responce = await BackEnd.addPayment(payment: payment);
      return await _fetchPaymentData(transactionId: transactionId);
    });

    return responce;
  }
}
