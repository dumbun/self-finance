import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/widgets/input_text_field.dart';

class UserNameUpdateWidget extends ConsumerStatefulWidget {
  const UserNameUpdateWidget({super.key, required this.userId, required this.userName});

  final int userId;
  final String userName;

  @override
  ConsumerState<UserNameUpdateWidget> createState() => _UserNameUpdateWidgetState();
}

class _UserNameUpdateWidgetState extends ConsumerState<UserNameUpdateWidget> {
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
    return Card(
      child: ListTile(
        onTap: () => showBottomSheet(
          enableDrag: true,
          context: context,
          builder: (context) {
            return Container(
              height: 60.sp,
              padding: EdgeInsets.all(16.sp),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(height: 18.sp),
                      InputTextField(
                        keyboardType: TextInputType.name,
                        hintText: "New User Name",
                        controller: _newUserName,
                      ),
                      SizedBox(height: 18.sp),
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
                                    .read(asyncUserProvider.notifier)
                                    .updateUserName(userId: widget.userId, updateUserName: _newUserName.text);
                                Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.done_rounded),
                            text: "Done",
                          ),
                          SizedBox(width: 12.sp),
                          _buildActionButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: AppColors.getErrorColor,
                            ),
                            text: "Cancel",
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        trailing: const Icon(
          Icons.edit,
          color: AppColors.getPrimaryColor,
        ),
        title: BodyOneDefaultText(
          text: widget.userName,
          bold: true,
        ),
      ),
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
          maxLines: 5,
        ),
      ),
    );
  }
}
