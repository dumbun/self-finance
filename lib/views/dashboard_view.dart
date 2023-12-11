import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/user_db.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/providers/user_backend_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  late PageController _pageController;
  int _selectedIndex = 0;

  void userDataUpdate() async {
    final data = await UserBackEnd.fetchUserData();
    if (data.isNotEmpty) {
      ref.read(up.notifier).state = data[0];
    }
  }

  @override
  void initState() {
    userDataUpdate();
    _pageController = PageController(initialPage: _selectedIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
                // pageTitle = pageTitels[index];
              });
            },
            children: <Widget>[
              const HomeScreen(),
              EMICalculatorView(),
              const HistoryView(),
            ],
          ),
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                foregroundColor: getPrimaryColor,
                elevation: 2.sp,
                onPressed: () {
                  Routes.navigateToAddNewEntry(context: context);
                  ImageCacheManager.prin();
                },
                enableFeedback: true,
                mini: false,
                shape: const CircleBorder(),
                backgroundColor: getPrimaryColor,
                tooltip: addNewEntry,
                child: const Icon(
                  Icons.add_rounded,
                  color: getBackgroundColor,
                  size: 25,
                ),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              label: 'EMI calculator',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
          ],
          selectedItemColor: getPrimaryColor,
          currentIndex: _selectedIndex,
          enableFeedback: true,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
