import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';

class ConsignmentCreateController extends GetxController {
  final ConsignmentRepository _consignmentRepo = Get.find<ConsignmentRepository>();
  final StoreRepository _storeRepo = Get.find<StoreRepository>();
  final ProductRepository _productRepo = Get.find<ProductRepository>();

  // Form controllers
  final formKey = GlobalKey<FormState>();
  final storeController = TextEditingController();
  final productController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // State
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<StoreModel?> selectedStore = Rx<StoreModel?>(null);
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadStores();
    loadProducts();
    startDateController.text = _formatDate(DateTime.now());
  }

  @override
  void onClose() {
    storeController.dispose();
    productController.dispose();
    quantityController.dispose();
    notesController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  Future<void> loadStores() async {
    try {
      final result = await _storeRepo.getStores();
      if (result.success && result.data != null) {
        stores.value = result.data!;
      }
    } catch (e) {
      print('Error loading stores: $e');
    }
  }

  Future<void> loadProducts() async {
    try {
      final result = await _productRepo.getProducts();
      if (result.success && result.data != null) {
        products.value = result.data!;
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void selectStore(StoreModel? store) {
    selectedStore.value = store;
    storeController.text = store?.name ?? '';
  }

  void selectProduct(ProductModel? product) {
    selectedProduct.value = product;
    productController.text = product?.name ?? '';
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate.value : endDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null) {
      if (isStartDate) {
        startDate.value = picked;
        startDateController.text = _formatDate(picked);
        // Reset end date if it's before start date
        if (endDate.value != null && endDate.value!.isBefore(picked)) {
          endDate.value = null;
          endDateController.text = '';
        }
      } else {
        if (picked.isAfter(startDate.value) || isSameDay(picked, startDate.value)) {
          endDate.value = picked;
          endDateController.text = _formatDate(picked);
        } else {
          Get.snackbar(
            'Error',
            'Tanggal selesai harus setelah atau sama dengan tanggal mulai',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void incrementQuantity() {
    quantity.value++;
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedStore.value == null || selectedProduct.value == null) {
      errorMessage.value = 'Harap pilih toko dan produk';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newConsignment = ConsignmentModel(
        id: 0, // ID akan diisi oleh server
        storeId: selectedStore.value!.id,
        code: '', // Kode akan di-generate oleh server
        status: 'pending',
        startDate: startDate.value,
        endDate: endDate.value,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        store: selectedStore.value,
        user: null, // Akan diisi oleh server
        items: [
          ConsignmentItemModel(
            id: 0, // ID akan diisi oleh server
            productId: selectedProduct.value!.id,
            quantity: quantity.value,
            product: selectedProduct.value,
          ),
        ],
      );

      final result = await _consignmentRepo.createConsignment(newConsignment);

      if (result.success && result.data != null) {
        Get.back(result: true); // Kembali ke halaman sebelumnya dengan status sukses
        Get.snackbar(
          'Sukses',
          'Konsinyasi berhasil dibuat',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = result.message ?? 'Gagal membuat konsinyasi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat membuat konsinyasi';
      print('Error creating consignment: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
