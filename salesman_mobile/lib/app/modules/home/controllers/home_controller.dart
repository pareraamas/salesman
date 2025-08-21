import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';
import 'package:salesman_mobile/app/data/sources/local_service.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthRepository authRepository;

  HomeController({required this.authRepository});

  final RxInt currentIndex = 0.obs;
  final RxBool isLoading = false.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Melakukan proses logout dengan membersihkan session dan data lokal
  Future<void> logout() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      // 1. Lakukan API call untuk logout (jika diperlukan)
      try {
        await authRepository.logout();
      } catch (e) {
        // Tetap lanjut ke langkah berikutnya meskipun API gagal
        log('⚠️ [HomeController] Gagal melakukan API logout: $e', 
           name: 'AUTH',
           error: e);
      }
      
      // 2. Hapus semua data dari local storage
      await LocalService.clearAll();
      
      // 3. Reset state controller
      currentIndex.value = 0;
      
      // 4. Navigasi ke halaman login
      await Get.offAllNamed(Routes.LOGIN);
      
    } catch (e, stackTrace) {
      log('❌ [HomeController] Error saat logout', 
         name: 'AUTH', 
         error: e,
         stackTrace: stackTrace);
         
      Get.snackbar(
        'Gagal Logout',
        'Terjadi kesalahan saat mencoba logout. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (isLoading.isTrue) {
        isLoading.value = false;
      }
    }
  }
}
