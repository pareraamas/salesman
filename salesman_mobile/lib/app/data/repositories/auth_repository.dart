import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/user_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 50, colors: true, printEmojis: true));

  /// Login with email and password
  Future<AppResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(ApiUrl.login, data: {'email': email, 'password': password});

      if (response.success && response.data != null) {
        final responseData = response.data!;
        final token = responseData['token'];

        // Set token after successful login
        if (token != null) {
          await _apiService.setAuthToken(token);
        }

        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {'user': UserModel.fromJson(responseData['user'] ?? responseData['data'] ?? {}), 'token': token},
          message: response.message,
        );
      }

      return AppResponse<Map<String, dynamic>>(success: false, message: response.message ?? 'Login gagal', errors: response.errors);
    } catch (e) {
      _logger.e('Login error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString().contains('Exception: ') ? e.toString().split('Exception: ')[1] : 'Terjadi kesalahan saat login',
      );
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _apiService.token;
    return token != null && token.isNotEmpty;
  }

  /// Register new user
  Future<AppResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiUrl.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      if (response.success && response.data != null) {
        final responseData = response.data!;
        final token = responseData['token'];

        // Set token after successful registration
        if (token != null) {
          await _apiService.setAuthToken(token);
        }

        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {'user': UserModel.fromJson(responseData['user'] ?? responseData), 'token': token},
          message: response.message,
        );
      }

      return AppResponse<Map<String, dynamic>>(success: false, message: response.message ?? 'Registrasi gagal', errors: response.errors);
    } catch (e) {
      _logger.e('Registration error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: e.toString().contains('Exception: ') ? e.toString().split('Exception: ')[1] : 'Terjadi kesalahan saat registrasi',
      );
    }
  }

  /// Logout user
  Future<AppResponse<void>> logout() async {
    try {
      final response = await _apiService.post<void>(ApiUrl.logout);

      // Clear token regardless of response
      await _apiService.clearAuthToken();

      if (response.success) {
        return AppResponse<void>(success: true, message: response.message);
      }

      return AppResponse<void>(success: false, message: response.message ?? 'Logout gagal');
    } catch (e) {
      _logger.e('Logout error: $e');
      // Still clear token even if there's an error
      await _apiService.clearAuthToken();

      return AppResponse<void>(success: false, message: 'Gagal logout. Silakan coba lagi.');
    }
  }

  /// Get current authenticated user
  Future<AppResponse<UserModel>> getUser() async {
    try {
      final token = await _apiService.token;
      if (token == null || token.isEmpty) {
        return AppResponse<UserModel>(
          success: false,
          message: 'Tidak ada token autentikasi',
        );
      }
      
      final response = await _apiService.get<Map<String, dynamic>>(ApiUrl.user);
      
      if (response.success && response.data != null) {
        return AppResponse<UserModel>(
          success: true,
          data: UserModel.fromJson(response.data!), 
          message: response.message,
        );
      }
      
      // Jika token tidak valid, bersihkan token
      if (response.statusCode == 401) {
        await _apiService.clearAuthToken();
      }
      
      return AppResponse<UserModel>(
        success: false,
        message: response.message ?? 'Gagal mengambil data pengguna',
        errors: response.errors,
      );
    } catch (e) {
      _logger.e('Get user error: $e');
      
      // Jika terjadi error karena token tidak valid, bersihkan token
      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        await _apiService.clearAuthToken();
      }
      
      return AppResponse<UserModel>(
        success: false,
        message: 'Terjadi kesalahan saat mengambil data pengguna: ${e.toString()}',
      );
    }
  }
}
