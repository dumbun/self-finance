import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/user_history_model.dart';

part 'history_provider.g.dart';

@riverpod
class HistorySearchQuery extends _$HistorySearchQuery {
  @override
  String build() => '';

  void set(String q) => state = q;

  void clear() => state = '';
}

@riverpod
class HistoryNotifier extends _$HistoryNotifier {
  Stream<List<UserHistory>> _fetchHistoryDate() {
    return BackEnd.watchAllUserHistory();
  }

  @override
  Stream<List<UserHistory>> build() {
    final Stream<List<UserHistory>> base = _fetchHistoryDate();
    final String query = ref
        .watch(historySearchQueryProvider)
        .trim()
        .toLowerCase();
    if (query.isEmpty) return base;
    return base.map((List<UserHistory> historys) {
      return historys.where((UserHistory element) {
        final String phoneNumber = element.customerNumber.trim().toLowerCase();
        final String customerName = element.customerName.trim().toLowerCase();
        return customerName.contains(query) || phoneNumber.contains(query);
      }).toList();
    });
  }

  void doSearch({required String userInput}) {
    ref.read(historySearchQueryProvider.notifier).set(userInput);
  }
}
