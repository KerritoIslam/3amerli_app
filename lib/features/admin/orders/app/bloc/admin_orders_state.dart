import '../../domain/entities/admin_order.dart';

abstract class AdminOrdersState {}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<AdminOrder> orders;
  final String? query;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final String? message;
  final bool isIncrementing;
  final String? errorMessage;

  AdminOrdersLoaded(
    this.orders, {
    this.query,
    this.hasMore = true,
    this.currentPage = 1,
    this.isLoadingMore = false,
    this.message,
    this.isIncrementing = false,
    this.errorMessage,
  });

  AdminOrdersLoaded copyWith({
    List<AdminOrder>? orders,
    String? query,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    String? message,
    bool? isIncrementing,
    String? errorMessage,
  }) {
    return AdminOrdersLoaded(
      orders ?? this.orders,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message,
      isIncrementing: isIncrementing ?? this.isIncrementing,
      errorMessage: errorMessage,
    );
  }
}

class AdminOrderDetailLoading extends AdminOrdersState {}

class AdminOrderDetailLoaded extends AdminOrdersState {
  final AdminOrder order;
  final String? message;
  final bool isIncrementing;
  final String? errorMessage;

  AdminOrderDetailLoaded(
    this.order, {
    this.message,
    this.isIncrementing = false,
    this.errorMessage,
  });

  AdminOrderDetailLoaded copyWith({
    AdminOrder? order,
    String? message,
    bool? isIncrementing,
    String? errorMessage,
  }) {
    return AdminOrderDetailLoaded(
      order ?? this.order,
      message: message,
      isIncrementing: isIncrementing ?? this.isIncrementing,
      errorMessage: errorMessage,
    );
  }
}

class AdminOrdersError extends AdminOrdersState {
  final String message;

  AdminOrdersError(this.message);
}

class AdminOrdersOperationSuccess extends AdminOrdersState {
  final String message;

  AdminOrdersOperationSuccess(this.message);
}
