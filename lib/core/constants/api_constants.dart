/// Konfigurasi endpoint backend Contre Store.
/// Ubah [baseUrl] sesuai lingkungan pengujian.
class ApiConstants {
  ApiConstants._();

  /// Android Emulator -> http://10.0.2.2:5000
  /// HP fisik (satu jaringan WiFi) -> http://IP_KOMPUTER:5000
  /// Web/Desktop -> http://localhost:5000
  static const String baseUrl = 'http://localhost:5000';

  static const String apiPrefix = '/api';

  // Auth
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String me = '$apiPrefix/auth/me';

  // Categories
  static const String categories = '$apiPrefix/categories';

  // Products
  static const String products = '$apiPrefix/products';

  // Upload
  static const String upload = '$apiPrefix/upload';

  // System
  static const String testDb = '$apiPrefix/test-db';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}