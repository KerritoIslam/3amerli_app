import 'package:amerli_app/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../domain/entities/order.dart';

class OrderTrackingPage extends StatelessWidget {
  final Order order;
  const OrderTrackingPage({super.key, required this.order});

  static const Color _primary = Color(0xFFA7C957);
  static const Color _dark = Color(0xFF083B2E);
  Widget _buildStep({
    required bool active,
    required IconData icon,
    required String title,
    required String date,
    required String time,
    required OrderStatus stepStatus,
    bool showTopConnector = true,
    bool showBottomConnector = true,
  }) {
    // Make circles bigger; diameter 44 (radius ~22)
    final circleSize = 44.0;
    // connector thickness and lengths
    const connectorWidth = 3.0;
    // increase connector lengths to create more spacing between states
    // keep inter-step SizedBox at 0 so connectors form a continuous line
    const connectorTopHeight = 24.0;
    const connectorBottomHeight = 24.0;

    // determine whether connectors should be shown as active (colored) based on current order.status
    int statusIndex(OrderStatus s) {
      switch (s) {
        case OrderStatus.confirmed:
          return 0;
        case OrderStatus.preparing:
          return 1;
        case OrderStatus.delivering:
          return 2;
        case OrderStatus.delivered:
          return 3;
        case OrderStatus.canceled:
          return -1; // canceled is special
      }
    }

    final stepIdx = statusIndex(stepStatus);
    final currentIdx = statusIndex(order.status);

    Color connectorColorTop() {
      if (!showTopConnector) return const Color(0xFFE5E7EB);
      // top connector (between stepIdx-1 and stepIdx) is active if we've reached at least this step
      if (currentIdx >= stepIdx) return AppColors.lightPrimary;
      return const Color(0xFFE5E7EB);
    }

    Color connectorColorBottom() {
      if (!showBottomConnector) return const Color(0xFFE5E7EB);
      // bottom connector (between stepIdx and stepIdx+1) is active if we've reached the next step
      if (currentIdx >= stepIdx + 1) return AppColors.lightPrimary;
      return const Color(0xFFE5E7EB);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // left column: top connector + circle + bottom connector
        SizedBox(
          width: 56,
          child: Column(
            children: [
              // top connector (touches circle)
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
              // bottom connector (touches circle)
              if (showBottomConnector)
                Container(
                    width: connectorWidth,
                    height: connectorBottomHeight,
                    color: connectorColorBottom()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // center
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
              Text(date,
                  style: TextStyle(
                      color: _dark, fontWeight: FontWeight.w400, fontSize: 13)),
          ]),
        ),
        // time (with AM/PM)
        if (active)
          Text(time,
              style: TextStyle(
                  color: _dark, fontWeight: FontWeight.w400, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // For mock purposes we derive times from createdAt
    final created = order.createdAt;
    final confirmedDate =
        '${created.day} ${_month(created.month)} ${created.year}';
    final confirmedTime = _formatTime(created);

    // build a simple timeline ordering
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icons/back_arrow.svg',
                        width: 16,
                        height: 16,
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
                  Text('Suivre \nMa Commande',
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
                    child: Text('Commande #${order.id}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _dark)))),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  children: [
                    _buildStep(
                        active: true,
                        icon: Icons.check,
                        title: OrderStatus.confirmed.displayLabel,
                        date: confirmedDate,
                        time: confirmedTime,
                        stepStatus: OrderStatus.confirmed,
                        showTopConnector: false,
                        showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(
                        active: order.status == OrderStatus.preparing ||
                            order.status == OrderStatus.delivering ||
                            order.status == OrderStatus.delivered,
                        icon: Icons.inventory_2_outlined,
                        title: OrderStatus.preparing.displayLabel,
                        date: confirmedDate,
                        time: confirmedTime,
                        stepStatus: OrderStatus.preparing,
                        showTopConnector: true,
                        showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(
                        active: order.status == OrderStatus.delivering ||
                            order.status == OrderStatus.delivered,
                        icon: Icons.local_shipping,
                        title: OrderStatus.delivering.displayLabel,
                        date: confirmedDate,
                        time: confirmedTime,
                        stepStatus: OrderStatus.delivering,
                        showTopConnector: true,
                        showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(
                        active: order.status == OrderStatus.delivered,
                        icon: Icons.mark_email_read,
                        title: OrderStatus.delivered.displayLabel,
                        date: confirmedDate,
                        time: confirmedTime,
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
    );
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:$minute $suffix';
  }
}
