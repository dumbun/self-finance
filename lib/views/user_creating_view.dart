import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class UserCreationView extends StatefulWidget {
  const UserCreationView({required this.pin, super.key});
  final String pin;

  @override
  State<UserCreationView> createState() => _UserCreationViewState();
}

class _UserCreationViewState extends State<UserCreationView> {
  String userProfilePicString = "";
  final double height = 55.sp;
  final double width = 55.sp;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameInput = TextEditingController();
  Widget? pickedItemImage;

  @override
  void dispose() {
    nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => createUser(
          User(id: 1, userName: nameInput.text, userPin: widget.pin, profilePicture: userProfilePicString),
        ),
        backgroundColor: getPrimaryColor,
        enableFeedback: true,
        autofocus: true,
        isExtended: true,
        mini: false,
        shape: const CircleBorder(),
        tooltip: "Next",
        splashColor: getPrimaryColor,
        focusElevation: 40.sp,
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: getBackgroundColor,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.all(18.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildImagePickWidget(),
                SizedBox(height: 24.sp),
                InputTextField(
                  validator: (String? value) {
                    if (value != null) {
                      if (value == "" && value.isEmpty) {
                        return "Please enter your name";
                      }
                    } else if (value == null) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  controller: nameInput,
                  hintText: pleaseEnterTheName,
                  keyboardType: TextInputType.name,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// navigates to the main Dashboard view
  void navigateToDashboard() {
    Routes.navigateToDashboard(context: context);
    snackBarWidget(context: context, message: "success : user created successfully ");
  }

  /// to show errors if avilable
  void showAlerts() {
    AlertDilogs.alertDialogWithOneAction(context, "error", 'Please try after some time');
  }

  /// to create user [createUser]
  void createUser(User user) async {
    if (validateAndSave()) {
      try {
        final result = await UserBackEnd.createNewUser(user);
        result ? navigateToDashboard() : showAlerts();
      } catch (e) {
        showAlerts();
      }
    }
  }

  // form validation
  bool validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildImagePickWidget() {
    return GestureDetector(
      onTap: () {
        pickImageFromGallery().then(
          (String value) {
            if (value != "" && value.isNotEmpty) {
              setState(
                () {
                  userProfilePicString = value;
                  pickedItemImage = Utility.imageFromBase64String(
                    value,
                    height: height,
                    width: width,
                  );
                },
              );
            }
          },
        );
      },
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: pickedItemImage ??
                    DefaultUserImage(
                      height: height,
                      width: width,
                    ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SvgPicture.asset(
                "assets/icon/edit_icon.svg",
                height: 30.sp,
                width: 30.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
