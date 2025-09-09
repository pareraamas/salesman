import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/modules/store/controllers/store_controller.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class StoreDetailView extends StatelessWidget {
  const StoreDetailView({super.key});

  void _showDeleteConfirmation(StoreModel store) {
    Get.defaultDialog(
      title: 'Hapus Toko',
      middleText: 'Anda yakin ingin menghapus toko ${store.name}?',
      textConfirm: 'Ya, Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey[700],
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      onConfirm: () async {
        Get.back(); // Close the dialog
        await _deleteStore(store);
      },
    );
  }

  Future<void> _deleteStore(StoreModel store) async {
    final success = await Get.find<StoreController>().deleteStore(store.id);
    if (success) {
      Get.back(); // Close detail view
    }
  }

  Future<void> _toggleStoreStatus(StoreModel store) async {
    try {
      final controller = Get.find<StoreController>();
      final updatedStore = store.copyWith(
        status: store.status == 'active' ? 'inactive' : 'active',
      );
      
      final success = await controller.updateStore(updatedStore);
      
      if (success) {
        Get.snackbar(
          'Berhasil',
          'Status toko berhasil diubah',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        // Refresh the store data
        final updated = await controller.getStoreById(store.id);
        if (updated != null) {
          Get.offAndToNamed(
            Routes.STORE_DETAIL,
            arguments: updated,
          );
        }
      } else {
        throw Exception(controller.errorMessage.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status toko: ${e.toString().replaceAll('Exception: ', '')}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      rethrow;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      Get.snackbar('Error', 'Tidak dapat melakukan panggilan');
    }
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka peta');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    
    try {
      final date = DateTime.parse(dateString).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get store from arguments
    final dynamic args = Get.arguments;
    final StoreModel? store = args is StoreModel ? args : null;
    
    // If we have a store ID in parameters but no store object, try to fetch it
    if (store == null && Get.parameters['id'] != null) {
      final storeId = int.tryParse(Get.parameters['id']!);
      if (storeId != null) {
        final controller = Get.find<StoreController>();
        final foundStore = controller.stores.firstWhereOrNull((s) => s.id == storeId);
        if (foundStore != null) {
          return _buildStoreDetail(foundStore);
        }
      }
    }
    
    // If store is still null, show not found message
    if (store == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Toko'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Toko tidak ditemukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'ID: ${Get.parameters['id'] ?? 'Tidak ada ID'}\n'
                'Silakan coba lagi nanti.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Kembali ke Daftar Toko'),
              ),
            ],
          ),
        ),
      );
    }
    
    return _buildStoreDetail(store);
  }
  
  Widget _buildStoreDetail(StoreModel store) {
    // Get status display text and color
    final statusText = store.status == 'active' ? 'Aktif' : 'Nonaktif';
    final statusColor = store.status == 'active' ? Colors.green : Colors.orange;
    
    // Get store details with fallback values
    final storeName = store.name.isNotEmpty ? store.name : 'Nama tidak tersedia';
    final storeCode = store.code.isNotEmpty ? store.code : 'Kode tidak tersedia';
    final storeAddress = store.address.isNotEmpty ? store.address : 'Alamat tidak tersedia';
    
    // Format phone number if available
    String? formattedPhone;
    if (store.phone != null && store.phone!.isNotEmpty) {
      final phone = store.phone!;
      if (phone.length >= 11) {
        formattedPhone = '${phone.substring(0, 4)}-${phone.substring(4, 8)}-${phone.substring(8)}';
      } else if (phone.length >= 8) {
        formattedPhone = '${phone.substring(0, 4)}-${phone.substring(4)}';
      } else {
        formattedPhone = phone;
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Toko'),
        actions: [
          Builder(
            builder: (BuildContext context) => _buildPopupMenuButton(context, store),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Builder(
          builder: (BuildContext context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                context,
                title: 'Informasi Toko',
                children: [
                  _buildInfoItem('Kode Toko', storeCode),
                  _buildInfoItem('Nama Toko', storeName),
                  _buildInfoItem('Status', statusText, 
                    valueStyle: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildInfoItem('Alamat', storeAddress),
                  if (formattedPhone != null)
                    _buildInfoItem(
                      'Telepon', 
                      formattedPhone,
                      onTap: () => _makePhoneCall(store.phone!),
                      valueStyle: const TextStyle(color: Colors.blue),
                    ),
                  if (store.ownerName != null && store.ownerName!.isNotEmpty)
                    _buildInfoItem('Pemilik', store.ownerName!),
                  if (store.latitude != null && store.longitude != null)
                    _buildInfoItem(
                      'Lokasi', 
                      '${store.latitude}, ${store.longitude}',
                      onTap: () => _openMap(store.latitude!, store.longitude!),
                      valueStyle: const TextStyle(color: Colors.blue),
                    ),
                  _buildInfoItem('Dibuat', _formatDate(store.createdAt)),
                  if (store.updatedAt != null && store.updatedAt!.isNotEmpty)
                    _buildInfoItem('Diperbarui', _formatDate(store.updatedAt!)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Statistik Kunjungan',
                children: [
                  _buildInfoItem('Kunjungan Hari Ini', '0'),
                  _buildInfoItem('Kunjungan Minggu Ini', '0'),
                  _buildInfoItem('Kunjungan Bulan Ini', '0'),
                  _buildInfoItem('Total Kunjungan', '0'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: store.status == 'active'
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigate to store visit screen
                Get.toNamed(
                  Routes.ADD_STORE_VISIT,
                  arguments: {'store': store},
                );
              },
              icon: const Icon(Icons.store),
              label: const Text('Kunjungi Toko'),
              backgroundColor: Get.theme.primaryColor,
              heroTag: 'visit_store_${store.id}',
            )
          : null,
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, StoreModel store) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            await Get.toNamed(
              '/store/edit',
              arguments: store,
            );
            // Refresh the store data if we came back from edit
            if (Get.arguments is StoreModel) {
              // The store data might have been updated
              Get.offAndToNamed(
                '/store/detail',
                arguments: Get.arguments,
              );
            }
            break;
          case 'delete':
            _showDeleteConfirmation(store);
            break;
          case 'toggle_status':
            await _toggleStoreStatus(store);
            // Refresh the store data after status change
            if (Get.arguments is StoreModel) {
              Get.offAndToNamed(
                '/store/detail',
                arguments: Get.arguments,
              );
            }
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit Toko'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                store.status == 'active' ? Icons.toggle_off : Icons.toggle_on,
                size: 20,
                color: store.status == 'active' ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                store.status == 'active' ? 'Nonaktifkan' : 'Aktifkan',
              ),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Hapus Toko',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label, 
    String? value, {
    TextStyle? valueStyle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: GestureDetector(
              onTap: value?.isNotEmpty == true ? onTap : null,
              child: Text(
                value?.isNotEmpty == true ? value! : '-',
                style: valueStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
