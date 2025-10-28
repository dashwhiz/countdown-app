/// API Configuration for backend integration
///
/// This file contains all API-related constants and configuration.
/// Update these values when backend is ready in Phase 2.
class AppApiConfig {
  AppApiConfig._();

  // ============================================================================
  // API Base URLs
  // ============================================================================

  /// Base URL for production API
  static const String productionBaseUrl = 'https://api.countdown.app/v1';

  /// Base URL for staging API
  static const String stagingBaseUrl = 'https://staging-api.countdown.app/v1';

  /// Base URL for development API
  static const String developmentBaseUrl = 'http://localhost:3000/v1';

  /// Current environment base URL
  /// TODO: Use environment variables or build flavors to determine this
  static const String baseUrl = developmentBaseUrl;

  // ============================================================================
  // API Endpoints
  // ============================================================================

  // Authentication endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authLogout = '/auth/logout';
  static const String authRefresh = '/auth/refresh';
  static const String authResetPassword = '/auth/reset-password';
  static const String authDeleteAccount = '/auth/account';

  // Events endpoints
  static const String events = '/events';
  static String eventById(String id) => '/events/$id';
  static String togglePinEvent(String id) => '/events/$id/pin';

  // User profile endpoints
  static const String profile = '/profile';
  static const String profileUpdate = '/profile';

  // Reactions endpoints
  static String eventReactions(String eventId) => '/events/$eventId/reactions';
  static String addReaction(String eventId) => '/events/$eventId/reactions';

  // Sharing endpoints
  static String shareEvent(String eventId) => '/events/$eventId/share';
  static String sharedEvent(String shareId) => '/shared/$shareId';

  // Pro/Subscription endpoints
  static const String proPurchase = '/pro/purchase';
  static const String proRestore = '/pro/restore';
  static const String proStatus = '/pro/status';

  // ============================================================================
  // API Configuration
  // ============================================================================

  /// API connection timeout in milliseconds
  static const int connectTimeout = 30000; // 30 seconds

  /// API receive timeout in milliseconds
  static const int receiveTimeout = 30000; // 30 seconds

  /// API send timeout in milliseconds
  static const int sendTimeout = 30000; // 30 seconds

  /// Maximum number of retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts in milliseconds
  static const int retryDelay = 1000; // 1 second

  // ============================================================================
  // API Headers
  // ============================================================================

  /// Content type header for JSON
  static const String contentTypeJson = 'application/json';

  /// Authorization header key
  static const String authorizationHeader = 'Authorization';

  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer';

  /// API version header
  static const String apiVersionHeader = 'X-API-Version';

  /// Current API version
  static const String apiVersion = '1.0';

  // ============================================================================
  // API Response Codes
  // ============================================================================

  /// Success response codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;

  /// Client error codes
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusTooManyRequests = 429;

  /// Server error codes
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  /// Get authorization header value with bearer token
  static Map<String, String> getAuthHeaders(String token) {
    return {
      authorizationHeader: '$bearerPrefix $token',
      'Content-Type': contentTypeJson,
      apiVersionHeader: apiVersion,
    };
  }

  /// Get default headers without authentication
  static Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': contentTypeJson,
      apiVersionHeader: apiVersion,
    };
  }

  /// Check if response code indicates success
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  /// Check if response code indicates client error
  static bool isClientErrorStatusCode(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  /// Check if response code indicates server error
  static bool isServerErrorStatusCode(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }
}
