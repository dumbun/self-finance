import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/backend/user_db.dart';

final FutureProvider<List> userDataProvider = FutureProvider<List>((ref) async {
  List result = await UserBackEnd.fetchUserData();
  return result;
});
