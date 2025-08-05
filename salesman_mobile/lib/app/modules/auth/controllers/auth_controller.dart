import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password tidak boleh kosong',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      final response = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (response['success'] == true) {
        // Simpan token dan user data ke local storage
        // await _authStorage.saveToken(response['token']);
        // await _authStorage.saveUser(response['data']);
        
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Terjadi kesalahan saat login',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Silakan coba lagi nanti.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }
}
