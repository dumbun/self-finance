import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/utility/user_utility.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/widgets/drawer_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/widgets/title_widget.dart';

final StateProvider<int> selectedPageIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final int pageIndex = ref.watch(selectedPageIndexProvider);
            return TitleWidget(
              text: switch (pageIndex) {
                0 => Constant.homeScreen,
                1 => Constant.emiCalculatorTitle,
                2 => Constant.history,
                int() => throw UnimplementedError(),
              },
            );
          },
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: GestureDetector(
          onTap: Utility.unfocus,
          child: Consumer(
            builder: (context, ref, child) {
              return PageView(
                controller: pageController,
                onPageChanged: (index) {
                  ref.read(selectedPageIndexProvider.notifier).update((state) => index);
                },
                children: const <Widget>[
                  HomeScreen(),
                  EMICalculatorView(),
                  HistoryView(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final int pageIndex = ref.watch(selectedPageIndexProvider);
          return switch (pageIndex) {
            0 => ExpandableFab(
                distance: 32.sp,
                children: [
                  ActionButton(
                    toolTip: Constant.addNewTransactionToolTip,
                    onPressed: () => {
                      Routes.navigateToContactsView(context),
                    },
                    icon: const Icon(Icons.format_align_left),
                  ),
                  ActionButton(
                    toolTip: Constant.addNewCustomerToolTip,
                    onPressed: () => Routes.navigateToAddNewEntry(context: context),
                    icon: const Icon(Icons.person_add_alt_1),
                  ),
                ],
              ),
            _ => const SizedBox.shrink()
          };
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return BottomNavigationBar(
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
            currentIndex: ref.watch(selectedPageIndexProvider),
            onTap: (index) {
              pageController.animateToPage(
                index,
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
