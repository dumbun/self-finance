import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/models/items_model.dart';

final itemByIdProvider = StreamProvider.autoDispose.family<Items?, int>((
  ref,
  itemId,
) {
  return BackEnd.watchRequriedItem(itemId: itemId);
});
