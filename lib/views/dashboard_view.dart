import 'package:flutter/material.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/views/transactions_view.dart';
import 'package:self_finance/widgets/drawer_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/core/fonts/title_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final PageController _pageController = PageController(initialPage: 0);
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    TransactionsView(),
    EMICalculatorView(),
    HistoryView(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (_, int index, __) {
            return TitleWidget(
              text: switch (index) {
                0 => Constant.homeScreen,
                1 => Constant.transacrtions,
                2 => Constant.emiCalculatorTitle,
                3 => Constant.history,
                _ => Constant.homeScreen,
              },
            );
          },
        ),
      ),
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: GestureDetector(
          onTap: Utility.unfocus,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              _selectedIndex.value = index;
            },
            children: _pages,
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (_, int index, __) {
          return index == 0 ? const ExpandableFab() : const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (_, int index, __) {
          return BottomNavigationBar(
            enableFeedback: true,
            showUnselectedLabels: true,
            elevation: 0,
            unselectedLabelStyle: const TextStyle(
              color: AppColors.getLigthGreyColor,
            ),
            unselectedItemColor: AppColors.getLigthGreyColor,
            unselectedIconTheme: const IconThemeData(
              color: AppColors.getLigthGreyColor,
            ),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: Constant.home,
                tooltip: Constant.homeScreen,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.transform_outlined),
                activeIcon: Icon(Icons.transform_rounded),
                label: Constant.transacrtions,
                tooltip: Constant.historyToolTip,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate_outlined),
                activeIcon: Icon(Icons.calculate_rounded),
                label: Constant.emiCalculatorTitle,
                tooltip: Constant.emiCalculatorToolTip,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_toggle_off),
                activeIcon: Icon(Icons.history_rounded),
                label: Constant.history,
                tooltip: Constant.historyToolTip,
              ),
            ],
            selectedItemColor: AppColors.getPrimaryColor,
            currentIndex: index,
            landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
            type: BottomNavigationBarType.fixed,
            onTap: (int tappedIndex) {
              _selectedIndex.value = tappedIndex;
              _pageController.animateToPage(
                tappedIndex,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOut,
              );
            },
          );
        },
      ),
    );
  }
}
