import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/views/emi_calculator.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (details) => FocusManager.instance.primaryFocus?.unfocus(),
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const <Widget>[
              HomeScreen(),
              EmiCalculator(),
              HistoryView(),
            ],
          ),
        ),
        floatingActionButton: _FloatingActionButton(selectedIndex: _selectedIndex),
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

class _FloatingActionButton extends StatelessWidget {
  const _FloatingActionButton({Key? key, required this.selectedIndex}) : super(key: key);

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 0) {
      return FloatingActionButton(
        clipBehavior: Clip.antiAlias,
        foregroundColor: getPrimaryColor,
        elevation: 2.sp,
        onPressed: () => Routes.navigateToAddNewEntry(context: context),
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
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
