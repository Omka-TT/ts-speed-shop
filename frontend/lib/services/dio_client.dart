import 'package:dio/dio.dart';

import 'auth_service.dart';

/// A single shared Dio instance configured for the backend API.
///
/// - Always attaches the current auth token (when available).
/// - Logs requests/responses for easier debugging.
/// - Uses a single interceptor chain so behavior is consistent.
class DioClient {
  DioClient._internal() {
    _dio = Dio(_baseOptions);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // The token should be kept in memory by AuthService and loaded early.
          final token = await AuthService.instance.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Token $token';
          } else {
            // For endpoints that require authentication, bail out early.
            final requiresAuth = options.extra['requiresAuth'] ?? true;
            if (requiresAuth) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: AuthException('Authentication token is missing. Please log in.'),
                  type: DioExceptionType.cancel,
                ),
              );
              return;
            }
          }

          print('[DioClient] ${options.method} ${options.uri}');
          handler.next(options);
        },
        onError: (DioException error, handler) {
          // Optional: Expand this to handle token refresh or global error handling.
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  static final DioClient _instance = DioClient._internal();

  static Dio get instance => _instance._dio;

  late final Dio _dio;

  static BaseOptions get _baseOptions => BaseOptions(
        baseUrl: 'http://127.0.0.1:8000/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      );
}
