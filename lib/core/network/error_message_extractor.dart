/// Helper function to extract error message from server response
/// Falls back to a default message if the message field is not found
String extractErrorMessage(dynamic serverResponse,
    {String defaultMessage = 'Network error'}) {
  if (serverResponse == null) return defaultMessage;

  try {
    if (serverResponse is Map) {
      // Try to get 'message' field first
      if (serverResponse.containsKey('message') &&
          serverResponse['message'] != null) {
        return serverResponse['message'].toString();
      }
      // Try 'error' field as fallback
      if (serverResponse.containsKey('error') &&
          serverResponse['error'] != null) {
        return serverResponse['error'].toString();
      }
      // Try 'msg' field as another fallback
      if (serverResponse.containsKey('msg') && serverResponse['msg'] != null) {
        return serverResponse['msg'].toString();
      }
    }
  } catch (e) {
    // If parsing fails, return default message
    return defaultMessage;
  }

  return defaultMessage;
}
