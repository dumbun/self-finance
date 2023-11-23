import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';

final hintTextProvider = StateProvider.autoDispose<String>((ref) => searchMobile);
final selectedFilterProvider = StateProvider.autoDispose<String>((ref) => "Mobile Number");
