import 'package:flutter/material.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/widgets/drawer_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/widgets/title_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int selectedPageIndex = 0;
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: TitleWidget(
          key: GlobalKey(),
          text: switch (selectedPageIndex) {
            0 => Constant.homeScreen,
            1 => Constant.emiCalculatorTitle,
            2 => Constant.history,
            int() => throw UnimplementedError(),
          },
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: GestureDetector(
          onTap: Utility.unfocus,
          child: PageView(
            controller: pageController,
            onPageChanged: (int index) {
              setState(() {
                selectedPageIndex = index;
              });
            },
            children: const <Widget>[
              HomeScreen(),
              EMICalculatorView(),
              HistoryView(),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedPageIndex == 0
          ? const ExpandableFab()
          : const SizedBox.shrink(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: Constant.home,
            tooltip: Constant.homeScreen,
            activeIcon: Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            label: Constant.emiCalculatorTitle,
            activeIcon: Icon(Icons.calculate_rounded),
            tooltip: Constant.emiCalculatorToolTip,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off),
            label: Constant.history,
            activeIcon: Icon(Icons.history_rounded),
            tooltip: Constant.historyToolTip,
          ),
        ],
        selectedItemColor: AppColors.getPrimaryColor,
        currentIndex: selectedPageIndex,
        onTap: (int index) => pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
