import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

class OrderTrackingPage extends StatelessWidget {
  final Order order;
  const OrderTrackingPage({Key? key, required this.order}) : super(key: key);

  static const Color _primary = Color(0xFFA7C957);
  static const Color _dark = Color(0xFF083B2E);
  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivering:
        return const Color(0xFF95A4FC);
      case OrderStatus.delivered:
        return const Color(0xFFA1E3CB);
      case OrderStatus.preparing:
        return const Color(0xFFB1E3FF);
      case OrderStatus.canceled:
        return const Color(0xFFF34141);
      case OrderStatus.confirmed:
        return const Color(0xFF95A4FC);
    }
  }

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
  // make connectors shorter and rely on no inter-step gap so they touch
  const connectorTopHeight = 12.0;
  const connectorBottomHeight = 12.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // left column: top connector + circle + bottom connector
        SizedBox(
          width: 56,
          child: Column(
            children: [
              // top connector (touches circle)
              if (showTopConnector) Container(width: connectorWidth, height: connectorTopHeight, color: const Color(0xFFE5E7EB)),
              Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(color: active ? _primary : const Color(0xFFE5E7EB), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: active ? Colors.white : Colors.grey.shade700),
              ),
              // bottom connector (touches circle)
              if (showBottomConnector) Container(width: connectorWidth, height: connectorBottomHeight, color: const Color(0xFFE5E7EB)),
            ],
          ),
        ),
  const SizedBox(width: 12),
        // center
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: active ? _dark : Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text(date, style: TextStyle(color: active ? _dark : Colors.grey.shade600, fontWeight: FontWeight.w400, fontSize: 13)),
          ]),
        ),
        // time (with AM/PM)
        Text(time, style: TextStyle(color: active ? _dark : Colors.grey.shade600, fontWeight: FontWeight.w400, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // For mock purposes we derive times from createdAt
  final created = order.createdAt;
  final confirmedDate = '${created.day} ${_month(created.month)} ${created.year}';
  final confirmedTime = _formatTime(created);

    // build a simple timeline ordering
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(width: 40, height: 40, alignment: Alignment.center, child: const Icon(Icons.arrow_back, color: _dark)),
                  ),
                  const Spacer(),
                  Text('Suivre Ma Commande', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _dark)),
                  const Spacer(flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Align(alignment: Alignment.centerLeft, child: Text('Commande #${order.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)))),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  children: [
                    _buildStep(active: true, icon: Icons.check, title: 'Commande confirmée', date: confirmedDate, time: confirmedTime, stepStatus: OrderStatus.confirmed, showTopConnector: false, showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(active: order.status == OrderStatus.preparing || order.status == OrderStatus.delivering || order.status == OrderStatus.delivered, icon: Icons.inventory_2_outlined, title: 'En préparation', date: confirmedDate, time: confirmedTime, stepStatus: OrderStatus.preparing, showTopConnector: true, showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(active: order.status == OrderStatus.delivering || order.status == OrderStatus.delivered, icon: Icons.local_shipping, title: 'En cours de livraison', date: confirmedDate, time: confirmedTime, stepStatus: OrderStatus.delivering, showTopConnector: true, showBottomConnector: true),
                    const SizedBox(height: 0),
                    _buildStep(active: order.status == OrderStatus.delivered, icon: Icons.mark_email_read, title: 'Livrée', date: confirmedDate, time: confirmedTime, stepStatus: OrderStatus.delivered, showTopConnector: true, showBottomConnector: false),
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
