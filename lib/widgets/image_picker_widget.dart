import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/fonts/body_text.dart';
import 'package:self_finance/util.dart';
import 'package:self_finance/widgets/image_widget.dart';

class ImagePickerWidget extends ConsumerStatefulWidget {
  const ImagePickerWidget({
    Key? key,
    required this.text,
    required this.defaultImage,
    required this.imageProvider,
  }) : super(key: key);

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
      child: InkWell(
        onTap: _doWork,
        child: Container(
          margin: EdgeInsets.all(15.sp),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.sp),
                child: pickedItemImage ??
                    ImageWidget(
                      height: 25.sp,
                      width: 25.sp,
                      shape: BoxShape.rectangle,
                      child: SvgPicture.asset(widget.defaultImage),
                    ),
              ),
              SizedBox(height: 10.sp),
              BodyOneDefaultText(text: widget.text)
            ],
          ),
        ),
      ),
    );
  }

  void _doWork() {
    pickImageFromCamera().then((value) {
      if (value != "" && value.isNotEmpty) {
        setState(() {
          pickedItemImage = Utility.imageFromBase64String(value);
        });
      }
      ref.read(widget.imageProvider.notifier).state = value;
    });
  }
}
