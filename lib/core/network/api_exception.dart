class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final dynamic serverResponse;

  ApiException(this.message, {this.statusCode, this.isNetworkError = false, this.serverResponse});

  @override
  String toString() => 'ApiException(status: $statusCode, network: $isNetworkError): $message | serverResponse: ${serverResponse ?? 'null'}';
}
