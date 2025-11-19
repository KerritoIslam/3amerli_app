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
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'DELIVERING':
        return OrderStatus.delivering;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELED':
      case 'CANCELLED':
        return OrderStatus.canceled;
      default:
        return OrderStatus.confirmed;
    }
  }

  /// Human-friendly label for display in the UI (French)
  String get displayLabel {
    switch (this) {
      case OrderStatus.confirmed:
        return 'En attente';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.delivering:
        return 'En livraison';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.canceled:
        return 'Annulée';
    }
  }
}
