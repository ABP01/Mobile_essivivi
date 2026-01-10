import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/api_config.dart';

class ApiService {
  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for Auth Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from FlutterSecureStorage
          final token = await _storage.read(key: ApiConfig.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized - Token expired
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            _isRefreshing = true;
            
            try {
              // Try to refresh the token
              final refreshToken = await _storage.read(key: ApiConfig.refreshTokenKey);
              
              if (refreshToken != null) {
                final response = await _dio.post(
                  ApiConfig.tokenRefreshEndpoint,
                  data: {'refresh': refreshToken},
                  options: Options(
                    headers: {
                      'Authorization': null, // Don't send old token
                    },
                  ),
                );

                if (response.statusCode == 200) {
                  final newAccessToken = response.data['access'];
                  await _storage.write(
                    key: ApiConfig.accessTokenKey,
                    value: newAccessToken,
                  );

                  // Retry the original request with new token
                  e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  final cloneReq = await _dio.request(
                    e.requestOptions.path,
                    options: Options(
                      method: e.requestOptions.method,
                      headers: e.requestOptions.headers,
                    ),
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters,
                  );
                  
                  _isRefreshing = false;
                  return handler.resolve(cloneReq);
                }
              }
            } catch (refreshError) {
              // Refresh failed, clear tokens and redirect to login
              await _storage.delete(key: ApiConfig.accessTokenKey);
              await _storage.delete(key: ApiConfig.refreshTokenKey);
              await _storage.delete(key: ApiConfig.isAuthenticatedKey);
              _isRefreshing = false;
            }
            
            _isRefreshing = false;
          }
          
          return handler.next(e);
        },
        onResponse: (response, handler) {
          // Log responses in debug mode
          // print('Response [${response.statusCode}]: ${response.data}');
          return handler.next(response);
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // Only log in debug mode
          // print(obj);
        },
      ),
    );
  }

  Dio get client => _dio;

  /// Helper method to handle multipart file uploads
  Future<FormData> createFormData(Map<String, dynamic> data) async {
    final formData = FormData();
    
    data.forEach((key, value) {
      if (value is MultipartFile) {
        formData.files.add(MapEntry(key, value));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });
    
    return formData;
  }

  /// Helper method to create MultipartFile from file path
  Future<MultipartFile> createMultipartFile(String filePath) async {
    return await MultipartFile.fromFile(filePath);
  }
}
