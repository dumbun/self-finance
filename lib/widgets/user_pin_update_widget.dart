import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';

class UserPinUpdateWidget extends ConsumerWidget {
  const UserPinUpdateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController pin = TextEditingController();
    TextEditingController conformPin = TextEditingController();
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
          data: (data) {
            return Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 14.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const BodyOneDefaultText(
                      text: "Change App Pin",
                      bold: true,
                    ),
                    IconButton(
                      onPressed: () {
                        showBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              padding: EdgeInsets.all(16.sp),
                              width: double.infinity,
                              height: 80.sp,
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 18.sp),
                                    const BodyOneDefaultText(text: "Please provide new pin "),
                                    PinInputWidget(
                                      pinController: pin,
                                      obscureText: false,
                                    ),
                                    SizedBox(height: 18.sp),
                                    const BodyOneDefaultText(text: "Please conform new pin "),
                                    PinInputWidget(
                                      validator: (p0) => pin.text != conformPin.text ? "Please provide same pin" : null,
                                      pinController: conformPin,
                                      obscureText: false,
                                    ),
                                    SizedBox(height: 18.sp),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
                                            onPressed: () {
                                              if (validateAndSave()) {
                                                ref.read(asyncUserProvider.notifier).updateUserPin(
                                                    userId: data.first.id!, updateUserPin: conformPin.text);
                                                Navigator.pop(context);
                                              }
                                            },
                                            label: const BodyTwoDefaultText(
                                              text: "Confirm",
                                            ),
                                            icon: const Icon(Icons.done_rounded),
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
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.password,
                        color: AppColors.getPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, stackTrace) => const Center(
            child: BodyTwoDefaultText(text: "Con't change pin please try again"),
          ),
        );
  }
}
