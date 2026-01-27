import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:self_finance/providers/history_provider.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/widgets/build_history_list_widget.dart';
import 'package:self_finance/widgets/refresh_widget.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshWidget(
      onRefresh: () => ref.refresh(asyncHistoryProvider.future),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoSearchTextField(
              controller: _controller,
              autocorrect: false,
              style: const TextStyle(
                color: AppColors.getPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.name,
              onChanged: (String value) => ref
                  .read(asyncHistoryProvider.notifier)
                  .doSearch(givenInput: value),
            ),
            SizedBox(height: 12.sp),
            const Expanded(child: BuildHistoryListWidget()),
          ],
        ),
      ),
    );
  }
}
