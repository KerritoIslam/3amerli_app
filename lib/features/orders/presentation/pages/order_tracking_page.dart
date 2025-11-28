import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:amerli_app/utils/constants/app_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../domain/entities/order.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../orders/app/bloc/orders_bloc.dart';
import '../../../orders/app/bloc/orders_event.dart';
import '../../../orders/app/bloc/orders_state.dart';
import 'package:amerli_app/features/orders/domain/entities/tracking_step.dart';
import 'package:amerli_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:amerli_app/core/config/injection.dart';

class OrderTrackingPage extends StatefulWidget {
  final Order order;
  const OrderTrackingPage({super.key, required this.order});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  late Order _order;
  List<TrackingStep>? _trackingSteps;
  bool _isLoading = true;
  static const Color _primary = Color(0xFFA7C957);
  static const Color _dark = Color(0xFF083B2E);

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchTracking();
  }

  Future<void> _fetchTracking() async {
    try {
      final steps = await sl<OrdersRepository>().fetchTracking(_order.id);
      if (mounted) {
        setState(() {
          _trackingSteps = steps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required OrderStatus stepStatus,
    bool showTopConnector = true,
    bool showBottomConnector = true,
  }) {
    // Find if this step exists in the tracking history
    final step = _trackingSteps?.firstWhere(
      (s) => s.status == stepStatus,
      orElse: () => TrackingStep(
          createdAt: DateTime(1900), status: OrderStatus.confirmed), // dummy
    );

    // Check if step is valid (not dummy)
    final bool active = step != null && step.createdAt.year != 1900;

    // For connectors:
    // Top connector is active if THIS step is active
    // Bottom connector is active if NEXT step is active

    // Define the sequence
    final sequence = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.delivering,
      OrderStatus.delivered
    ];

    final currentIndex = sequence.indexOf(stepStatus);
    final nextStatus =
        currentIndex < sequence.length - 1 ? sequence[currentIndex + 1] : null;

    final nextStep = nextStatus != null
        ? _trackingSteps?.firstWhere(
            (s) => s.status == nextStatus,
            orElse: () => TrackingStep(
                createdAt: DateTime(1900), status: OrderStatus.confirmed),
          )
        : null;

    final bool nextActive = nextStep != null && nextStep.createdAt.year != 1900;

    final circleSize = 44.0;
    const connectorWidth = 3.0;
    const connectorTopHeight = 24.0;
    const connectorBottomHeight = 24.0;

    Color connectorColorTop() {
      if (!showTopConnector) return const Color(0xFFE5E7EB);
      return active ? AppColors.lightPrimary : const Color(0xFFE5E7EB);
    }

    Color connectorColorBottom() {
      if (!showBottomConnector) return const Color(0xFFE5E7EB);
      return nextActive ? AppColors.lightPrimary : const Color(0xFFE5E7EB);
    }

    String dateStr = '';
    String timeStr = '';

    if (active) {
      final dt = step.createdAt;
      dateStr = '${dt.day} ${_month(dt.month)} ${dt.year}';
      timeStr = _formatTime(dt);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 56,
          child: Column(
            children: [
              if (showTopConnector)
                Container(
                    width: connectorWidth,
                    height: connectorTopHeight,
                    color: connectorColorTop()),
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                    color: active ? _primary : const Color(0xFFE5E7EB),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    size: 20,
                    color: active ? Colors.white : Colors.grey.shade700),
              ),
              if (showBottomConnector)
                Container(
                    width: connectorWidth,
                    height: connectorBottomHeight,
                    color: connectorColorBottom()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: active ? _dark : Colors.grey.shade700)),
            const SizedBox(height: 6),
            if (active)
              Text(dateStr,
                  style: TextStyle(
                      color: _dark, fontWeight: FontWeight.w400, fontSize: 13)),
          ]),
        ),
        if (active)
          Text(timeStr,
              style: TextStyle(
                  color: _dark, fontWeight: FontWeight.w400, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrdersLoaded) {
          try {
            final updated = state.items.firstWhere((o) => o.id == _order.id);
            setState(() {
              _order = updated;
            });
          } catch (_) {}
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<OrdersBloc>().add(OrdersLoadEvent());
              await _fetchTracking();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/back_arrow.svg',
                            width: 16,
                            height: 16,
                            matchTextDirection: true,
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).colorScheme.onPrimary,
                                BlendMode.srcIn),
                            placeholderBuilder: (context) => Icon(
                              Icons.arrow_back,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(AppLanguage.trackMyOrder,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _dark)),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${AppLanguage.orderNumberPrefix}${_order.id}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _dark)))),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12),
                          child: Column(
                            children: [
                              _buildStep(
                                  icon: Icons.check,
                                  title: OrderStatus.confirmed.displayLabel,
                                  stepStatus: OrderStatus.confirmed,
                                  showTopConnector: false,
                                  showBottomConnector: true),
                              const SizedBox(height: 0),
                              _buildStep(
                                  icon: Icons.inventory_2_outlined,
                                  title: OrderStatus.preparing.displayLabel,
                                  stepStatus: OrderStatus.preparing,
                                  showTopConnector: true,
                                  showBottomConnector: true),
                              const SizedBox(height: 0),
                              _buildStep(
                                  icon: Icons.local_shipping,
                                  title: OrderStatus.delivering.displayLabel,
                                  stepStatus: OrderStatus.delivering,
                                  showTopConnector: true,
                                  showBottomConnector: true),
                              const SizedBox(height: 0),
                              _buildStep(
                                  icon: Icons.mark_email_read,
                                  title: OrderStatus.delivered.displayLabel,
                                  stepStatus: OrderStatus.delivered,
                                  showTopConnector: true,
                                  showBottomConnector: false),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _month(int m) {
    final months = [
      AppLanguage.jan,
      AppLanguage.feb,
      AppLanguage.mar,
      AppLanguage.apr,
      AppLanguage.may,
      AppLanguage.jun,
      AppLanguage.jul,
      AppLanguage.aug,
      AppLanguage.sep,
      AppLanguage.oct,
      AppLanguage.nov,
      AppLanguage.dec
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? AppLanguage.pm : AppLanguage.am;
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:$minute $suffix';
  }
}
