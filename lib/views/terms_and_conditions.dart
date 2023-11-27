import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/constants/terms_and_conditions_api.dart';
import 'package:self_finance/fonts/body_small_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';
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
      backgroundColor: getBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(24.sp),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _getIcon(),
                _getHeading(),
                _space(),
                _getTermsAndConditions(),
                _getNextButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getNextButton() {
    return SizedBox(
      width: double.infinity,
      child: RoundedCornerButton(
        text: next,
        onPressed: ticked ? () => Routes.navigateToPinCreationView(context) : null,
      ),
    );
  }

  Column _getTermsAndConditions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getTerms(),
        ),
        SizedBox(height: 16.sp),
        _getCheckBoxWithDescription(),
        SizedBox(height: 16.sp),
      ],
    );
  }

  List<Widget> _getTerms() {
    List<Widget> result = [];
    for (var element in termsAndConditionsMap.entries) {
      result.add(BodyTwoDefaultText(
        text: element.key,
        bold: true,
        color: getPrimaryTextColor,
      ));
      result.add(SizedBox(height: 16.sp));
      for (var element in element.value) {
        result.add(BodyTwoDefaultText(
          text: element,
          color: getPrimaryTextColor,
        ));
        result.add(SizedBox(height: 16.sp));
      }
    }
    return result;
  }

  InkWell _getCheckBoxWithDescription() {
    return InkWell(
      onTap: () => setState(() => ticked = !ticked),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: ticked,
            onChanged: (value) => _getClicked(),
            activeColor: getPrimaryColor,
          ),
          SizedBox(width: 10.sp),
          SizedBox(
            width: 66.sp,
            height: 30.sp,
            child: const BodySmallText(
              text: termAcknowledge,
            ),
          )
        ],
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
        text: tAndMString,
        bold: true,
        textAlign: TextAlign.justify,
      ),
    );
  }

  SizedBox _space() {
    return SizedBox(height: 24.sp);
  }

  Center _getIcon() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 24.sp, bottom: 24.sp),
        child: const AppIcon(),
      ),
    );
  }
}
