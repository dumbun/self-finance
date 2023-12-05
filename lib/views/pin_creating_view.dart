import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/pin_input_widget.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class PinCreatingView extends StatefulWidget {
  const PinCreatingView({super.key});

  @override
  State<PinCreatingView> createState() => _PinCreatingViewState();
}

class _PinCreatingViewState extends State<PinCreatingView> {
  bool _samePin = false;
  final TextEditingController p2 = TextEditingController();
  final TextEditingController p1 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(18.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getAppIcon(),
            SizedBox(height: 20.sp),
            const BodyOneDefaultText(
              bold: true,
              text: "Please create your login pin",
            ),
            SizedBox(height: 20.sp),
            PinInputWidget(pinController: p1, obscureText: false),
            SizedBox(height: 20.sp),
            PinInputWidget(pinController: p2, obscureText: false),
            SizedBox(height: 20.sp),
            Visibility(
              visible: !_samePin,
              child: const BodyOneDefaultText(
                text: "Please Enter same pin",
                bold: true,
                error: true,
              ),
            ),
            SizedBox(height: 20.sp),
            RoundedCornerButton(
              onPressed: () {
                if (p1.text != p2.text) {
                  setState(() {
                    _samePin = false;
                  });
                } else {
                  setState(() {
                    _samePin = true;
                    Routes.navigateToUserCreationView(context, p1.text);
                  });
                }
              },
              text: "save",
            ),
          ],
        ),
      ),
    );
  }

  _getAppIcon() {
    return Container(
      alignment: Alignment.center,
      height: 32.sp,
      child: AppIcon(),
    );
  }
}
