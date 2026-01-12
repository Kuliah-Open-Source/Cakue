class AppConfig {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static String get baseUrl => _baseUrl;
  static String get apiUrl => '$_baseUrl/api';
  static bool get isDevelopment => _environment == 'development';
  static bool get isProduction => _environment == 'production';
  
  // API Endpoints
  static String get loginUrl => '$apiUrl/auth/login';
  static String get registerUrl => '$apiUrl/auth/register';
  static String get accountsUrl => '$apiUrl/accounts';
  static String get transactionsUrl => '$apiUrl/transactions';
  
  // App Settings
  static const int requestTimeout = 30; // seconds
  static const int maxRetries = 3;
}