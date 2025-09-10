import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';

class ConsignmentEditController extends GetxController {
  final ConsignmentRepository _consignmentRepository = Get.find<ConsignmentRepository>();
  
  // Form fields
  final formKey = GlobalKey<FormState>();
  final notesController = TextEditingController();
  final statusController = TextEditingController();
  
  // State
  final Rx<ConsignmentModel> consignment = ConsignmentModel(
    id: 0,
    storeId: 0,
    code: '',
    status: 'pending',
    startDate: DateTime.now(),
    items: [],
    store: null,
    user: null,
    endDate: null,
    notes: null,
    createdAt: null,
    updatedAt: null,
  ).obs;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ConsignmentModel) {
      consignment.value = args;
      notesController.text = args.notes ?? '';
      statusController.text = args.status;
    }
  }
  
  @override
  void onClose() {
    notesController.dispose();
    statusController.dispose();
    super.onClose();
  }
  
  Future<void> saveConsignment() async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Create updated consignment with form data
      final updatedConsignment = ConsignmentModel(
        id: consignment.value.id,
        storeId: consignment.value.storeId,
        code: consignment.value.code,
        status: statusController.text.trim(),
        startDate: consignment.value.startDate,
        endDate: consignment.value.endDate,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        store: consignment.value.store,
        user: consignment.value.user,
        items: consignment.value.items,
        createdAt: consignment.value.createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      
      // Call API to update consignment
      final result = await _consignmentRepository.updateConsignment(updatedConsignment);
      
      if (result.success) {
        Get.back(result: true); // Return success
        Get.snackbar(
          'Berhasil',
          'Konsinyasi berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        errorMessage.value = result.message ?? 'Gagal memperbarui konsinyasi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan saat memperbarui konsinyasi';
      print('Error updating consignment: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Status options for dropdown
  List<DropdownMenuItem<String>> get statusOptions => [
    const DropdownMenuItem(value: 'pending', child: Text('Menunggu')),
    const DropdownMenuItem(value: 'active', child: Text('Aktif')),
    const DropdownMenuItem(value: 'completed', child: Text('Selesai')),
    const DropdownMenuItem(value: 'cancelled', child: Text('Dibatalkan')),
  ];
}
