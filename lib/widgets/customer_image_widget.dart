import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/customer_model.dart';
import 'package:self_finance/providers/customer_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class CustomerImageWidget extends ConsumerWidget {
  const CustomerImageWidget({
    super.key,
    required this.customerId,
    required this.size,
  });
  final int customerId;
  final double size;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(customerProvider(customerId))
        .when(
          data: (Customer? data) {
            if (data == null) {
              return const BodyTwoDefaultText(
                text: Constant.errorUpdatingContactMessage,
              );
            }
            return CircularImageWidget(
              customeSize: size,
              imageData: data.photo,
              titile: data.name,
            );
          },
          loading: () => DefaultUserImage(height: size),
          error: (_, _) => DefaultUserImage(height: size, width: size),
        );
  }
}
