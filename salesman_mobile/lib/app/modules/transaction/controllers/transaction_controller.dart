import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/models/transaction_item_model.dart';
import 'package:salesman_mobile/app/data/models/transaction_model.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';
import 'package:salesman_mobile/app/data/repositories/transaction_repository.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class TransactionController extends GetxController {
  final TransactionRepository _transactionRepository;
  final StoreRepository _storeRepository;
  final ProductRepository _productRepository;
  final ConsignmentRepository _consignmentRepository;
  
  // State
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt perPage = 15.obs;
  final RxBool hasMore = true.obs;
  
  // Filters
  final RxString searchQuery = ''.obs;
  final RxString statusFilter = ''.obs;
  final RxInt storeIdFilter = 0.obs;
  final RxInt consignmentIdFilter = 0.obs;
  final RxString startDateFilter = ''.obs;
  final RxString endDateFilter = ''.obs;
  
  // Transaction Creation
  final RxList<TransactionItemModel> transactionItems = <TransactionItemModel>[].obs;
  final RxList<StoreModel> stores = <StoreModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final Rx<StoreModel?> selectedStore = Rx<StoreModel?>(null);
  final Rx<ConsignmentModel?> selectedConsignment = Rx<ConsignmentModel?>(null);
  final RxList<ConsignmentModel> availableConsignments = <ConsignmentModel>[].obs;
  final Rx<DateTime> transactionDate = DateTime.now().obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble tax = 0.0.obs;
  final RxDouble total = 0.0.obs;
  final TextEditingController discountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  
  // Getters
  double get taxRate => 0.1; // 10% tax rate
  
  // Computed
  RxDouble get calculatedTax => (subtotal.value * taxRate).obs;
  RxDouble get calculatedTotal => (subtotal.value + calculatedTax.value - discount.value).obs;

  TransactionController({
    required TransactionRepository transactionRepository,
    required StoreRepository storeRepository,
    required ProductRepository productRepository,
    required ConsignmentRepository consignmentRepository,
  })  : _transactionRepository = transactionRepository,
        _storeRepository = storeRepository,
        _productRepository = productRepository,
        _consignmentRepository = consignmentRepository;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    _loadStores();
    _loadProducts();
    _loadConsignments();
    
    // Listen to changes in transaction items to update totals
    ever(transactionItems, (_) => _calculateTotals());
    
    // Listen to changes in discount
    debounce(discount, (_) => _calculateTotals(),
        time: const Duration(milliseconds: 500));
  }
  
  @override
  void onClose() {
    discountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> fetchTransactions({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
      } else {
        if (currentPage.value >= totalPages.value || isLoading.value) return;
        currentPage.value++;
      }

      errorMessage.value = '';
      
      final response = await _transactionRepository.getTransactions(
        page: currentPage.value,
        limit: perPage.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        status: statusFilter.value.isNotEmpty ? statusFilter.value : null,
        storeId: storeIdFilter.value > 0 ? storeIdFilter.value : null,
        consignmentId: consignmentIdFilter.value > 0 ? consignmentIdFilter.value : null,
        startDate: startDateFilter.value.isNotEmpty ? startDateFilter.value : null,
        endDate: endDateFilter.value.isNotEmpty ? endDateFilter.value : null,
      );

      if (response.success && response.data != null) {
        final newTransactions = (response.data!['transactions'] as List<TransactionModel>);
        
        if (loadMore) {
          transactions.addAll(newTransactions);
        } else {
          transactions.value = newTransactions;
        }
        
        final pagination = response.data!['pagination'] as Map<String, dynamic>;
        totalPages.value = pagination['last_page'] ?? 1;
        hasMore.value = (pagination['current_page'] ?? 1) < (pagination['last_page'] ?? 1);
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat data transaksi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memuat data transaksi';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    await fetchTransactions();
  }
  
  Future<void> _loadStores() async {
    try {
      final response = await _storeRepository.getStores();
      if (response.success && response.data != null) {
        stores.value = response.data!;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat daftar toko';
    }
  }
  
  Future<void> _loadProducts() async {
    try {
      final response = await _productRepository.getProducts();
      if (response.success && response.data != null) {
        products.value = response.data!;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat daftar produk';
    }
  }

  Future<void> _loadConsignments() async {
    try {
      final response = await _consignmentRepository.getConsignments(
        status: 'active', // Only load active consignments
        storeId: selectedStore.value?.id,
      );
      
      if (response.success && response.data != null) {
        availableConsignments.value = (response.data!['consignments'] as List).cast<ConsignmentModel>();
        
        // Auto-select consignment if there's only one
        if (availableConsignments.length == 1) {
          selectedConsignment.value = availableConsignments.first;
        } else {
          selectedConsignment.value = null;
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat daftar konsinyasi';
    }
  }
  
  // Update available consignments when store changes
  void onStoreChanged(StoreModel? store) {
    selectedStore.value = store;
    selectedConsignment.value = null;
    _loadConsignments();
  }
  
  // Transaction Item Management
  Future<void> addTransactionItem({
    required ProductModel product,
    required int quantity,
    required double price,
  }) async {
    try {
      final item = TransactionItemModel(
        id: 0, // Temporary ID
        transactionId: 0, // Will be set when creating transaction
        productId: product.id,
        product: product,
        quantity: quantity,
        price: price,
        subtotal: price * quantity,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      transactionItems.add(item);
      _calculateTotals();
    } catch (e) {
      errorMessage.value = 'Gagal menambahkan item: $e';
      rethrow;
    }
  }
  
  Future<void> updateTransactionItem({
    required int index,
    required ProductModel product,
    required int quantity,
    required double price,
  }) async {
    try {
      if (index >= 0 && index < transactionItems.length) {
        final item = transactionItems[index];
        final updatedItem = item.copyWith(
          product: product,
          productId: product.id,
          quantity: quantity,
          price: price,
          subtotal: price * quantity,
          updatedAt: DateTime.now().toIso8601String(),
        );
        
        transactionItems[index] = updatedItem;
        _calculateTotals();
      }
    } catch (e) {
      errorMessage.value = 'Gagal memperbarui item: $e';
      rethrow;
    }
  }
  
  void removeTransactionItem(int index) {
    if (index >= 0 && index < transactionItems.length) {
      transactionItems.removeAt(index);
      _calculateTotals();
    }
  }
  
  // Calculate transaction totals
  void _calculateTotals() {
    // Calculate subtotal from all items
    subtotal.value = transactionItems.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
    
    // Parse discount from controller
    final discountValue = double.tryParse(discountController.text) ?? 0.0;
    discount.value = discountValue > 0 ? discountValue : 0.0;
    
    // Calculate tax and total
    tax.value = calculatedTax.value;
    total.value = calculatedTotal.value;
  }
  
  // Reset form
  void resetForm() {
    transactionItems.clear();
    selectedStore.value = null;
    transactionDate.value = DateTime.now();
    discountController.clear();
    notesController.clear();
    _calculateTotals();
  }
  
  // Create new transaction
  Future<bool> createTransaction() async {
    try {
      if (selectedStore.value == null) {
        errorMessage.value = 'Pilih toko terlebih dahulu';
        return false;
      }
      
      if (transactionItems.isEmpty) {
        errorMessage.value = 'Tambahkan minimal satu item transaksi';
        return false;
      }
      
      isLoading.value = true;
      
      final transaction = TransactionModel(
        id: 0, // Will be set by the server
        storeId: selectedStore.value!.id,
        invoiceNumber: '', // Will be generated by the server
        totalAmount: subtotal.value,
        discount: discount.value > 0 ? discount.value : null,
        tax: tax.value > 0 ? tax.value : null,
        grandTotal: total.value,
        status: 'pending',
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        transactionDate: DateFormat('yyyy-MM-dd').format(transactionDate.value),
        store: selectedStore.value,
        items: transactionItems,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      final response = await _transactionRepository.createTransaction(transaction);
      
      if (response.success) {
        // Reset form on success
        resetForm();
        // Navigate to transaction list
        Get.offAllNamed(Routes.TRANSACTIONS);
        return true;
      } else {
        errorMessage.value = response.message ?? 'Gagal membuat transaksi';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat membuat transaksi';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _transactionRepository.getTransactionById(id);
      
      if (response.success) {
        return response.data;
      } else {
        errorMessage.value = response.message ?? 'Gagal mengambil detail transaksi';
        return null;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil detail transaksi';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void updateFilters({
    String? search,
    String? status,
    int? storeId,
    int? consignmentId,
    String? startDate,
    String? endDate,
  }) {
    searchQuery.value = search ?? searchQuery.value;
    statusFilter.value = status ?? statusFilter.value;
    storeIdFilter.value = storeId ?? storeIdFilter.value;
    consignmentIdFilter.value = consignmentId ?? consignmentIdFilter.value;
    startDateFilter.value = startDate ?? startDateFilter.value;
    endDateFilter.value = endDate ?? endDateFilter.value;
    
    fetchTransactions();
  }

  void resetFilters() {
    searchQuery.value = '';
    statusFilter.value = '';
    storeIdFilter.value = 0;
    consignmentIdFilter.value = 0;
    startDateFilter.value = '';
    endDateFilter.value = '';
    
    fetchTransactions();
  }

  Future<TransactionModel?> getTransactionDetail(int id) async {
    try {
      final response = await _transactionRepository.getTransactionById(id);
      if (response.success) {
        return response.data;
      }
      errorMessage.value = response.message ?? 'Gagal mengambil detail transaksi';
      return null;
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat mengambil detail transaksi';
      return null;
    }
  }

  Future<bool> updateTransactionStatus(int id, String status) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _transactionRepository.updateTransactionStatus(id, status);
      
      if (response.success) {
        // Refresh transaksi yang ada di list
        await fetchTransactions();
        return true;
      } else {
        errorMessage.value = response.message ?? 'Gagal memperbarui status transaksi';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memperbarui status transaksi';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelTransaction(int id) async {
    final result = await updateTransactionStatus(id, 'cancelled');
    if (result) {
      Get.snackbar('Berhasil', 'Transaksi berhasil dibatalkan');
    } else {
      Get.snackbar('Gagal', errorMessage.value);
    }
    return result;
  }

  Future<bool> completeTransaction(int id) async {
    final result = await updateTransactionStatus(id, 'completed');
    if (result) {
      Get.snackbar('Berhasil', 'Transaksi berhasil diselesaikan');
    } else {
      Get.snackbar('Gagal', errorMessage.value);
    }
    return result;
  }
}
