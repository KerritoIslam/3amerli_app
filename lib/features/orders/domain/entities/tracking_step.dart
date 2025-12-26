import 'package:amerli_app/features/orders/domain/entities/order_status.dart';

class TrackingStep {
  final DateTime createdAt;
  final OrderStatus status;

  TrackingStep({required this.createdAt, required this.status});
}
