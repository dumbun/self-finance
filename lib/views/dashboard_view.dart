import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
import 'package:self_finance/widgets/theme_toggle_icon_button.dart';

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
        actionsPadding: EdgeInsets.only(right: 12.sp),
        actions: [ThemeToggleIconButton(size: 22.sp)],
        forceMaterialTransparency: true,
        title: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (_, int index, _) {
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
        builder: (_, int index, _) {
          return index == 0 ? const ExpandableFab() : const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (_, int index, _) {
          return NavigationBar(
            key: const ValueKey(0),
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
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                label: Constant.home,
                selectedIcon: Icon(Icons.home_filled),
                tooltip: Constant.homeScreen,
              ),
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book_rounded),
                label: Constant.transacrtions,
                tooltip: Constant.historyToolTip,
              ),
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate_rounded),
                label: Constant.calculator,
                tooltip: Constant.emiCalculatorToolTip,
              ),
              NavigationDestination(
                icon: Icon(Icons.history_toggle_off),
                selectedIcon: Icon(Icons.history_rounded),
                label: Constant.history,
                tooltip: Constant.historyToolTip,
              ),
            ],
          );
        },
      ),
    );
  }
}
