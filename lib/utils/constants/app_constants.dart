class AppConstants {
  static const String appName = '3amerli';
  // Base API endpoint used by Dio. Update this to match your backend host.
  // Tips:
  // - Traefik (Docker): backend is exposed on port 80; routes work without a version prefix.
  //   Default desktop/dev:        http://localhost
  // - Android emulator:           http://10.0.2.2
  // - iOS simulator:              http://localhost
  // - Physical device on same Wi‑Fi: use your PC IPv4, e.g., http://192.168.15.181
  // CURRENT: Targeting a physical Android device on your Wi‑Fi
  // Updated to the endpoint used by the recent automated tests
  // Keep the API base URL to the host/origin only; repository code uses '/api/v1/...' paths.
  // This prevents the accidental double prefix when concatenating paths.
  static const String apiBaseUrl = 'http://api.ammerli.com/api/v1/';
}
