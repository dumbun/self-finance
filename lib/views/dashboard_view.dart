import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/models/user_model.dart';
import 'package:self_finance/providers/user_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/views/EMi%20Calculator/emi_calculator_view.dart';
import 'package:self_finance/views/history/history_view.dart';
import 'package:self_finance/views/home_screen.dart';
import 'package:self_finance/views/pin_auth_view.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/dilogbox_widget.dart';
import 'package:self_finance/widgets/expandable_fab.dart';
import 'package:self_finance/widgets/title_widget.dart';

final StateProvider<int> selectedPageIndexProvider = StateProvider<int>((ref) {
  return 0;
});

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    navigateToPinAuthView(User user) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (context) {
          return const PinAuthView();
        },
      ), (route) => false);
    }

    void logout(User user) async {
      int response = await AlertDilogs.alertDialogWithTwoAction(context, "Exit", "Press yes to signout");
      if (response == 1) {
        navigateToPinAuthView(user);
      }
    }

    final PageController pageController = PageController();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Consumer(
          builder: (context, ref, child) {
            final int pageIndex = ref.watch(selectedPageIndexProvider);
            return TitleWidget(
              text: pageIndex == 0
                  ? "Home Screen"
                  : pageIndex == 1
                      ? "EMI Calculator"
                      : "History",
            );
          },
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: "user-profile-pic",
                  child: Consumer(
                    builder: (BuildContext context, WidgetRef ref, Widget? child) {
                      return ref.watch(asyncUserProvider).when(
                            data: (List<User> data) {
                              return data.first.profilePicture.isNotEmpty
                                  ? Utility.imageFromBase64String(
                                      data.first.profilePicture,
                                      height: 45.sp,
                                      width: 45.sp,
                                    )
                                  : DefaultUserImage(
                                      height: 45.sp,
                                      width: 45.sp,
                                    );
                            },
                            error: (Object _, StackTrace __) => const Center(
                              child: Text("error"),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                    },
                  ),
                ),
                SizedBox(height: 24.sp),
                _buildDrawerButtons(
                  text: "Account",
                  icon: Icons.vpn_key_rounded,
                  onTap: () {
                    Routes.navigateToAccountSettingsView(context: context);
                  },
                ),
                SizedBox(height: 12.sp),
                Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    return ref.watch(asyncUserProvider).when(
                          data: (List<User> data) {
                            return _buildDrawerButtons(
                              text: "Logout",
                              icon: Icons.login_rounded,
                              color: AppColors.getErrorColor,
                              onTap: () => logout(data.first),
                            );
                          },
                          error: (error, stackTrace) => Text(error.toString()),
                          loading: () => const CircularProgressIndicator.adaptive(),
                        );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
                children: <Widget>[
                  const HomeScreen(),
                  EMICalculatorView(),
                  const HistoryView(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return ref.watch(selectedPageIndexProvider) == 0
              ? ExpandableFab(
                  distance: 32.sp,
                  children: [
                    ActionButton(
                      toolTip: "Add New Transaction to a existing customer",
                      onPressed: () => {
                        Routes.navigateToContactsView(context),
                      },
                      icon: const Icon(Icons.format_align_left),
                    ),
                    ActionButton(
                      toolTip: "Add New Customer",
                      onPressed: () => Routes.navigateToAddNewEntry(context: context),
                      icon: const Icon(Icons.person_add_alt_1),
                    ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
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

  Widget _buildDrawerButtons(
      {required String text, required IconData icon, required void Function()? onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyOneDefaultText(
                text: text,
                bold: true,
              ),
              Icon(
                icon,
                color: color,
              )
            ],
          ),
        ),
      ),
    );
  }
}
