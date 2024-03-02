import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';

class PinUpdatebuttomSheetWidget extends ConsumerStatefulWidget {
  const PinUpdatebuttomSheetWidget({super.key, required this.id, required this.userPin});
  final int id;
  final String userPin;

  @override
  ConsumerState<PinUpdatebuttomSheetWidget> createState() => _PinUpdatebuttomSheetWidgetState();
}

class _PinUpdatebuttomSheetWidgetState extends ConsumerState<PinUpdatebuttomSheetWidget> {
  final TextEditingController _pin = TextEditingController();
  final TextEditingController _conformPin = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _pin.dispose();
    _conformPin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      width: double.infinity,
      height: 80.sp,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 18.sp),
            const BodyOneDefaultText(text: "Please provide new pin"),
            PinInputWidget(
              pinController: _pin,
              obscureText: false,
            ),
            SizedBox(height: 18.sp),
            const BodyOneDefaultText(text: "Please conform new pin "),
            PinInputWidget(
              validator: (p0) => _pin.text != _conformPin.text ? "Please provide same pin" : null,
              pinController: _conformPin,
              obscureText: false,
            ),
            SizedBox(height: 18.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildActionButton(
                  onPressed: () {
                    if (validateAndSave()) {
                      if (widget.userPin != _pin.text && widget.userPin != _conformPin.text) {
                        update();
                      }
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.done_rounded),
                  text: "Confirm",
                ),
                SizedBox(width: 12.sp),
                _buildActionButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.getErrorColor,
                  ),
                  text: "Cancel",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  update() {
    ref.read(asyncUserProvider.notifier).updateUserPin(
          userId: widget.id,
          updateUserPin: _conformPin.text,
        );
  }

  Expanded _buildActionButton({required void Function()? onPressed, required Widget icon, required String text}) {
    return Expanded(
      child: ElevatedButton.icon(
        style: const ButtonStyle(elevation: MaterialStatePropertyAll(0)),
        onPressed: onPressed,
        icon: icon,
        label: BodyTwoDefaultText(
          text: text,
        ),
      ),
    );
  }
}
