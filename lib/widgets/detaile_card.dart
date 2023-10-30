import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/constants/routes.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/widgets/arrow_widge.dart';

class DetailCard extends StatelessWidget {
  const DetailCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.0.sp,
        vertical: 6.sp,
      ),
      width: double.infinity,
      child: Card(
        color: getVeryLightGreyColor,
        elevation: 0.0,
        child: InkWell(
          onTap: () => Routes.navigateToDetailsView(context: context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 18.0.sp,
              horizontal: 16.0.sp,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      //image
                      //todo for present we have to use a default icons
                      SizedBox(
                        height: 24.sp,
                        child: SvgPicture.asset("assets/icon/testImage.svg"),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          BodyTwoDefaultText(
                            text: "name",
                            bold: true,
                            color: getPrimaryTextColor,
                          ),
                          SizedBox(height: 8.sp),
                          BodyTwoDefaultText(text: "date"),
                          SizedBox(height: 8.sp),
                          Row(
                            children: [
                              BodyTwoDefaultText(text: "amount : "),
                              BodyTwoDefaultText(
                                bold: true,
                                text: "1234",
                                error: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                getArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
