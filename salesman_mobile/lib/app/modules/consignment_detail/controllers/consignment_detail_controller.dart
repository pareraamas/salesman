import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class ConsignmentDetailController extends GetxController {
  final ConsignmentRepository _consignmentRepository = Get.find<ConsignmentRepository>();
  
  // State
  final Rx<ConsignmentModel?> consignment = Rx<ConsignmentModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Permission flags - sesuaikan dengan role user
  bool get canEdit => true;
  bool get canDelete => true;
  
  // Get consignment ID from arguments
  int? get consignmentId {
    if (Get.arguments is int) {
      return Get.arguments as int;
    } else if (Get.arguments is String) {
      return int.tryParse(Get.arguments as String);
    } else if (Get.arguments is ConsignmentModel) {
      return (Get.arguments as ConsignmentModel).id;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    if (consignmentId != null) {
      fetchConsignmentDetail();
    } else if (Get.arguments is ConsignmentModel) {
      consignment.value = Get.arguments as ConsignmentModel;
    } else {
      errorMessage.value = 'ID Konsinyasi tidak valid';
    }
  }

  Future<void> fetchConsignmentDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await _consignmentRepository.getConsignmentById(consignmentId!);
      
      if (result.success && result.data != null) {
        consignment.value = result.data!;
      } else {
        errorMessage.value = result.message ?? 'Gagal memuat detail konsinyasi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memuat detail konsinyasi';
      print('Error fetching consignment detail: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> editConsignment(ConsignmentModel consignment) async {
    final result = await Get.toNamed(
      '/consignments/${consignment.id}/edit',
      arguments: consignment,
    );
    
    if (result == true) {
      // Refresh the data if the consignment was updated
      await fetchConsignmentDetail();
    }
  }
  
  Future<void> deleteConsignment(int id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Konsinyasi'),
        content: const Text('Apakah Anda yakin ingin menghapus konsinyasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Tampilkan loading
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final response = await _consignmentRepository.deleteConsignment(id);
        Get.back(); // Tutup loading

        if (response.success) {
          Get.back(result: true); // Kembali ke halaman sebelumnya
          Get.snackbar(
            'Berhasil',
            'Konsinyasi berhasil dihapus',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Gagal',
            response.message ?? 'Gagal menghapus konsinyasi',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.back(); // Tutup loading
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat menghapus konsinyasi',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
  
  Future<void> refreshData() async {
    await fetchConsignmentDetail();
  }

  /// Navigate to consignment transactions page
  void viewTransactions(int consignmentId) {
    Get.toNamed(
      Routes.CONSIGNMENT_TRANSACTIONS.replaceAll(':id', consignmentId.toString()),
      arguments: {'consignmentId': consignmentId},
    );
  }
}
