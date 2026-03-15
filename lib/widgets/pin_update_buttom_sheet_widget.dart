import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';

class PinUpdatebuttomSheetWidget extends ConsumerStatefulWidget {
  const PinUpdatebuttomSheetWidget({
    super.key,
    required this.id,
    required this.userPin,
  });
  final int id;
  final String userPin;

  @override
  ConsumerState<PinUpdatebuttomSheetWidget> createState() =>
      _PinUpdatebuttomSheetWidgetState();
}

class _PinUpdatebuttomSheetWidgetState
    extends ConsumerState<PinUpdatebuttomSheetWidget> {
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
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: 420,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 18),
            const BodyOneDefaultText(text: "Please provide new pin"),
            PinInputWidget(pinController: _pin, obscureText: false),
            const SizedBox(height: 18),
            const BodyOneDefaultText(text: "Please conform new pin "),
            PinInputWidget(
              validator: (p0) => _pin.text != _conformPin.text
                  ? "Please provide same pin"
                  : null,
              pinController: _conformPin,
              obscureText: false,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildActionButton(
                  onPressed: () {
                    if (validateAndSave()) {
                      if (widget.userPin != _pin.text &&
                          widget.userPin != _conformPin.text) {
                        update();
                      }
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.done_rounded),
                  text: "Confirm",
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.getErrorColor,
                  ),
                  text: "Cancel",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void update() {
    ref
        .read(userProvider.notifier)
        .changeUserPin(id: widget.id, newPin: _conformPin.text);
  }

  Expanded _buildActionButton({
    required void Function()? onPressed,
    required Widget icon,
    required String text,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        style: const ButtonStyle(elevation: WidgetStatePropertyAll(0)),
        onPressed: onPressed,
        icon: icon,
        label: BodyTwoDefaultText(text: text),
      ),
    );
  }
}
