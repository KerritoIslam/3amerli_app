import 'package:amerli_app/features/cart/domain/entities/cart_item.dart';

/// Payment methods supported by the API
enum PaymentMethod {
  cash('CASH'),
  epayment('EPAYMENT');

  final String value;
  const PaymentMethod(this.value);
}

/// Helper class to build order creation payload according to API spec
class OrderPayloadBuilder {
  /// Build order payload from cart items
  /// Either provide addressId (for existing address) or address map (for new address)
  /// Not both!
  static Map<String, dynamic> build({
    required List<CartItem> cartItems,
    required PaymentMethod paymentMethod,
    int? addressId,
    Map<String, dynamic>? address,
  }) {
    // Validate: either addressId OR address, not both
    if (addressId != null && address != null) {
      throw ArgumentError('Provide either addressId or address, not both');
    }
    if (addressId == null && address == null) {
      throw ArgumentError('Must provide either addressId or address');
    }

    // Build items array
    final items = cartItems.map((item) {
      return {
        'productId': int.tryParse(item.productId) ?? 0,
        'quantity': item.quantity,
      };
    }).toList();

    // Build payload
    final payload = <String, dynamic>{
      'items': items,
      'paymentWay': paymentMethod.value,
    };

    // Add either addressId or address
    if (addressId != null) {
      payload['addressId'] = addressId;
    } else if (address != null) {
      payload['address'] = address;
    }

    return payload;
  }

  /// Build address map from components
  static Map<String, dynamic> buildAddress({
    required String street,
    required String city,
    required String district,
  }) {
    return {
      'street': street,
      'city': city,
      'district': district,
    };
  }
}
