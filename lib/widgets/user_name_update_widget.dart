import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class UserNameUpdateWidget extends ConsumerWidget {
  const UserNameUpdateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool validateAndSave() {
      final FormState? form = formKey.currentState;
      if (form!.validate()) {
        return true;
      } else {
        return false;
      }
    }

    return ref.watch(asyncUserProvider).when(
          data: (List<User> data) {
            final TextEditingController newUserName = TextEditingController(text: data.first.userName);
            return Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 14.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BodyOneDefaultText(
                      text: data.first.userName,
                      bold: true,
                    ),
                    IconButton(
                      onPressed: () {
                        showBottomSheet(
                          enableDrag: true,
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 60.sp,
                              padding: EdgeInsets.all(16.sp),
                              child: Form(
                                key: formKey,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(height: 18.sp),
                                      InputTextField(
                                        keyboardType: TextInputType.name,
                                        hintText: "New User Name",
                                        controller: newUserName,
                                      ),
                                      SizedBox(height: 18.sp),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
                                              onPressed: () {
                                                if (newUserName.text == data.first.userName) {
                                                  Navigator.pop(context);
                                                } else if (validateAndSave()) {
                                                  ref.read(asyncUserProvider.notifier).updateUserName(
                                                      userId: data.first.id!, updateUserName: newUserName.text);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              icon: const Icon(Icons.done_rounded),
                                              label: const BodyTwoDefaultText(
                                                text: "Done",
                                                maxLines: 5,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12.sp),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
                                              onPressed: () => Navigator.pop(context),
                                              icon: const Icon(
                                                Icons.cancel_rounded,
                                                color: AppColors.getErrorColor,
                                              ),
                                              label: const BodyTwoDefaultText(text: "Cancel"),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.getPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (Object error, StackTrace stackTrace) => const Center(
            child: BodyOneDefaultText(
              text: "Error fetching user name, please restart the app",
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
  }
}
