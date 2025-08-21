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
  
  // Form controllers
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Constructor with dependency injection
  ProductController({required ProductRepository productRepository}) 
      : _productRepository = productRepository;

  @override
  void onClose() {
    nameController.dispose();
    skuController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
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

  String? validateSku(String? value) {
    return FieldValidator.text(value ?? '', label: 'SKU')
        .required()
        .minLength(3, message: 'SKU minimal 3 karakter')
        .error;
  }

  String? validatePrice(String? value) {
    final numericValue = value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0';
    return FieldValidator.number(numericValue, label: 'Harga')
        .requiredNumber()
        .minValue(1, message: 'Harga harus lebih dari 0')
        .error;
  }

  String? validateStock(String? value) {
    return FieldValidator.number(value ?? '0', label: 'Stok')
        .requiredNumber()
        .minValue(0, message: 'Stok tidak boleh kurang dari 0')
        .error;
  }

  // Create a new product from form data
  Future<void> submitProductForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      
      final product = ProductModel(
        id: 0, // Will be set by the server
        name: nameController.text.trim(),
        sku: skuController.text.trim(),
        description: descriptionController.text.trim().isNotEmpty 
            ? descriptionController.text.trim() 
            : null,
        price: double.parse(priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        stock: int.parse(stockController.text),
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
