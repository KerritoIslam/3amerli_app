import 'package:flutter/foundation.dart';
import 'constants/app_constants.dart';

/// Resolve an image reference returned by the backend into a usable URL.
/// Rules (conservative):
/// - If value already starts with http(s), return as-is.
/// - If it contains an internal host like `minio`, add https:// prefix if missing.
/// - Otherwise treat as a filename and build a fallback URL using the API origin:
///   origin + '/files/' + filename
String resolveImageUrl(String input) {
  final s = input.trim();
  if (s.isEmpty) return '';

  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) return s;

  // internal host like minio:9000 or host:port -> try to make it reachable by adding https://
  if (s.contains('minio') || s.contains(':')) {
    if (!s.startsWith('http')) return 'https://' + s;
    return s;
  }
  // protocol-relative URL like //host/path -> prefix https:
  if (s.startsWith('//')) return 'https:' + s;

  // If the path starts with '/', treat it as an absolute path on the API origin
  if (s.startsWith('/')) {
    try {
      final origin = Uri.parse(AppConstants.apiBaseUrl).origin;
      return origin + s;
    } catch (e) {
      return s;
    }
  }

  // fallback: we don't want to produce an invalid /files/<name> URL which
  // often returns 404 on servers that expect signed URLs. Return an empty
  // string so callers can show a local placeholder instead.
  // In debug builds, provide a helpful message.
  if (!kReleaseMode) {
    try {
      final origin = Uri.parse(AppConstants.apiBaseUrl).origin;
      // ignore: avoid_print
      print('[image_resolver] received filename "$s"; not building fallback $origin/files/$s to avoid 404; returning empty string');
    } catch (_) {}
  }
  return '';
}
