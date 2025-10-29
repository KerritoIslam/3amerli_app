import 'order_model.dart';
import '../../domain/entities/create_order_result.dart' as entity;

/// Result of creating an order, which may include a checkout URL for online payments
class CreateOrderResult {
  final OrderModel order;
  final String? checkoutUrl;

  CreateOrderResult({
    required this.order,
    this.checkoutUrl,
  });

  factory CreateOrderResult.fromJson(Map<String, dynamic> json) {
    // Handle response shape: { "order": {...}, "checkoutUrl": "..." }
    // or just the order itself: {...}
    if (json.containsKey('order')) {
      return CreateOrderResult(
        order: OrderModel.fromJson(Map<String, dynamic>.from(json['order'] as Map)),
        checkoutUrl: json['checkoutUrl']?.toString(),
      );
    }
    
    // If no nested 'order' key, treat entire json as order
    return CreateOrderResult(
      order: OrderModel.fromJson(json),
      checkoutUrl: json['checkoutUrl']?.toString(),
    );
  }

  entity.CreateOrderResult toEntity() {
    return entity.CreateOrderResult(
      order: order.toEntity(),
      checkoutUrl: checkoutUrl,
    );
  }
}
