/// Configuration de l'API backend MyJalako.
///
/// Production : [productionBaseUrl]
/// Dev local : `flutter run --dart-define=API_BASE_URL=http://localhost:3001`
class ApiConfig {
  ApiConfig._();

  static const String productionBaseUrl = 'https://myjalako-backend.onrender.com';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return _stripTrailingSlash(override);
    return productionBaseUrl;
  }

  static String get authBaseUrl => '$baseUrl/api/auth';

  static String _stripTrailingSlash(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
