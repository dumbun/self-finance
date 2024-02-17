import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/constants/terms_and_conditions_api.dart';
import 'package:self_finance/fonts/body_small_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/fonts/strong_heading_one_text.dart';
import 'package:self_finance/widgets/app_icon.dart';
import 'package:self_finance/widgets/round_corner_button.dart';

class TermsAndConditons extends StatefulWidget {
  const TermsAndConditons({super.key});

  @override
  State<TermsAndConditons> createState() => _TermsAndConditonsState();
}

class _TermsAndConditonsState extends State<TermsAndConditons> {
  bool ticked = false;
  @override
  void initState() {
    ticked = false;
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
              _getNextButton(ticked),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _getNextButton(bool t) {
    return SizedBox(
      width: double.infinity,
      child: RoundedCornerButton(
          text: Constant.next,
          onPressed: () {
            if (t == true) {
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
      onTap: () => setState(() => ticked = !ticked),
      child: Container(
        margin: EdgeInsets.only(top: 20.sp, bottom: 20.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: ticked,
              onChanged: (bool? value) => _getClicked(),
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

  void _getClicked() {
    setState(() {
      ticked = !ticked;
    });
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
