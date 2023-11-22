import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';

final hintTextProvider = StateProvider<String>((ref) {
  return searchMobile;
});

final selectedFilterProvider = StateProvider((ref) => "Mobile Number");
