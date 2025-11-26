import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/admin_orders_bloc.dart';
import '../bloc/admin_orders_event.dart';
import '../bloc/admin_orders_state.dart';
import '../../domain/entities/admin_order.dart';
import 'package:amerli_app/core/error/error_handler.dart';
import 'package:amerli_app/widgets/searchbar.dart';
import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:amerli_app/core/utils/top_toast.dart';
import 'package:amerli_app/core/utils/csv_export_helper.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<AdminOrdersBloc>()
        .add(AdminOrdersLoadEvent(page: 1, limit: 20));
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final state = context.read<AdminOrdersBloc>().state;
      if (state is AdminOrdersLoaded && state.hasMore && !state.isLoadingMore) {
        context.read<AdminOrdersBloc>().add(AdminOrdersLoadEvent(
            query: state.query, page: state.currentPage + 1, limit: 20));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminOrdersBloc>().add(AdminOrdersLoadEvent(
        query: query.isEmpty ? null : query, page: 1, limit: 20));
  }

  Future<void> _onExportCSV() async {
    final state = context.read<AdminOrdersBloc>().state;
    if (state is! AdminOrdersLoaded || state.orders.isEmpty) {
      TopToast.show(context, AppLanguage.noOrdersFound, isError: true);
      return;
    }

    try {
      final headers = [
        'ID',
        'Order Number',
        'Customer',
        'Store',
        'Phone',
        'Date',
        'Status',
        'Total',
        'Items Count',
        'Payment Method'
      ];

      final data = state.orders.map((order) {
        return [
          order.id,
          order.orderNumber,
          order.customerName,
          order.storeName,
          order.customerPhone,
          order.orderDate.toString(),
          order.status,
          order.totalAmount,
          order.itemsCount,
          order.paymentMethod,
        ];
      }).toList();

      await CsvExportHelper.exportToCsv(
        fileName: 'orders_export_${DateTime.now().millisecondsSinceEpoch}',
        headers: headers,
        data: data,
      );
    } catch (e) {
      if (mounted) {
        TopToast.show(context, AppLanguage.csvExportError, isError: true);
      }
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();

    // Cancelled (Red)
    if (s.contains('annul') ||
        s.contains('cancel') ||
        s.contains('إلغاء') ||
        s.contains('ملغ')) {
      return const Color(0xFFF34141);
    }

    // Delivered / Delivering (Green)
    if (s.contains('livré') ||
        s.contains('livree') ||
        s.contains('deliv') ||
        s.contains('delivered') ||
        s.contains('توصيل') ||
        s.contains('مستلم') ||
        s.contains('تم التسليم')) {
      return const Color(0xFF4AA785);
    }

    // Preparing (Blue)
    if (s.contains('préparation') ||
        s.contains('preparation') ||
        s.contains('preparing') ||
        s.contains('تحضير') ||
        s.contains('تجهيز')) {
      return const Color(0xFF59A8D4);
    }

    // Pending (Yellow)
    if (s.contains('en attente') ||
        s.contains('pending') ||
        s.contains('confirmation') ||
        s.contains('confirm') ||
        s.contains('انتظار') ||
        s.contains('معلق')) {
      return const Color(0xFFFFC555);
    }

    return Colors.grey;
  }

  String _getLocalizedStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('annul') || s.contains('cancel') || s.contains('ملغ')) {
      return AppLanguage.cancelled;
    }
    if (s.contains('livré') ||
        s.contains('delivered') ||
        s.contains('تم التسليم')) {
      return AppLanguage.delivered;
    }
    if (s.contains('préparation') ||
        s.contains('preparing') ||
        s.contains('تحضير')) {
      return AppLanguage.preparing;
    }
    if (s.contains('attente') ||
        s.contains('pending') ||
        s.contains('انتظار')) {
      return AppLanguage.pending;
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: AppLanguage.localeNotifier,
      builder: (context, locale, _) =>
          BlocListener<AdminOrdersBloc, AdminOrdersState>(
        listener: (context, state) {
          if (state is AdminOrdersError) {
            ErrorHandler.showError(context, state.message);
          }
          if (state is AdminOrdersLoaded) {
            if (state.message != null) {
              TopToast.show(context, state.message!);
            }
            if (state.errorMessage != null) {
              TopToast.show(context, state.errorMessage!, isError: true);
            }
          }
          if (state is AdminOrdersOperationSuccess) {
            TopToast.show(context, state.message);
            // Refresh list
            context
                .read<AdminOrdersBloc>()
                .add(AdminOrdersLoadEvent(page: 1, limit: 20));
          }
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      AppLanguage.orders,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Search and Export Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: AppSearchbar(
                              controller: _searchController,
                              onChanged: _onSearch,
                              showFilter: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Export Button
                        ElevatedButton(
                          onPressed: _onExportCSV,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLanguage.exportCSV,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Orders Table
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<AdminOrdersBloc>()
                            .add(AdminOrdersLoadEvent(page: 1, limit: 20));
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo is ScrollEndNotification &&
                              scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                            final state = context.read<AdminOrdersBloc>().state;
                            if (state is AdminOrdersLoaded &&
                                state.hasMore &&
                                !state.isLoadingMore) {
                              context.read<AdminOrdersBloc>().add(
                                  AdminOrdersLoadEvent(
                                      query: state.query,
                                      page: state.currentPage + 1,
                                      limit: 20));
                            }
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: BlocBuilder<AdminOrdersBloc, AdminOrdersState>(
                            builder: (context, state) {
                              if (state is AdminOrdersLoading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (state is AdminOrdersError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 40),
                                      Icon(Icons.error_outline,
                                          size: 48, color: Colors.red),
                                      const SizedBox(height: 16),
                                      Text(state.message,
                                          textAlign: TextAlign.center),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<AdminOrdersBloc>().add(
                                              AdminOrdersLoadEvent(
                                                  page: 1, limit: 20));
                                        },
                                        child: Text(AppLanguage.retry),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (state is AdminOrdersLoaded) {
                                if (state.orders.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppLanguage.noOrdersFound,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Table Header
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Text(
                                                    AppLanguage.orderNumber,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    AppLanguage.client,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    AppLanguage.status,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                  child: Text(
                                                    AppLanguage.actions,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 10,
                                                    ),
                                                    textAlign: TextAlign.start,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Orders List
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: state.orders.length,
                                            separatorBuilder:
                                                (context, index) => Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.12),
                                            ),
                                            itemBuilder: (context, index) {
                                              final order = state.orders[index];

                                              return _OrderRow(
                                                order: order,
                                                statusColor: _getStatusColor(
                                                    order.status),
                                                localizedStatus:
                                                    _getLocalizedStatus(
                                                        order.status),
                                                onView: () {
                                                  context.push(
                                                      '/admin/orders/${order.id}');
                                                },
                                                onIncrementStatus: () {
                                                  context
                                                      .read<AdminOrdersBloc>()
                                                      .add(
                                                        AdminOrdersIncrementStatusEvent(
                                                            order.id),
                                                      );
                                                },
                                              );
                                            },
                                          ),
                                          if (state.isLoadingMore)
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            80), // Padding for bottom nav bar
                                  ],
                                );
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final AdminOrder order;
  final Color statusColor;
  final String localizedStatus;
  final VoidCallback onView;
  final VoidCallback onIncrementStatus;

  const _OrderRow({
    required this.order,
    required this.statusColor,
    required this.localizedStatus,
    required this.onView,
    required this.onIncrementStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: [
          // Order Number
          SizedBox(
            width: 80,
            child: Text(
              order.orderNumber,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Client Name
          Expanded(
            flex: 2,
            child: SizedBox(
              width: 70,
              child: Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    localizedStatus,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // View Button
                InkWell(
                  onTap: onView,
                  child: Icon(
                    Icons.visibility_outlined,
                    size: 14,
                    color: AppColors.brandDeep,
                  ),
                ),
                const SizedBox(width: 8),
                // Increment Status Button
                if (!order.status.toLowerCase().contains('livré') &&
                    !order.status.toLowerCase().contains('delivered'))
                  InkWell(
                    onTap: onIncrementStatus,
                    child: Icon(
                      Icons.arrow_circle_up,
                      size: 14,
                      color: AppColors.brandDeep,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
