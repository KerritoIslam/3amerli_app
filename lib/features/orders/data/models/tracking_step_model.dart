import 'package:amerli_app/features/orders/domain/entities/tracking_step.dart';
import 'package:amerli_app/features/orders/domain/entities/order_status.dart';

class TrackingStepModel {
  final DateTime createdAt;
  final String status;

  TrackingStepModel({required this.createdAt, required this.status});

  factory TrackingStepModel.fromJson(Map<String, dynamic> json) {
    return TrackingStepModel(
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }

  TrackingStep toEntity() {
    return TrackingStep(
      createdAt: createdAt,
      status: _mapStatus(status),
    );
  }

  OrderStatus _mapStatus(String status) {
    switch (status) {
      case 'CONFIRMATION':
        return OrderStatus.confirmed;
      case 'PREPARATION':
        return OrderStatus.preparing;
      case 'ON_DELIVERING':
        return OrderStatus.delivering;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELED':
        return OrderStatus.canceled;
      default:
        return OrderStatus.confirmed;
    }
  }
}
