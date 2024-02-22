import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';

final currencyProvider = FutureProvider<String>((ref) async {
  return ref.watch(asyncUserProvider).when(
        data: (List<User> data) {
          return data.first.userCurrency;
        },
        error: (error, stackTrace) => "",
        loading: () => "",
      );
});
