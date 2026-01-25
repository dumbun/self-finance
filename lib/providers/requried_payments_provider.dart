import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/models/payment_model.dart';
import 'package:self_finance/providers/payments_provider.dart';

part 'requried_payments_provider.g.dart';

@riverpod
List<Payment> requriedPayments(Ref ref, int transactionId) {
  return ref
      .watch(asyncPaymentProvider(transactionId))
      .when(
        data: (List<Payment> data) => data,
        error: (Object error, StackTrace stackTrace) => [
          Payment(
            transactionId: transactionId,
            paymentDate: 'error',
            amountpaid: 0000,
            type: 'error',
            createdDate: 'error',
          ),
        ],
        loading: () => [
          Payment(
            transactionId: transactionId,
            paymentDate: 'loading',
            amountpaid: 402,
            type: 'loading',
            createdDate: 'loading',
          ),
        ],
      );
}
