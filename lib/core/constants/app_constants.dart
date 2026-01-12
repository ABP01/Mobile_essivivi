/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Essivi Water';
  static const String appVersion = '1.0.0';
  
  // Delivery Constants
  static const double deliveryFeePerKm = 500.0; // FCFA
  static const double bottleDeposit = 1000.0; // FCFA
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const Duration cacheValidity = Duration(minutes: 5);
  static const Duration longCacheValidity = Duration(hours: 1);
  
  // Maps
  static const double defaultLatitude = 6.1319; // Lomé, Togo
  static const double defaultLongitude = 1.2228;
  static const double defaultZoom = 13.0;
  
  // GPS Tracking
  static const Duration gpsUpdateInterval = Duration(seconds: 10);
  static const double gpsAccuracyThreshold = 50.0; // meters
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// Storage Keys for local persistence
class StorageKeys {
  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String isAuthenticated = 'is_authenticated';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userId = 'user_id';
  
  // Preferences
  static const String isDarkMode = 'isDarkMode';
  static const String languageCode = 'languageCode';
  static const String notifications = 'notifications';
  
  // Cache
  static const String cachedUserProfile = 'cached_user_profile';
  static const String cachedDeliveries = 'cached_deliveries';
  static const String cachedOrders = 'cached_orders';
  static const String lastSyncTime = 'last_sync_time';
  
  // Location
  static const String lastKnownLatitude = 'last_known_latitude';
  static const String lastKnownLongitude = 'last_known_longitude';
}
