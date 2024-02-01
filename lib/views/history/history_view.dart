import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/backend/backend.dart';
import 'package:self_finance/constants/constants.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/models/user_history.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CupertinoSearchTextField(
            controller: searchController,
            autocorrect: false,
            enableIMEPersonalizedLearning: true,
            style: const TextStyle(color: AppColors.getPrimaryColor, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.name,
            onChanged: (value) => ref.read(asyncHistoryProvider.notifier).doSearch(givenInput: value),
          ),
          SizedBox(height: 18.sp),
          Consumer(
            builder: (context, ref, child) {
              return ref.watch(asyncHistoryProvider).when(
                    data: (List<UserHistory> data) {
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(data[index]);
                          },
                          itemCount: data.length,
                        ),
                      );
                    },
                    error: (error, stackTrace) => Text(error.toString()),
                    loading: () => const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  Container _buildHistoryCard(UserHistory data) {
    return Container(
      margin: EdgeInsets.only(top: 12.sp),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIcon(type: data.eventType),
              SizedBox(width: 16.sp),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmount(data.eventType, data.amount),
                    SizedBox(height: 4.sp),
                    _buildCustomerName(data.customerID),
                  ],
                ),
              ),
              _buildDate(data.eventDate),
            ],
          ),
        ),
      ),
    );
  }

  BodyOneDefaultText _buildAmount(String type, double amount) {
    return BodyOneDefaultText(
      text: " ${type == debited ? "-" : "+"}${Utility.doubleFormate(amount)}",
    );
  }

  Column _buildDate(String eventDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          DateFormat.yMMMd().format(DateTime.parse(eventDate)),
          softWrap: true,
          style: TextStyle(color: AppColors.getLigthGreyColor, fontSize: 14.sp),
        ),
        Text(
          DateFormat.Hm().format(DateTime.parse(eventDate)),
          softWrap: true,
          style: TextStyle(color: AppColors.getLigthGreyColor, fontSize: 14.sp),
        ),
      ],
    );
  }

  Container _buildIcon({required String type}) {
    return type == debited
        ? Container(
            height: 26.sp,
            width: 26.sp,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.getErrorColor),
            child: Icon(
              color: AppColors.getBackgroundColor,
              Icons.arrow_upward_rounded,
              size: 22.sp,
            ),
          )
        : Container(
            height: 26.sp,
            width: 26.sp,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.getGreenColor),
            child: Icon(
              color: AppColors.getBackgroundColor,
              Icons.arrow_downward_rounded,
              size: 22.sp,
            ),
          );
  }
}

FutureBuilder _buildCustomerName(int customerID) {
  return FutureBuilder(
    future: BackEnd.fetchRequriedCustomerName(customerID),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return BodyTwoDefaultText(
          text: snapshot.data!,
          bold: true,
          color: AppColors.getLigthGreyColor,
        );
      } else if (snapshot.hasError) {
        return const BodyTwoDefaultText(text: "error");
      } else {
        return const BodyOneDefaultText(text: "else");
      }
    },
  );
}
