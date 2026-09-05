class AppConfig {
  AppConfig._();

  /// Set to true to bypass Firebase and AI API calls.
  /// Use this for rapid UI development and testing.
  static const bool useMockMode = true;

  /// Mock User Credentials
  static const String mockEmail = 'alyankhan12@gmail.com';
  static const String mockPassword = '123456';
}
