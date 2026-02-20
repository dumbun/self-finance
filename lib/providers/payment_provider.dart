import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/payment_model.dart';

part 'payment_provider.g.dart';

@Riverpod(keepAlive: false)
class PaymentByTrxId extends _$PaymentByTrxId {
  @override
  Stream<List<Payment>> build({required int transactionId}) {
    return BackEnd.watchRequriedPaymentsOfTransaction(
      transactionId: transactionId,
    );
  }
}
