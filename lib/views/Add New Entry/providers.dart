import 'package:flutter_riverpod/flutter_riverpod.dart';

final pickedCustomerProfileImageStringProvider = StateProvider.autoDispose<String>((ref) {
  // Initial value is an empty string
  return "";
});
final pickedCustomerProofImageStringProvider = StateProvider.autoDispose<String>((ref) {
  // Initial value is an empty string
  return "";
});
final pickedCustomerItemImageStringProvider = StateProvider.autoDispose<String>((ref) {
  // Initial value is an empty string
  return "";
});
