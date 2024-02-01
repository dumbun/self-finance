import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_two_default_text.dart';
import 'package:self_finance/util.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  const ImagePickerWidget({
    super.key,
    required this.text,
    required this.defaultImage,
    required this.imageProvider,
  });

  final String text;
  final String defaultImage;
  final StateProvider<String> imageProvider;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends ConsumerState<ImagePickerWidget> {
  Widget? pickedItemImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.sp,
      child: Padding(
        padding: EdgeInsets.all(18.sp),
        child: GestureDetector(
          onTap: _doWork,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: pickedItemImage ??
                    SvgPicture.asset(
                      widget.defaultImage,
                      height: 28.sp,
                      width: 28.sp,
                    ),
              ),
              SizedBox(height: 10.sp),
              BodyTwoDefaultText(
                text: widget.text,
                bold: true,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _doWork() {
    pickImageFromCamera().then(
      (value) {
        if (value != "" && value.isNotEmpty) {
          setState(() {
            pickedItemImage = Utility.imageFromBase64String(value);
          });
        }
        ref.read(widget.imageProvider.notifier).update((state) => value);
      },
    );
  }
}
