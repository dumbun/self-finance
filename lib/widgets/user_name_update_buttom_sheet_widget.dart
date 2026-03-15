import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class UserNameUpdateButtomSheetWidget extends ConsumerStatefulWidget {
  const UserNameUpdateButtomSheetWidget({
    super.key,
    required this.userId,
    required this.userName,
  });

  final int userId;
  final String userName;

  @override
  ConsumerState<UserNameUpdateButtomSheetWidget> createState() =>
      _UserNameUpdateButtomSheetWidgetState();
}

class _UserNameUpdateButtomSheetWidgetState
    extends ConsumerState<UserNameUpdateButtomSheetWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newUserName = TextEditingController();
  bool validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _newUserName.text = widget.userName;
    super.initState();
  }

  @override
  void dispose() {
    _newUserName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 18),
              InputTextField(
                keyboardType: TextInputType.name,
                hintText: "New User Name",
                controller: _newUserName,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildActionButton(
                    onPressed: () {
                      if (_newUserName.text == widget.userName) {
                        Navigator.pop(context);
                      } else if (validateAndSave()) {
                        ref
                            .read(userProvider.notifier)
                            .changeUserName(
                              id: widget.userId,
                              newUserName: _newUserName.text,
                            );
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.done_rounded),
                    text: "Done",
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
      ),
    );
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
        label: BodyTwoDefaultText(text: text, maxLines: 5),
      ),
    );
  }
}
