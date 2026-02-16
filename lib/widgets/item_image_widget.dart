import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/core/constants/constants.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/models/items_model.dart';
import 'package:self_finance/providers/item_provider.dart';

class ItemImageWidget extends ConsumerWidget {
  const ItemImageWidget({super.key, required this.transactionId});
  final int transactionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(itemByIdProvider(transactionId))
        .when(
          data: (Items? item) {
            if (item == null) {
              return const BodyTwoDefaultText(text: "Error fetching Item data");
            }
            if (item.photo.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTwoDefaultText(
                    bold: true,
                    text: Constant.itemDescription,
                  ),
                  Card(
                    elevation: 2,
                    child: ListTile(
                      title: BodyTwoDefaultText(
                        bold: true,
                        text: item.description,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTwoDefaultText(
                    bold: true,
                    text: Constant.customerItem,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(12.sp),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => Routes.navigateToImageView(
                                context: context,
                                titile: item.description,
                                imageWidget: Image.file(File(item.photo)),
                              ),
                              child: Image.file(
                                height: 52.sp,
                                width: 42.sp,
                                File(item.photo),
                              ),
                            ),
                            BodyTwoDefaultText(
                              bold: true,
                              text: item.description,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
          error: (error, stackTrace) =>
              BodyTwoDefaultText(text: error.toString()),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}
