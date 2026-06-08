import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/fonts/strong_heading_one_text.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/views/EMI%20Calculator/emi_calculator_view.dart';
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
  final PageController _pageController = PageController(initialPage: 0);
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (_, int index, _) {
          return NavigationBar(
            maintainBottomViewPadding: true,
            selectedIndex: index,
            onDestinationSelected: (int tappedIndex) {
              _pageController.animateToPage(
                tappedIndex,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
              );
            },
            indicatorColor: AppColors.getPrimaryColor,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            labelTextStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                label: Constant.emiCalculatorTitle,
                selectedIcon: Icon(Icons.calculate),
                tooltip: Constant.calculator,
              ),
              NavigationDestination(
                icon: Icon(Icons.person_2_outlined),
                selectedIcon: Icon(Icons.person),
                label: Constant.account,
                tooltip: Constant.account,
              ),
            ],
          );
        },
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (int index) {
            _selectedIndex.value = index;
          },
          children: <Widget>[
            const SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 22),
                  TitleWidget(text: Constant.emiCalculatorTitle),
                  EMICalculatorView(),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _getHeading(),
                    const SizedBox(height: 16),
                    _getCheckBoxWithDescription(),
                    _getPrivacyAndPolicyButton(),
                    _getNextButton(),
                    const SizedBox(height: 16),
                    const RestoreWithProgressWidget(),
                  ],
                ),
              ),
            ),
          ],
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
