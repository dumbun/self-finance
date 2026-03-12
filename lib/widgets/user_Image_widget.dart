import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';

class UserImageWIdget extends ConsumerWidget {
  const UserImageWIdget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(userProvider)
        .when(
          data: (User? data) => data != null
              ? CircularImageWidget(
                  imageData: data.profilePicture,
                  titile: data.userName,
                )
              : const DefaultUserImage(),
          error: (_, _) =>
              const BodyTwoDefaultText(text: Constant.errorUserFetch),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        );
  }
}
