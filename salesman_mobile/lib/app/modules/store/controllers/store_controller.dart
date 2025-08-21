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

  Future<void> fetchStores({bool loadMore = false}) async {
    try {
      if (isLoading.value) return;
      
      if (!loadMore) {
        currentPage.value = 1;
        hasMore.value = true;
        isLoading.value = true;
      } else {
        if (!hasMore.value) return;
        currentPage.value++;
      }
      
      final response = await _storeRepository.getStores(
        page: currentPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      
      if (response.success && response.data != null) {
        final newStores = response.data!;
        
        if (loadMore) {
          stores.addAll(newStores);
        } else {
          stores.assignAll(newStores);
        }
        
        // Check if there are more pages using the meta data
        if (response.meta != null) {
          hasMore.value = response.meta!.currentPage < response.meta!.lastPage;
        } else {
          hasMore.value = false;
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load stores';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshStores() async {
    await fetchStores(loadMore: false);
  }

  void searchStores(String query) {
    searchQuery.value = query;
    fetchStores(loadMore: false);
  }

  Future<StoreModel?> getStoreById(int id) async {
    try {
      final response = await _storeRepository.getStoreById(id);
      if (response.success && response.data != null) {
        return response.data;
      }
      errorMessage.value = response.message ?? 'Failed to load store';
      return null;
    } catch (e) {
      errorMessage.value = 'Error loading store: $e';
      return null;
    }
  }

  Future<bool> createStore(StoreModel store) async {
    try {
      final response = await _storeRepository.createStore(store);
      if (response.success) {
        await refreshStores();
        return true;
      }
      errorMessage.value = response.message ?? 'Failed to create store';
      return false;
    } catch (e) {
      errorMessage.value = 'Error creating store: $e';
      return false;
    }
  }

  Future<bool> updateStore(StoreModel store) async {
    try {
      final response = await _storeRepository.updateStore(store);
      if (response.success) {
        await refreshStores();
        return true;
      }
      errorMessage.value = response.message ?? 'Failed to update store';
      return false;
    } catch (e) {
      errorMessage.value = 'Error updating store: $e';
      return false;
    }
  }

  Future<bool> deleteStore(int id) async {
    try {
      final response = await _storeRepository.deleteStore(id);
      if (response.success) {
        await refreshStores();
        return true;
      }
      errorMessage.value = response.message ?? 'Failed to delete store';
      return false;
    } catch (e) {
      errorMessage.value = 'Error deleting store: $e';
      return false;
    }
  }
}
