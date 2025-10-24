import 'package:flutter/material.dart';
import '../../domain/entities/order.dart';

class OrderTrackingPage extends StatelessWidget {
  final Order order;
  const OrderTrackingPage({Key? key, required this.order}) : super(key: key);

  static const Color _primary = Color(0xFFA7C957);
  static const Color _dark = Color(0xFF083B2E);

  Widget _buildStep({required bool active, required IconData icon, required String title, required String date, required String time}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // left column: icon + connector
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: active ? _primary : const Color(0xFFE5E7EB), shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: active ? Colors.white : Colors.grey.shade700),
              ),
              const SizedBox(height: 6),
              // connector
              Container(width: 2, height: 32, color: const Color(0xFFE5E7EB)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // center
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: active ? _dark : Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text(date, style: TextStyle(color: active ? _dark : Colors.grey.shade600)),
          ]),
        ),
        // time
        Text(time, style: TextStyle(color: active ? _dark : Colors.grey.shade600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // For mock purposes we derive times from createdAt
    final created = order.createdAt;
    final confirmedDate = '${created.day} ${_month(created.month)} ${created.year}';
    final confirmedTime = '${created.hour}:${created.minute.toString().padLeft(2, '0')}';

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
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Align(alignment: Alignment.centerLeft, child: Text('Commande #${order.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _dark)))),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
                child: Column(
                  children: [
                    _buildStep(active: true, icon: Icons.check, title: 'Commande confirmée', date: confirmedDate, time: confirmedTime),
                    const SizedBox(height: 16),
                    _buildStep(active: order.status == OrderStatus.preparing || order.status == OrderStatus.delivering || order.status == OrderStatus.delivered, icon: Icons.inventory_2_outlined, title: 'En préparation', date: confirmedDate, time: confirmedTime),
                    const SizedBox(height: 16),
                    _buildStep(active: order.status == OrderStatus.delivering || order.status == OrderStatus.delivered, icon: Icons.local_shipping, title: 'En cours de livraison', date: confirmedDate, time: confirmedTime),
                    const SizedBox(height: 16),
                    _buildStep(active: order.status == OrderStatus.delivered, icon: Icons.mark_email_read, title: 'Livrée', date: confirmedDate, time: confirmedTime),
                    const SizedBox(height: 24),
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
}
