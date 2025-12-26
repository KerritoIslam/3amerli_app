import 'package:amerli_app/utils/constants/app_language.dart';

enum OrderStatus { confirmed, preparing, delivering, delivered, canceled }

extension OrderStatusX on OrderStatus {
  String get nameValue {
    switch (this) {
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.preparing:
        return 'PREPARING';
      case OrderStatus.delivering:
        return 'DELIVERING';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.canceled:
        return 'CANCELED';
    }
  }

  static OrderStatus fromString(String s) {
    switch (s.toUpperCase()) {
      case 'CONFIRMATION':
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARATION':
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'ON_DELIVERING':
      case 'DELIVERING':
        return OrderStatus.delivering;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
      case 'CANCELED':
        return OrderStatus.canceled;
      default:
        return OrderStatus.confirmed;
    }
  }

  /// Human-friendly label for display in the UI (French)
  String get displayLabel {
    switch (this) {
      case OrderStatus.confirmed:
        return AppLanguage.pending;
      case OrderStatus.preparing:
        return AppLanguage.statusPreparing;
      case OrderStatus.delivering:
        return AppLanguage.statusDelivering;
      case OrderStatus.delivered:
        return AppLanguage.delivered;
      case OrderStatus.canceled:
        return AppLanguage.cancelled;
    }
  }
}
