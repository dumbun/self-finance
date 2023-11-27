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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

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
    final String phoneNumber = widget.phoneNumber;
    if (Utility.isValidPhoneNumber(phoneNumber)) {
      return _hasCallSupport
          ? ElevatedButton(
              style: ButtonStyle(
                alignment: Alignment.center,
                enableFeedback: true,
                animationDuration: Durations.long1,
                shape: const MaterialStatePropertyAll<OutlinedBorder?>(CircleBorder()),
                padding: MaterialStatePropertyAll(EdgeInsets.all(16.sp)),
              ),
              onPressed: () async {
                await _makePhoneCall(widget.phoneNumber);
              },
              child: const Icon(
                Icons.call,
                color: getPrimaryColor,
              ),
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
          color: getErrorColor,
        ),
      ),
    );
  }
}
