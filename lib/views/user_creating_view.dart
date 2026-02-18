import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_database.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/utility/image_saving_utility.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/currency_type_input_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/input_text_field.dart';
import 'package:self_finance/widgets/snack_bar_widget.dart';

class UserCreatingView extends StatefulWidget {
  const UserCreatingView({super.key, required this.pin});
  final String pin;
  @override
  State<UserCreatingView> createState() => _UserCreatingViewState();
}

class _UserCreatingViewState extends State<UserCreatingView> {
  String userProfilePicString = "";
  final double height = 55.sp;
  final double width = 55.sp;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameInput = TextEditingController();
  final TextEditingController _currencyInput = TextEditingController();

  @override
  void dispose() {
    _nameInput.dispose();
    _currencyInput.dispose();
    super.dispose();
  }

  /// navigates to the main Dashboard view
  void _navigateToDashboard() {
    Routes.navigateToDashboard(context: context);
    SnackBarWidget.snackBarWidget(
      context: context,
      message: "success : user created successfully ",
    );
  }

  /// to show errors if avilable
  void _showAlerts() {
    AlertDilogs.alertDialogWithOneAction(
      context,
      "error",
      'Please try after some time',
    );
  }

  /// to create user [createUser]
  void _createUser(User user) async {
    if (_validateAndSave()) {
      try {
        final bool result = await UserBackEnd.createNewUser(user);
        result ? _navigateToDashboard() : _showAlerts();
      } catch (e) {
        _showAlerts();
      }
    }
  }

  // form validation
  bool _validateAndSave() {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  XFile? pickedImageFile;

  Widget _buildImagePickWidget() {
    return GestureDetector(
      onTap: () async {
        final XFile? imageFile = await ImageSavingUtility.doPickImage(
          camera: false,
        );
        if (imageFile != null) {
          setState(() {
            pickedImageFile = imageFile;
          });
        }
      },
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100.sp),
                child: pickedImageFile == null
                    ? DefaultUserImage(height: height, width: width)
                    : Image.file(
                        File(pickedImageFile!.path),
                        height: height,
                        width: width,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 32.sp,
                width: 32.sp,
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppColors.contentColorBlue,
                  borderRadius: BorderRadius.circular(32.sp),
                ),
                child: Icon(
                  Icons.edit,
                  size: 22.sp,
                  color: AppColors.contentColorWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(18.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildImagePickWidget(),
                    SizedBox(height: 24.sp),
                    InputTextField(
                      controller: _nameInput,
                      hintText: Constant.pleaseEnterTheName,
                      keyboardType: TextInputType.name,
                    ),
                    SizedBox(height: 24.sp),
                    CurrencyTypeInputWidget(controller: _currencyInput),
                    // const GoogleSignInButtonWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String imagePath = await ImageSavingUtility.saveImage(
            location: 'user',
            image: pickedImageFile,
          );
          _createUser(
            User(
              id: 1,
              userName: _nameInput.text,
              userPin: widget.pin,
              userCurrency: _currencyInput.text,
              profilePicture: imagePath,
            ),
          );
        },
        backgroundColor: AppColors.getPrimaryColor,
        enableFeedback: true,
        autofocus: true,
        isExtended: true,
        mini: false,
        shape: const CircleBorder(),
        tooltip: "Next",
        splashColor: AppColors.getPrimaryColor,
        focusElevation: 40.sp,
        child: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.getBackgroundColor,
        ),
      ),
    );
  }
}
