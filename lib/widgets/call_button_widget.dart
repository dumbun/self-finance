import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/theme/colors.dart';
import 'package:self_finance/util.dart';
import 'package:url_launcher/url_launcher.dart';

class CallButtonWidget extends StatefulWidget {
  const CallButtonWidget({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  State<CallButtonWidget> createState() => _CallButtonWidgetState();
}

class _CallButtonWidgetState extends State<CallButtonWidget> {
  bool _hasCallSupport = false;

  @override
  void initState() {
    super.initState();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Utility.isValidPhoneNumber(widget.phoneNumber)) {
      return _hasCallSupport
          ? const Icon(
              Icons.call,
              color: AppColors.getPrimaryColor,
            )
          : _buildDisabledPhone();
    } else {
      return _buildDisabledPhone();
    }
  }

  Card _buildDisabledPhone() {
    return Card(
      shape: const CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: const Icon(
          Icons.phone_disabled_rounded,
          color: AppColors.getErrorColor,
        ),
      ),
    );
  }
}
