import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/consignment/controllers/consignment_controller.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class ConsignmentListView extends GetView<ConsignmentController> {
  const ConsignmentListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Konsinyasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/consignments/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // List Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.consignments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (controller.consignments.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data konsinyasi'),
                );
              }

              return ListView.builder(
                itemCount: controller.consignments.length + 1, // +1 for loading indicator
                itemBuilder: (context, index) {
                  if (index < controller.consignments.length) {
                    final consignment = controller.consignments[index];
                    return _buildConsignmentCard(consignment);
                  } else {
                    // Show loading indicator at the bottom when loading more
                    return controller.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                },
                controller: ScrollController()
                  ..addListener(() {
                    final maxScroll = Scrollable.of(context).position.maxScrollExtent;
                    final currentScroll = Scrollable.of(context).position.pixels;
                    if (currentScroll >= (maxScroll * 0.9)) {
                      controller.loadMore();
                    }
                  }),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create consignment
        },
        backgroundColor: Theme.of(Get.context!).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Status Filter
            Obx(() {
              return DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                value: controller.filters['status'],
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua Status')),
                  ...['active', 'completed', 'returned', 'cancelled'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status[0].toUpperCase() + status.substring(1)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  controller.updateFilter('status', value);
                },
              );
            }),
            const SizedBox(height: 8),
            // Search field
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cari...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: (value) {
                controller.updateFilter('search', value.isEmpty ? null : value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsignmentCard(ConsignmentModel consignment) {
    final totalItems = consignment.items.fold(0, (sum, item) => sum + item.quantity);
    final productNames = consignment.items
        .map((item) => item.product?.name ?? 'Produk #${item.productId}')
        .join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text('Konsinyasi #${consignment.code}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (consignment.store != null) Text('Toko: ${consignment.store!.name}'),
            Text('Jumlah Item: $totalItems'),
            Text('Produk: $productNames'),
            Text('Status: ${_getStatusText(consignment.status)}'),
            Text('Mulai: ${_formatDate(consignment.startDate)}'),
            if (consignment.endDate != null) Text('Selesai: ${_formatDate(consignment.endDate!)}'),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Get.toNamed(
            Routes.CONSIGNMENT_DETAIL,
            arguments: consignment,
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Selesai';
      case 'returned':
        return 'Dikembalikan';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status ?? 'Tidak Diketahui';
    }
  }
}
