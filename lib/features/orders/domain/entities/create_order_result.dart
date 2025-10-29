import 'order.dart';

/// Result of creating an order, which may include a checkout URL for online payments
class CreateOrderResult {
  final Order order;
  final String? checkoutUrl;

  CreateOrderResult({
    required this.order,
    this.checkoutUrl,
  });
}
