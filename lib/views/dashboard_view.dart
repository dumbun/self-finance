import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/theme/app_colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/widgets/drawer_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/widgets/title_widget.dart';

//? providers
///[selectedPageIndexProvider] is a provider which is auto dispose
///this provider helps to maintain
///the state of the buttom navigation bar in the dashboard
final StateProvider<int> selectedPageIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final StateProvider<PageController> dashboardPageController = StateProvider<PageController>((ref) {
  final PageController pageController = PageController();
  return pageController;
});

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = ref.watch(dashboardPageController);
    final int selectedPageIndex = ref.watch(selectedPageIndexProvider);
    void changePage(int index) {
      final PageController dashboardController = ref.read(dashboardPageController);
      dashboardController.animateToPage(
        index,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: TitleWidget(
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
              ref.read(selectedPageIndexProvider.notifier).update((state) => index);
            },
            children: const <Widget>[
              HomeScreen(),
              EMICalculatorView(),
              HistoryView(),
            ],
          ),
        ),
      ),
      floatingActionButton: selectedPageIndex == 0 ? const ExpandableFab() : const SizedBox.shrink(),
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
        onTap: (index) => changePage(index),
      ),
    );
  }
}
