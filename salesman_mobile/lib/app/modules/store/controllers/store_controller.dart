import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';

class StoreController extends GetxController {
  final StoreRepository _storeRepository;
  
  // Reactive variables
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;

  StoreController({required StoreRepository storeRepository}) 
      : _storeRepository = storeRepository;

  @override
  void onInit() {
    super.onInit();
    fetchStores();
  }

  // Fetch stores from API
  Future<void> fetchStores({bool loadMore = false}) async {
    try {
      // Prevent multiple simultaneous requests
      if (isLoading.value) return;
      
      if (!loadMore) {
        // Reset state for new search/refresh
        currentPage.value = 1;
        hasMore.value = true;
        isLoading.value = true;
        errorMessage.value = '';
        stores.clear();
      } else {
        // Don't load more if no more items or already loading
        if (!hasMore.value || isLoading.value) return;
        currentPage.value++;
      }
      
      isLoading.value = true;
      
      // Call repository to fetch stores
      final response = await _storeRepository.getStores(
        page: currentPage.value,
        perPage: 10, // Default items per page
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      
      if (response.success && response.data != null) {
        final newStores = response.data!;
        
        // Check if there are more items to load
        hasMore.value = newStores.length >= 10; // Assuming 10 items per page
        
        if (loadMore) {
          // Append new stores for infinite scroll
          stores.addAll(newStores);
        } else {
          stores.assignAll(newStores);
        }
        
        // Check if there are more pages using the meta data
        if (response.meta != null) {
          hasMore.value = response.meta!.currentPage < response.meta!.lastPage;
        } else {
          hasMore.value = newStores.isNotEmpty; // If no meta, assume there are more if we got items
        }
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat data toko';
        if (!loadMore) {
          Get.snackbar('Error', errorMessage.value);
        }
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStores() async {
    await fetchStores();
  }

  Future<void> searchStores(String query) async {
    searchQuery.value = query.trim();
    await fetchStores();
  }

  /// Get store details by ID
  Future<StoreModel?> getStoreById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _storeRepository.getStoreById(id);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat detail toko';
        Get.snackbar('Error', errorMessage.value);
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Error loading store: $e';
      Get.snackbar('Error', errorMessage.value);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createStore(StoreModel store) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _storeRepository.createStore(store);
      
      if (response.success) {
        await refreshStores();
        Get.snackbar('Sukses', response.message ?? 'Toko berhasil ditambahkan',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      }
      
      errorMessage.value = response.message ?? 'Gagal menambahkan toko';
      if (response.errors != null && response.errors!.isNotEmpty) {
        errorMessage.value += '\n${response.errors!.values.first.join('\n')}';
      }
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStore(StoreModel store) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _storeRepository.updateStore(store);
      
      if (response.success) {
        await refreshStores();
        Get.snackbar('Sukses', response.message ?? 'Data toko berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      }
      
      errorMessage.value = response.message ?? 'Gagal memperbarui data toko';
      if (response.errors != null && response.errors!.isNotEmpty) {
        errorMessage.value += '\n${response.errors!.values.first.join('\n')}';
      }
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteStore(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Hapus Toko'),
          content: const Text('Apakah Anda yakin ingin menghapus toko ini? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      
      if (confirm != true) return false;
      
      final response = await _storeRepository.deleteStore(id);
      
      if (response.success) {
        await refreshStores();
        Get.snackbar('Sukses', response.message ?? 'Toko berhasil dihapus',
            snackPosition: SnackPosition.BOTTOM);
        return true;
      }
      
      errorMessage.value = response.message ?? 'Gagal menghapus toko';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar('Error', errorMessage.value,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
