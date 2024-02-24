import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/constants/terms_and_conditions_api.dart';
import 'package:self_finance/fonts/body_small_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/widgets/app_icon.dart';
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
  void initState() {
    _ticked = false;
    _pAndP = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _getIcon(),
              _getHeading(),
              SizedBox(height: 16.sp),
              _getTerms(),
              _getCheckBoxWithDescription(),
              _getPrivacyAndPolicyButton(),
              _getNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  _getPrivacyAndPolicyButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
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
          GestureDetector(
            onTap: () => Utility.launchInBrowserView(Constant.pAndPUrl),
            child: SizedBox(
              width: 60.sp,
              height: 28.sp,
              child: const BodySmallText(
                bold: true,
                color: AppColors.getPrimaryColor,
                text: Constant.pAndPDistription,
              ),
            ),
          )
        ],
      ),
    );
  }

  SizedBox _getNextButton() {
    return SizedBox(
      width: double.infinity,
      child: RoundedCornerButton(
          text: Constant.next,
          onPressed: () {
            if (_pAndP == true && _ticked == true) {
              Routes.navigateToPinCreationView(context);
            }
          }),
    );
  }

  Expanded _getTerms() {
    List<Widget> result = [];

    for (var element in TermsAndConditions.termsAndConditionsMap.entries) {
      result.add(BodyTwoDefaultText(
        text: element.key,
        bold: true,
      ));
      result.add(SizedBox(height: 16.sp));
      for (var element in element.value) {
        result.add(BodyTwoDefaultText(
          text: element,
          color: AppColors.getLigthGreyColor,
        ));
        result.add(SizedBox(height: 16.sp));
      }
    }

    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: result.length,
        itemBuilder: (BuildContext context, int index) => result[index],
      ),
    );
  }

  InkWell _getCheckBoxWithDescription() {
    return InkWell(
      onTap: () => setState(() => _ticked = !_ticked),
      child: Container(
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
            SizedBox(
              width: 66.sp,
              height: 30.sp,
              child: const BodySmallText(
                color: AppColors.getLigthGreyColor,
                text: Constant.termAcknowledge,
              ),
            )
          ],
        ),
      ),
    );
  }

  Container _getHeading() {
    return Container(
      alignment: Alignment.topLeft,
      child: const StrongHeadingOne(
        text: Constant.tAndcString,
        bold: true,
        textAlign: TextAlign.justify,
      ),
    );
  }

  Center _getIcon() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 20.sp, bottom: 24.sp),
        child: const AppIcon(),
      ),
    );
  }
}
