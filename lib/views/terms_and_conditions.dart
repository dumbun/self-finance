import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/bodySmallText.dart';
import 'package:self_finance/fonts/bodyTwoDefaultText.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/fonts/strognHeadingOneText.dart';

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
      body: Container(
        padding: EdgeInsets.all(24.sp),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _getIcon(),
            _getHeading(),
            _space(),
            _getDetails(),
            _getNextButton(),
          ],
        ),
      ),
    );
  }

  _getNextButton() {
    return Container(
      margin: EdgeInsets.only(top: 20.sp),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: ticked
            ? () {
                //todo navigate to next page
              }
            : null,
        child: const BodyTwoDefaultText(
          text: "Next",
          color: getBackgroundColor,
          bold: true,
        ),
      ),
    );
  }

  Container _getDetails() {
    return Container(
      height: 88.sp,
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 90.sp,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BodyTwoDefaultText(
                text: testText,
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(text: "Conditions:", bold: true),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "1. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "2. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "3. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "4. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "5. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "6. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "7. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              const BodyTwoDefaultText(
                text: "8. $testText",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.sp),
              _getCheckBoxWithDescription(),
              SizedBox(height: 16.sp),
            ],
          ),
        ),
      ),
    );
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
            height: 25.sp,
            child: const BodySmallText(
              text: testCheckbox,
            ),
          )
        ],
      ),
    );
  }

  dynamic _getClicked() {
    setState(() {
      ticked = !ticked;
    });
  }

  Container _getHeading() {
    return Container(
      alignment: Alignment.topLeft,
      child: const StrongHeadingOne(
        text: "Term & Conditions",
        bold: true,
        textAlign: TextAlign.justify,
      ),
    );
  }

  SizedBox _space() {
    return SizedBox(
      height: 24.sp,
    );
  }

  Center _getIcon() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 32.sp, bottom: 28.sp),
        child: SvgPicture.asset(
          "assets/icon/iconWithOutBackground.svg",
        ),
      ),
    );
  }
}
