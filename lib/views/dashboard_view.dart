import 'package:material_ui/material_ui.dart';
import 'package:self_finance/core/localization/localization_extension.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/views/transactions_view.dart';
import 'package:self_finance/widgets/drawer_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/title_widget.dart';
import 'package:self_finance/widgets/app_icon_widget.dart';
import 'package:self_finance/widgets/offline_indicator.dart';
import 'package:self_finance/widgets/sync_indicator_icon_button.dart';
import 'package:self_finance/widgets/theme_toggle_icon_button.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.scaffoldBackgroundColor,
        actionsPadding: const EdgeInsets.only(right: 12),
        actions: const [
          OfflineIndicator(),
          SyncIndicatorIconButton(),
          ThemeToggleIconButton(),
        ],
        title: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (_, int index, _) {
            if (index == 0) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIconWidget(height: 28, width: 28),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TitleWidget(text: 'Self Finance'),
                      BodySmallText(
                        text: l10n.portfolioOverview,
                        color: AppColors.getLigthGreyColor,
                      ),
                    ],
                  ),
                ],
              );
            }
            return TitleWidget(
              text: switch (index) {
                1 => l10n.transactions,
                2 => l10n.emiCalculatorTitle,
                3 => l10n.history,
                _ => l10n.dashboard,
              },
            );
          },
        ),
      ),
      drawer: const DrawerWidget(),
      body: PageView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return switch (index) {
            0 => HomeScreen(onNavigateToTab: _navigateToPage),
            1 => const TransactionsView(),
            2 => const EMICalculatorView(),
            3 => const HistoryView(),
            _ => HomeScreen(onNavigateToTab: _navigateToPage),
          };
        },
        controller: _pageController,
        onPageChanged: (int index) {
          _selectedIndex.value = index;
        },
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
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                label: l10n.home,
                selectedIcon: const Icon(Icons.home_filled),
                tooltip: l10n.homeScreen,
              ),
              NavigationDestination(
                icon: const Icon(Icons.book_outlined),
                selectedIcon: const Icon(Icons.book_rounded),
                label: l10n.transactions,
                tooltip: l10n.transactions,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calculate_outlined),
                selectedIcon: const Icon(Icons.calculate_rounded),
                label: l10n.calculator,
                tooltip: l10n.calculator,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_toggle_off),
                selectedIcon: const Icon(Icons.history_rounded),
                label: l10n.history,
                tooltip: l10n.history,
              ),
            ],
          );
        },
      ),
    );
  }
}
