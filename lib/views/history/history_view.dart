import 'package:flutter/material.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/widgets/detail_card_widget.dart';
import 'package:self_finance/widgets/title_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/providers/transactions_provider.dart';

/// Providers

final searchHintTextProvider = StateProvider<String>((ref) => searchMobile);
final searchSelectedFilterProvider = StateProvider<String>((ref) => "Mobile Number");

///

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(asyncTransactionsProvider.future),
        child: Container(
          padding: EdgeInsets.all(16.sp),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: TitleWidget(text: history),
              ),
              SizedBox(height: 20.sp),
              buildSearchBar(ref),
              SizedBox(height: 10.sp),
              Expanded(child: buildData(ref)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildData(WidgetRef ref) {
    return ref.watch(asyncTransactionsProvider).when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(
                child: BodyOneDefaultText(
                  text: noTransactionsFound,
                  bold: true,
                ),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                return DetailCardWidget(data: data[index]);
              },
            );
          },
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget buildSearchBar(WidgetRef ref) {
    final String hintText = ref.watch(searchHintTextProvider);
    final String filterText = ref.watch(searchSelectedFilterProvider);

    //seach function
    doSearch(value) {
      switch (filterText) {
        case mobileNumber:
          ref.read(asyncTransactionsProvider.notifier).doMobileSearch(mobileNumber: value);
          break;
        case customerName:
          ref.read(asyncTransactionsProvider.notifier).doNameSearch(customerName: value);
          break;
        case customerPlace:
          ref.read(asyncTransactionsProvider.notifier).doPlaceSearch(place: value);
          break;
        default:
          ref.read(asyncTransactionsProvider.notifier).doMobileSearch(mobileNumber: value);
      }
    }

    return SearchBar(
      elevation: MaterialStateProperty.all<double>(0),
      padding: MaterialStateProperty.all<EdgeInsets>(
        EdgeInsets.only(left: 16.sp),
      ),
      hintText: hintText,
      leading: const Icon(
        Icons.search,
        color: AppColors.getPrimaryColor,
      ),
      trailing: [
        PopupMenuButton<String>(
          enableFeedback: true,
          icon: const Icon(Icons.filter_alt_outlined),
          iconColor: AppColors.getPrimaryColor,
          tooltip: filterText,
          onSelected: (String filter) {
            final update = ref.read(searchHintTextProvider.notifier);
            update.update((state) {
              switch (filter) {
                case mobileNumber:
                  return searchMobile;
                case customerName:
                  return searchName;
                case customerPlace:
                  return searchPlace;
                default:
                  return searchMobile;
              }
            });
            ref.read(searchSelectedFilterProvider.notifier).update((state) => state = filter);
          },
          initialValue: filterText,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: mobileNumber,
              child: BodyTwoDefaultText(text: mobileNumber),
            ),
            const PopupMenuItem<String>(
              value: customerName,
              child: BodyTwoDefaultText(text: customerName),
            ),
            const PopupMenuItem<String>(
              value: customerPlace,
              child: BodyTwoDefaultText(text: customerPlace),
            ),
          ],
        ),
      ],
      onSubmitted: (String value) => doSearch(value),
      onChanged: (String value) => doSearch(value),
    );
  }
}
