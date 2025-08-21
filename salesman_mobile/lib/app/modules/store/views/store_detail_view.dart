import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/store/controllers/store_controller.dart';

class StoreDetailView extends GetView<StoreController> {
  const StoreDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = Get.arguments as Map<String, dynamic>?;
    
    if (store == null) {
      return const Scaffold(
        body: Center(child: Text('Toko tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Toko'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit store
              // Get.toNamed('${Routes.STORES}/edit/${store['id']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              context,
              title: 'Informasi Toko',
              children: [
                _buildInfoItem('Nama Toko', store['name']),
                _buildInfoItem('Alamat', store['address']),
                if (store['phone'] != null) _buildInfoItem('Telepon', store['phone']),
                if (store['email'] != null) _buildInfoItem('Email', store['email']),
                if (store['description'] != null) _buildInfoItem('Deskripsi', store['description']),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Start visit
          // Get.toNamed(Routes.CHECK_IN, arguments: {'storeId': store['id']});
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Mulai Kunjungan'),
      ),
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

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
