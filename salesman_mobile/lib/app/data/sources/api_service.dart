import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../models/app_response.dart';

// Re-export Dio types for easier access

class ApiService {
  static const String _baseUrlKey = 'BASE_URL';
  static const int _defaultTimeoutSeconds = 30;
  static const int _receiveTimeoutSeconds = 30;
  static const int _sendTimeoutSeconds = 30;
  static const Duration _defaultTimeout = Duration(seconds: _defaultTimeoutSeconds);
  static const Duration _receiveTimeout = Duration(seconds: _receiveTimeoutSeconds);
  static const Duration _sendTimeout = Duration(seconds: _sendTimeoutSeconds);
  static const int _maxRetries = 3;

  late final Dio _dio;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 50, colors: true, printEmojis: true));

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // Private constructor
  ApiService._internal() {
    _init();
  }

  // Initialize the service
  Future<void> init() async {
    await dotenv.load(fileName: '.env');
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get(_baseUrlKey, fallback: 'http://localhost:8000/api'),
        connectTimeout: _defaultTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );
    _addInterceptors();
  }

  // Token management
  String? _authToken;

  // Get authentication token
  String? get token => _authToken;

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Private method for internal initialization
  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.get(_baseUrlKey, fallback: 'http://localhost:8000/api'),
        connectTimeout: _defaultTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _sendTimeout,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        responseType: ResponseType.json,
        validateStatus: (status) => status! < 500,
      ),
    );
    _addInterceptors();
  }

  void _addInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if exists
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logError(e);

          // Handle 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // TODO: Implement token refresh logic here
            // For now, just pass the error through
          }

          return handler.next(e);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onError: (DioException error, handler) async {
          // Retry on network errors or 5xx server errors
          if (_shouldRetry(error)) {
            final retryCount = (error.requestOptions.extra['retry'] as int?) ?? 0;
            if (retryCount < _maxRetries) {
              error.requestOptions.extra['retry'] = retryCount + 1;
              final delaySeconds = 1 + retryCount;
              await Future.delayed(Duration(seconds: delaySeconds));
              return handler.resolve(
                await _dio.request(
                  error.requestOptions.path,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(method: error.requestOptions.method, headers: error.requestOptions.headers),
                ),
              );
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null && error.response!.statusCode! >= 500);
  }

  void _logRequest(RequestOptions options) {
    _logger.i('🌐 [${options.method.toUpperCase()}] ${options.uri}');
    _logger.d('📤 Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('📦 Request Body: ${options.data is FormData ? '[FormData]' : jsonEncode(options.data)}');
    }
  }

  void _logResponse(Response response) {
    _logger.i('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    _logger.d('📥 Response: ${jsonEncode(response.data)}');
  }

  void _logError(DioException error) {
    _logger.e('❌ [${error.response?.statusCode}] ${error.requestOptions.uri}', error: error, stackTrace: error.stackTrace);
    if (error.response?.data != null) {
      _logger.e('❌ Error Response: ${jsonEncode(error.response?.data)}');
    }
  }

  // Helper method to handle error responses
  AppResponse<T> _handleError<T>(DioException e) {
    _logger.e('API Error: ${e.message}');
    
    if (e.response != null) {
      _logger.e('Response data: ${e.response?.data}');
      _logger.e('Status code: ${e.response?.statusCode}');
      
      return AppResponse<T>(
        success: false,
        message: e.response?.data is Map 
          ? (e.response?.data as Map)['message']?.toString() 
          : 'An error occurred',
        statusCode: e.response?.statusCode,
        errors: e.response?.data is Map 
          ? (e.response?.data as Map)['errors'] as Map<String, dynamic>?
          : null,
      );
    } else {
      return AppResponse<T>(
        success: false,
        message: e.message ?? 'An unexpected error occurred',
        statusCode: 500,
      );
    }
  }

  // HTTP Methods
  Future<AppResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return AppResponse<T>.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {'data': response.data},
        fromJsonT: fromJsonT,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<AppResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return AppResponse<T>.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {'data': response.data},
        fromJsonT: fromJsonT,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<AppResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return AppResponse<T>.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {'data': response.data},
        fromJsonT: fromJsonT,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<AppResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return AppResponse<T>.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {'data': response.data},
        fromJsonT: fromJsonT,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<AppResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return AppResponse<T>.fromJson(
        response.data is Map ? response.data as Map<String, dynamic> : {'data': response.data},
        fromJsonT: fromJsonT,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Download file
  Future<AppResponse<void>> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );

      return AppResponse(
        success: true,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  // Upload file
  Future<AppResponse<T>> upload<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    T Function(dynamic json)? fromJsonT,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      final responseData = response.data;
      T? parsedData;
      
      if (fromJsonT != null && responseData != null) {
        try {
          parsedData = fromJsonT(responseData);
        } catch (e) {
          _logger.e('Error parsing response data: $e');
          return AppResponse<T>(
            success: false,
            message: 'Error parsing response data',
            statusCode: response.statusCode,
          );
        }
      }

      return AppResponse<T>(
        success: true,
        data: parsedData,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }
}
