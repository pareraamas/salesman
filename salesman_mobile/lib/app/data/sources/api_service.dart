import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class ApiService extends GetxService {
  static const String _baseUrlKey = 'API_BASE_URL';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);
  static const Duration _sendTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  late final dio.Dio _dio;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token management
  String? _authToken;
  
  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<ApiService> init() async {
    try {
      await dotenv.load(fileName: '.env');
      
      _dio = dio.Dio(
        dio.BaseOptions(
          baseUrl: dotenv.get(_baseUrlKey, fallback: 'http://localhost:8000/api'),
          connectTimeout: _defaultTimeout,
          receiveTimeout: _receiveTimeout,
          sendTimeout: _sendTimeout,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          responseType: dio.ResponseType.json,
          validateStatus: (status) {
            return status! < 500; // Consider all status codes below 500 as valid
          },
        ),
      );

      // Add interceptors
      _addInterceptors();
      
      return this;
    } catch (e) {
      _logger.e('❌ Failed to initialize ApiService', error: e);
      rethrow;
    }
  }

  void _addInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
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
        onError: (dio.DioException e, handler) async {
          _logError(e);
          
          // Handle 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // TODO: Implement token refresh logic if needed
            // await _refreshToken();
            // return _retry(e.requestOptions);
          }
          
          return handler.next(e);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      dio.QueuedInterceptorsWrapper(
        onError: (dio.DioException error, handler) async {
          // Retry on network errors or 5xx server errors
          if (_shouldRetry(error)) {
            final retryCount = error.requestOptions.extra['retry'] ?? 0;
            if (retryCount < _maxRetries) {
              await Future.delayed(Duration(seconds: 1));
              error.requestOptions.extra['retry'] = retryCount + 1;
              _logger.w('🔄 Retry ${retryCount + 1}/$_maxRetries: ${error.requestOptions.uri}');
              return handler.resolve(await _dio.fetch(error.requestOptions));
            }
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  bool _shouldRetry(dio.DioException error) {
    return error.type == dio.DioExceptionType.connectionTimeout ||
        error.type == dio.DioExceptionType.receiveTimeout ||
        error.type == dio.DioExceptionType.sendTimeout ||
        (error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }

  void _logRequest(dio.RequestOptions options) {
    _logger.i(
      '🌐 [${options.method.toUpperCase()}] ${options.uri}',
    );
    _logger.d(
      '📤 Headers: ${jsonEncode(options.headers)}',
    );
    if (options.data != null) {
      _logger.d(
        '📦 Request Body: ${options.data is dio.FormData ? '[FormData]' : jsonEncode(options.data)}',
      );
    }
  }

  void _logResponse(dio.Response response) {
    _logger.i(
      '✅ [${response.statusCode}] ${response.requestOptions.uri}',
    );
    _logger.d(
      '📥 Response: ${jsonEncode(response.data)}',
    );
  }

  void _logError(dio.DioException error) {
    _logger.e(
      '❌ [${error.response?.statusCode}] ${error.requestOptions.uri}',
      error: error,
      stackTrace: error.stackTrace,
    );
    if (error.response != null) {
      _logger.d('❌ Error Response: ${error.response?.data}');
    }
  }

  // Helper method to handle error responses
  Map<String, dynamic> _handleError(dio.DioException e) {
    if (e.response != null) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      final statusCode = e.response?.statusCode;
      dynamic responseData = e.response?.data;
      
      // Log the error details
      _logger.e('Error Response:');
      _logger.e('Status: $statusCode');
      _logger.e('Data: $responseData');
      
      String message = 'An error occurred';
      Map<String, dynamic>? errors;
      
      try {
        if (responseData is Map) {
          message = responseData['message'] ?? 
                   responseData['error'] ?? 
                   'An error occurred';
          errors = responseData['errors'];
        } else if (responseData is String) {
          message = responseData.isNotEmpty ? responseData : message;
        }
        
        // Handle specific status codes
        switch (statusCode) {
          case 400:
            message = message.contains('Invalid credentials') 
                ? 'Email atau password salah' 
                : 'Permintaan tidak valid';
            break;
          case 401:
            message = 'Sesi telah berakhir, silakan login kembali';
            // TODO: Trigger logout flow
            break;
          case 403:
            message = 'Anda tidak memiliki izin untuk mengakses fitur ini';
            break;
          case 404:
            message = 'Data tidak ditemukan';
            break;
          case 422:
            message = 'Data yang dimasukkan tidak valid';
            break;
          case 500:
            message = 'Terjadi kesalahan pada server';
            break;
          default:
            message = message;
        }
      } catch (e) {
        _logger.e('Error parsing error response: $e');
      }
      
      return {
        'success': false,
        'message': message,
        'errors': errors,
        'statusCode': statusCode,
      };
    } else {
      // Something happened in setting up or sending the request
      String message = 'Tidak dapat terhubung ke server';
      
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout ||
          e.type == dio.DioExceptionType.sendTimeout) {
        message = 'Koneksi timeout, silakan coba lagi';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        message = 'Tidak ada koneksi internet';
      }
      
      _logger.e('Network Error: ${e.message}');
      
      return {
        'success': false,
        'message': message,
        'statusCode': 0,
      };
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // Download file
  Future<Map<String, dynamic>> download(
    String urlPath,
    dynamic savePath, {
    dio.ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    dio.CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = dio.Headers.contentLengthHeader,
    dynamic data,
    dio.Options? options,
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
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }
  
  // Upload file
  Future<Map<String, dynamic>> upload(
    String path, {
    required dio.FormData data,
    Map<String, dynamic>? queryParameters,
    dio.Options? options,
    dio.CancelToken? cancelToken,
    dio.ProgressCallback? onSendProgress,
    dio.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? dio.Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } on dio.DioException catch (e) {
      return _handleError(e);
    }
  }
}
