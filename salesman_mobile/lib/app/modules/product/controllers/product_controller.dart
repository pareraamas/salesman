import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository;
  
  // Reactive variables
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final searchQuery = ''.obs;
  
  // Constructor with dependency injection
  ProductController({required ProductRepository productRepository}) 
      : _productRepository = productRepository;
  
  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }
  
  // Fetch products with pagination and search
  Future<void> fetchProducts({bool loadMore = false}) async {
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
      
      final response = await _productRepository.getProducts(
        page: currentPage.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      
      if (response.success && response.data != null) {
        final newProducts = response.data!;
        
        if (loadMore) {
          products.addAll(newProducts);
        } else {
          products.assignAll(newProducts);
        }
        
        // Check if there are more pages using the meta data
        if (response.meta != null) {
          hasMore.value = response.meta!.currentPage < response.meta!.lastPage;
        } else {
          hasMore.value = false;
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load products';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    fetchProducts();
  }
  
  // Refresh products
  Future<void> refreshProducts() async {
    await fetchProducts();
  }
}
