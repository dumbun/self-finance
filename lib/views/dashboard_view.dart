import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';

//// provider
final selectedIndexProvider = StateProvider<int>((ref) => 0);
//// provider

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PageController pageController = PageController();
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: Utility.unfocus,
          child: PageView(
            controller: pageController,
            onPageChanged: (index) {
              ref.read(selectedIndexProvider.notifier).update((state) => index);
            },
            children: <Widget>[
              const HomeScreen(),
              EMICalculatorView(),
              const HistoryView(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, ref),
      bottomNavigationBar: _buildBottomNavigationBar(ref, pageController),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    return selectedIndex == 0
        ? FloatingActionButton(
            foregroundColor: AppColors.getPrimaryColor,
            elevation: 2.sp,
            onPressed: () {
              Routes.navigateToAddNewEntry(context: context);
            },
            mini: false,
            shape: const CircleBorder(),
            backgroundColor: AppColors.getPrimaryColor,
            tooltip: addNewEntry,
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.getBackgroundColor,
              size: 25,
            ),
          )
        : null;
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, PageController pageController) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
          tooltip: "Home Screen",
          activeIcon: Icon(Icons.home_rounded),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate_outlined),
          label: 'EMI calculator',
          activeIcon: Icon(Icons.calculate_rounded),
          tooltip: "EMI calculator page where you can callculate intrests",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_toggle_off),
          label: 'History',
          activeIcon: Icon(Icons.history_rounded),
          tooltip: "History Page : Views all your transactions history",
        ),
      ],
      selectedItemColor: AppColors.getPrimaryColor,
      currentIndex: ref.watch(selectedIndexProvider.notifier).state,
      onTap: (index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}
