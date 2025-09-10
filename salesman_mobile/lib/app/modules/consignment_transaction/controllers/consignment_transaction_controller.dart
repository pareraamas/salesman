import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/consignment_transaction_model.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_transaction_repository.dart';

class ConsignmentTransactionController extends GetxController {
  final ConsignmentTransactionRepository _repository = Get.find<ConsignmentTransactionRepository>();

  // State
  final RxList<ConsignmentTransactionModel> transactions = <ConsignmentTransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;
  final RxBool hasMore = true.obs;
  final int consignmentId = Get.arguments['consignmentId'];
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    setupScrollController();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !isLoading.value &&
          hasMore.value) {
        loadMoreTransactions();
      }
    });
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 1;

      final response = await _repository.getConsignmentTransactions(
        consignmentId,
        page: currentPage.value,
        limit: itemsPerPage,
      );

      if (response.success && response.data != null) {
        transactions.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat transaksi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memuat transaksi';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;
      final nextPage = currentPage.value + 1;

      final response = await _repository.getConsignmentTransactions(
        consignmentId,
        page: nextPage,
        limit: itemsPerPage,
      );

      if (response.success && response.data != null) {
        if (response.data!.isEmpty) {
          hasMore.value = false;
        } else {
          transactions.addAll(response.data!);
          currentPage.value = nextPage;
        }
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat transaksi tambahan';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTransactions() async {
    await loadTransactions();
  }

  Future<bool> createTransaction({
    required String transactionType,
    required int quantity,
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _repository.createConsignmentTransaction(
        consignmentId,
        transactionType: transactionType,
        quantity: quantity,
        notes: notes,
      );

      if (response.success && response.data != null) {
        // Add new transaction to the beginning of the list
        transactions.insert(0, response.data!);
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

  // Get total quantity for a specific transaction type
  int getTotalQuantityByType(String type) {
    return transactions
        .where((t) => t.transactionType == type)
        .fold(0, (sum, t) => sum + t.quantity);
  }
}
