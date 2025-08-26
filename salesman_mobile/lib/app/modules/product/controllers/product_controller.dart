import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/utils/validator/field_validator.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository;
  
  // Reactive variables
  final isLoading = false.obs;
  final products = <ProductModel>[].obs;
  final errorMessage = ''.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final searchQuery = ''.obs;
  final currentProduct = Rxn<ProductModel>();
  
  // Form controllers
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Constructor with dependency injection
  ProductController({required ProductRepository productRepository}) 
      : _productRepository = productRepository {
    // Initialize any necessary setup
    clearControllers();
  }
  
  // Clear all text controllers
  void clearControllers() {
    nameController.clear();
    codeController.clear();
    descriptionController.clear();
    priceController.clear();
    errorMessage.value = '';
    if (formKey.currentState != null) {
      formKey.currentState!.reset();
    }
  }

  Future<void> getProductById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _productRepository.getProductById(id);
      if (response.success && response.data != null) {
        currentProduct.value = response.data!;
        nameController.text = response.data!.name;
        codeController.text = response.data!.code;
        priceController.text = response.data!.price;
        descriptionController.text = response.data!.description ?? '';
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat data produk';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data produk: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(int id) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Create updated product with form data
      final updatedProduct = ProductModel(
        id: id,
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        price: priceController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
        // Preserve existing values for fields not in the form
        photoUrl: currentProduct.value?.photoUrl,
        photoPath: currentProduct.value?.photoPath,
        createdAt: currentProduct.value?.createdAt,
        updatedAt: currentProduct.value?.updatedAt,
        deletedAt: currentProduct.value?.deletedAt,
      );

      final response = await _productRepository.updateProduct(updatedProduct);
      
      if (response.success && response.data != null) {
        // Update the current product with the response data
        currentProduct.value = response.data!;
        
        // Show success message
        Get.snackbar(
          'Sukses',
          'Produk berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Close the update view after a short delay
        await Future.delayed(const Duration(seconds: 1));
        Get.back(result: true); // Pass true to indicate success
      } else {
        throw Exception(response.message ?? 'Gagal memperbarui produk');
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _productRepository.deleteProduct(id);
      
      if (response.success) {
        Get.back(); // Close any open dialogs
        
        // Show success message
        Get.snackbar(
          'Sukses',
          'Produk berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Navigate back to product list with refresh flag
        Get.until((route) => route.isFirst);
        Get.offNamed('/products', arguments: {'refresh': true});
      } else {
        errorMessage.value = response.message ?? 'Gagal menghapus produk';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat menghapus produk: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
  
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

  // Form validation
  String? validateName(String? value) {
    return FieldValidator.text(value ?? '', label: 'Nama produk')
        .required()
        .minLength(3, message: 'Nama produk minimal 3 karakter')
        .error;
  }

  String? validateCode(String? value) {
    return FieldValidator.text(value ?? '', label: 'Kode produk')
        .required()
        .minLength(2, message: 'Kode produk minimal 2 karakter')
        .error;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    final price = double.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    if (price == null || price <= 0) {
      return 'Masukkan harga yang valid';
    }
    return null;
  }


  // Create a new product from form data
  Future<void> submitProductForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final product = ProductModel(
        id: 0, // Will be set by the server
        name: nameController.text.trim(),
        code: codeController.text.trim(),
        price: double.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')).toString(),
        description: descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
        photoPath: null,
        photoUrl: null,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        deletedAt: null,
      );

      final response = await _productRepository.createProduct(product);
      
      if (response.success && response.data != null) {
        products.insert(0, response.data!);
        Get.back(result: true);
        Get.snackbar(
          'Sukses',
          'Produk berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = response.message ?? 'Gagal menambahkan produk';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
