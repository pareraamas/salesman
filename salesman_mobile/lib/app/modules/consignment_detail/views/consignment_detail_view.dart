import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/modules/consignment_detail/controllers/consignment_detail_controller.dart';

class ConsignmentDetailView extends GetView<ConsignmentDetailController> {
  const ConsignmentDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final code = controller.consignment.value?.code;
          return Text('Detail Konsinyasi${code != null ? ' #$code' : ''}');
        }),
        actions: [
          Obx(() {
            final consignment = controller.consignment.value;
            if (consignment != null) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.receipt_long),
                    tooltip: 'Lihat Transaksi',
                    onPressed: () => controller.viewTransactions(consignment.id),
                  ),
                  if (controller.canEdit) ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => controller.editConsignment(consignment),
                    ),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshData,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final consignment = controller.consignment.value;
        if (consignment == null) {
          return const Center(child: Text('Data konsinyasi tidak ditemukan'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(consignment),
                const SizedBox(height: 16),
                _buildItemsList(consignment),
                const SizedBox(height: 16),
                _buildStatusSection(consignment),
                const SizedBox(height: 24),
                if (controller.canDelete)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.deleteConsignment(consignment.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Hapus Konsinyasi'),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(ConsignmentModel consignment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Kode', consignment.code),
            _buildInfoRow('Toko', consignment.store?.name ?? '-'),
            _buildInfoRow(
              'Tanggal Mulai',
              DateFormat('dd MMMM yyyy').format(consignment.startDate),
            ),
            _buildInfoRow(
              'Tanggal Selesai',
              consignment.endDate != null
                  ? DateFormat('dd MMMM yyyy').format(consignment.endDate!)
                  : '-',
            ),
            if (consignment.notes?.isNotEmpty == true)
              _buildInfoRow('Catatan', consignment.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(ConsignmentModel consignment) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Daftar Produk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          if (consignment.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Tidak ada produk dalam konsinyasi ini'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: consignment.items.length,
              itemBuilder: (context, index) {
                final item = consignment.items[index];
                final remaining = item.quantity - 
                    (item.soldQuantity ?? 0) - 
                    (item.returnedQuantity ?? 0);
                return ListTile(
                  title: Text(item.product?.name ?? 'Produk #${item.productId}'),
                  subtitle: Text('Jumlah: ${item.quantity}'),
                  trailing: Text(
                    'Tersisa: $remaining',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(ConsignmentModel consignment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Konsinyasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusItem('Status', _getStatusText(consignment.status)),
            const SizedBox(height: 8),
            if (consignment.createdAt != null && consignment.createdAt!.isNotEmpty)
              _buildStatusItem('Dibuat Pada', 
                DateFormat('dd MMMM yyyy HH:mm').format(DateTime.parse(consignment.createdAt!))),
            if (consignment.updatedAt != null && consignment.updatedAt!.isNotEmpty) ...[  
              const SizedBox(height: 8),
              _buildStatusItem('Diperbarui Pada', 
                DateFormat('dd MMMM yyyy HH:mm').format(DateTime.parse(consignment.updatedAt!))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const Text(': '),
        Text(value),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }
}
