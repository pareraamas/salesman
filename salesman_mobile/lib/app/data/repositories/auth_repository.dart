import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiUrl.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response['success'] == true) {
        final responseData = response['data'] is Map ? response['data'] : response;
        
        // Set token after successful login
        if (responseData['token'] != null) {
          _apiService.setAuthToken(responseData['token']);
        }
        
        return {
          'success': true,
          'data': UserModel.fromJson(responseData['user'] ?? responseData['data']),
          'token': responseData['token'],
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Login gagal',
        'errors': response['errors'],
      };
    } catch (e) {
      _logger.e('Login error: $e');
      return {
        'success': false,
        'message': e.toString().contains('Exception: ') 
            ? e.toString().split('Exception: ')[1] 
            : 'Terjadi kesalahan saat login',
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiUrl.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': 'salesman',
        },
      );
      
      final responseData = response['data'] is Map ? response['data'] : response;
      
      if (response['success'] == true) {
        // Set token after successful registration
        if (responseData['token'] != null) {
          _apiService.setAuthToken(responseData['token']);
        }
        
        return {
          'success': true,
          'data': UserModel.fromJson(responseData['user'] ?? responseData),
          'token': responseData['token'],
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Registrasi gagal',
        'errors': response['errors'],
      };
    } catch (e) {
      _logger.e('Registration error: $e');
      return {
        'success': false,
        'message': e.toString().contains('Exception: ') 
            ? e.toString().split('Exception: ')[1] 
            : 'Terjadi kesalahan saat registrasi',
      };
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(ApiUrl.logout);
      
      // Clear token regardless of response
      _apiService.setAuthToken(null);
      
      if (response['success'] == true) {
        return {'success': true};
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Logout gagal',
      };
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear token even if there's an error
      _apiService.setAuthToken(null);
      
      return {
        'success': false,
        'message': 'Gagal logout. Silakan coba lagi.',
      };
    }
  }

  /// Get current authenticated user
  Future<Map<String, dynamic>> getUser() async {
    try {
      final response = await _apiService.get(ApiUrl.user);
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': UserModel.fromJson(response['data'] is Map ? response['data'] : response),
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Gagal mengambil data pengguna',
      };
    } catch (e) {
      _logger.e('Get user error: $e');
      return {
        'success': false,
        'message': 'Tidak dapat memuat data pengguna',
      };
    }
  }
}
