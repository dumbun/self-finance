import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_small_text.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/utility/restore_utility.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class TermsAndConditons extends StatefulWidget {
  const TermsAndConditons({super.key});

  @override
  State<TermsAndConditons> createState() => _TermsAndConditonsState();
}

class _TermsAndConditonsState extends State<TermsAndConditons> {
  bool _ticked = false;
  bool _pAndP = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(24.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // _getIcon(),
                _getHeading(),
                SizedBox(height: 16.sp),
                // _getTerms(),
                _getCheckBoxWithDescription(),
                _getPrivacyAndPolicyButton(),
                _getNextButton(),
                SizedBox(height: 16.sp),
                _getRestoreButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getRestoreButton() {
    return RoundedCornerButton(
      text: "Restore",
      onPressed: () {
        RestoreUtility.restoreBackupFromZip();
      },
    );
  }

  Container _getPrivacyAndPolicyButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.sp),
      child: InkWell(
        onTap: () => setState(() {
          _pAndP = !_pAndP;
        }),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _pAndP,
              onChanged: (bool? value) => setState(() {
                _pAndP = value!;
              }),
              activeColor: AppColors.getPrimaryColor,
            ),
            SizedBox(width: 10.sp),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodySmallText(
                  bold: true,
                  color: AppColors.getLigthGreyColor,
                  text: Constant.pAndPDistription,
                ),
                SizedBox(height: 8.sp),
                GestureDetector(
                  onTap: () => Utility.launchInBrowserView(Constant.pAndPUrl),
                  child: const BodySmallText(
                    bold: true,
                    color: AppColors.getPrimaryColor,
                    text: "Click Here to see",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SizedBox _getNextButton() {
    return SizedBox(
      width: double.infinity,
      child: RoundedCornerButton(
        text: Constant.next,
        onPressed: _pAndP == true && _ticked == true
            ? () => Routes.navigateToPinCreationView(context)
            : null,
      ),
    );
  }

  InkWell _getCheckBoxWithDescription() {
    return InkWell(
      onTap: () => setState(() => _ticked = !_ticked),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 20.sp, bottom: 20.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _ticked,
              onChanged: (bool? value) {
                setState(() {
                  _ticked = value!;
                });
              },
              activeColor: AppColors.getPrimaryColor,
            ),
            SizedBox(width: 10.sp),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 66.sp,
                  height: 34.sp,
                  child: const BodySmallText(
                    bold: true,
                    color: AppColors.getLigthGreyColor,
                    text: Constant.termAcknowledge,
                  ),
                ),
                SizedBox(height: 8.sp),
                GestureDetector(
                  onTap: () => Utility.launchInBrowserView(Constant.tAndcUrl),
                  child: const BodySmallText(
                    bold: true,
                    color: AppColors.getPrimaryColor,
                    text: "Click Here to see",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _getHeading() {
    return Container(
      alignment: Alignment.topLeft,
      child: const StrongHeadingOne(
        text: "Please Accept Terms And Conditions",
        bold: true,
        textAlign: TextAlign.start,
      ),
    );
  }

  // Center _getIcon() {
  //   return Center(
  //     child: Container(
  //       margin: EdgeInsets.only(top: 20.sp, bottom: 24.sp),
  //       child: const AppIcon(),
  //     ),
  //   );
  // }
}
