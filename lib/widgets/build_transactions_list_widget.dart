import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:self_finance/core/constants/routes.dart';
import 'package:self_finance/core/fonts/body_small_text.dart';
import 'package:self_finance/core/fonts/body_text.dart';
import 'package:self_finance/core/fonts/body_two_default_text.dart';
import 'package:self_finance/core/theme/app_colors.dart';
import 'package:self_finance/core/utility/user_utility.dart';
import 'package:self_finance/models/trx_with_customer_model.dart';
import 'package:self_finance/providers/transactions_provider.dart';
import 'package:self_finance/widgets/circular_image_widget.dart';
import 'package:self_finance/widgets/currency_widget.dart';
import 'package:self_finance/widgets/default_user_image.dart';
import 'package:self_finance/widgets/slidable_widget.dart';
import 'package:self_finance/widgets/status_chip_widget.dart';

class BuildTransactionsListWidget extends ConsumerStatefulWidget {
  const BuildTransactionsListWidget({super.key});

  @override
  ConsumerState<BuildTransactionsListWidget> createState() =>
      _BuildTransactionsListWidgetState();
}

class _BuildTransactionsListWidgetState
    extends ConsumerState<BuildTransactionsListWidget> {
  static const double _loadMoreThreshold = 300;
  late final ScrollController _scrollController;

  /// Prevents multiple postFrameCallbacks from stacking up across consecutive
  /// build() calls during a single async cycle.
  bool _viewportFillPending = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final ScrollPosition pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - _loadMoreThreshold) {
      ref.read(transactionsProvider.notifier).loadMore();
    }
  }

  void _scheduleViewportFill() {
    if (_viewportFillPending) return;
    _viewportFillPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewportFillPending = false;
      if (!mounted || !_scrollController.hasClients) return;
      final TransactionsPaginationState? state =
          ref.read(transactionsProvider).value;
      if (state == null ||
          !state.hasMore ||
          state.isLoadingMore ||
          state.loadMoreError != null) {
        return;
      }
      if (_scrollController.position.maxScrollExtent <= 0) {
        ref.read(transactionsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(transactionsProvider).when(
      data: (TransactionsPaginationState state) {
        final List<TrxWithCustomer> data = state.transactions;
        final bool hasMore = state.hasMore;
        final bool isLoadingMore = state.isLoadingMore;
        final Object? loadMoreError = state.loadMoreError;

        if (data.isEmpty) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: BodyOneDefaultText(
                    bold: true,
                    text: 'No Transactions to view',
                  ),
                ),
              ),
            ),
          );
        }

        // Only trigger viewport fill if there is more data, not already loading, and no error.
        if (hasMore && !isLoadingMore && loadMoreError == null) {
          _scheduleViewportFill();
        }

        final bool showFooter = isLoadingMore || loadMoreError != null;

        return ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: data.length + (showFooter ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= data.length) {
              if (loadMoreError != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const BodySmallText(
                          text: 'Failed to load more transactions',
                          color: AppColors.getLigthGreyColor,
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(transactionsProvider.notifier)
                              .loadMore(isRetry: true),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator.adaptive()),
              );
            }

            final TrxWithCustomer txn = data[index];
            return SlidableWidget(
              key: ValueKey(txn.id),
              customerId: txn.customerId,
              transactionId: txn.id,
              child: ListTile(
                onTap: () => Routes.navigateToTransactionDetailsView(
                  transacrtionId: txn.id,
                  customerId: txn.customerId,
                  context: context,
                ),
                leading: txn.customerPhoto.isNotEmpty
                    ? CircularImageWidget(
                        errorBuilder: DefaultUserImage(
                          userName: txn.customerName,
                        ),
                        customeSize: 44,
                        imageData: txn.customerPhoto,
                        titile: txn.customerName,
                        heroTag: '${txn.customerName}-${txn.id}',
                      )
                    : DefaultUserImage(
                        userName: txn.customerName,
                        height: 44,
                        width: 44,
                      ),
                title: CurrencyWidget(
                  amount: Utility.doubleFormate(txn.amount),
                ),
                subtitle: BodySmallText(
                  text: txn.customerName.isNotEmpty
                      ? txn.customerName
                      : 'Unknown',
                  bold: true,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.getLigthGreyColor,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodySmallText(
                      text: Utility.formatDate(date: txn.transactionDate),
                      bold: true,
                      color: AppColors.getLigthGreyColor,
                    ),
                    StatusChipWidget(
                      smallText: true,
                      status: txn.transactionType,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      error: (Object error, StackTrace stackTrace) =>
          BodyTwoDefaultText(text: error.toString()),
      loading: () =>
          const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
