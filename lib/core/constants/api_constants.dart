/// Konfigurasi endpoint backend Contre Store.
/// Ubah [baseUrl] sesuai lingkungan pengujian.
class ApiConstants {
  ApiConstants._();

  /// Android Emulator -> http://10.0.2.2:5000
  /// HP fisik (satu jaringan WiFi) -> http://IP_KOMPUTER:5000
  /// Web/Desktop -> http://localhost:5000
  ///
  /// Saat build produksi, suntikkan alamat backend yang sudah online:
  ///   flutter build web --release --dart-define=API_BASE_URL=https://api-kamu
  /// Tanpa --dart-define, nilai bawaan di bawah dipakai (cukup untuk dev lokal).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

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