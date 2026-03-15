import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/widgets/restore_widget.dart';
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
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // _getIcon(),
                _getHeading(),
                const SizedBox(height: 16),
                // _getTerms(),
                _getCheckBoxWithDescription(),
                _getPrivacyAndPolicyButton(),
                _getNextButton(),
                const SizedBox(height: 16),
                const RestoreWithProgressWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container _getPrivacyAndPolicyButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BodySmallText(
                  bold: true,
                  color: AppColors.getLigthGreyColor,
                  text: Constant.pAndPDistription,
                ),
                const SizedBox(height: 8),
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
            ? () => Navigator.of(context).pushNamed(Constant.pinCreatingView)
            : null,
      ),
    );
  }

  InkWell _getCheckBoxWithDescription() {
    return InkWell(
      onTap: () => setState(() => _ticked = !_ticked),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const BodySmallText(
                    bold: true,
                    color: AppColors.getLigthGreyColor,
                    text: Constant.termAcknowledge,
                  ),
                  const SizedBox(height: 8),
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
}
