import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';
import 'package:salesman_mobile/app/data/sources/local_service.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo;

  AuthController({required AuthRepository authRepository}) : _authRepo = authRepository;

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // UI state
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Form validation errors
  final nameError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    // Periksa status login dari LocalService
    final isLoggedIn = await LocalService.isLoggedIn();
    if (isLoggedIn) {
      // Navigate to home if logged in
      Get.offAllNamed(Routes.HOME);
    }
  }

  // Login method
  Future<void> login() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final response = await _authRepo.login(emailController.text.trim(), passwordController.text);

      if (response.success) {
        // Simpan data user dan token ke local storage
        await LocalService.setLoggedIn(true);
        await LocalService.saveAuthToken(response.data?['token']);
        await LocalService.saveUserData(jsonEncode(response.data?['user']));

        // Navigate to home on success
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar('Login Gagal', response.message ?? 'Terjadi kesalahan saat login', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().contains('Exception: ') ? e.toString().split('Exception: ')[1] : 'Terjadi kesalahan. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register method
  Future<void> register() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar('Error', 'Konfirmasi password tidak cocok', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final response = await _authRepo.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (response.success) {
        // Navigate to home on success
        Get.offAllNamed(Routes.HOME);
      } else {
        // Show error message
        Get.snackbar('Registrasi Gagal', response.message ?? 'Registrasi gagal', backgroundColor: Colors.red, colorText: Colors.white);
        // Handle validation errors
        if (response.errors != null) {
          final errors = response.errors!;
          if (errors.containsKey('email')) {
            emailError.value = errors['email'] is List ? errors['email']![0].toString() : errors['email'].toString();
          }
          if (errors.containsKey('password')) {
            passwordError.value = errors['password'] is List ? errors['password']![0].toString() : errors['password'].toString();
          }
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
