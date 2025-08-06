import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  AuthController get controller => Get.find<AuthController>(tag: 'register');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.offNamed(Routes.LOGIN)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo
              // Image.asset('assets/images/logo.png', height: 100, fit: BoxFit.contain),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Buat Akun Baru',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Isi data diri Anda untuk mendaftar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Name Field
              Obx(
                () => TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: controller.nameError.value.isNotEmpty ? controller.nameError.value : null,
                  ),
                  onChanged: (_) => controller.nameError.value = '',
                ),
              ),
              const SizedBox(height: 16),
              // Email Field
              Obx(
                () => TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: controller.emailError.value.isNotEmpty ? controller.emailError.value : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => controller.emailError.value = '',
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              Obx(
                () => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: controller.passwordError.value.isNotEmpty ? controller.passwordError.value : null,
                  ),
                  obscureText: !controller.isPasswordVisible.value,
                  onChanged: (_) => controller.passwordError.value = '',
                ),
              ),
              const SizedBox(height: 16),
              // Confirm Password Field
              Obx(
                () => TextFormField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isConfirmPasswordVisible.value ? Icons.visibility_off : Icons.visibility),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    errorText: controller.confirmPasswordError.value.isNotEmpty ? controller.confirmPasswordError.value : null,
                  ),
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  onChanged: (_) => controller.confirmPasswordError.value = '',
                ),
              ),
              const SizedBox(height: 24),
              // Register Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.register(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : const Text('DAFTAR'),
                ),
              ),
              const SizedBox(height: 16),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  TextButton(onPressed: () => Get.offNamed(Routes.LOGIN), child: const Text('Masuk')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
