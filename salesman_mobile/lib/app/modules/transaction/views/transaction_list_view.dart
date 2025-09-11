import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesman_mobile/app/data/models/transaction_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:salesman_mobile/app/widgets/empty_state.dart';
import 'package:salesman_mobile/app/widgets/error_state.dart';
import 'package:salesman_mobile/app/widgets/loading_state.dart';

class TransactionListView extends GetView<TransactionController> {
  const TransactionListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.transactions.isEmpty) {
          return const LoadingState();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refreshTransactions,
          );
        }

        if (controller.transactions.isEmpty) {
          return EmptyState(
            message: 'Tidak ada data transaksi',
            onRefresh: controller.refreshTransactions,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTransactions,
          child: ListView.builder(
            itemCount: controller.transactions.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.transactions.length) {
                if (!controller.isLoading.value) {
                  controller.fetchTransactions(loadMore: true);
                }
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final transaction = controller.transactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          transaction.invoiceNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.store != null) Text(transaction.store!.name),
            Text('${dateFormat.format(DateTime.parse(transaction.transactionDate ?? transaction.createdAt!))}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(transaction.grandTotal),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(transaction.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Get.toNamed(
            '/transactions/${transaction.id}',
            arguments: transaction.id,
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Menunggu';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  void _showFilterDialog() {
    final controller = Get.find<TransactionController>();
    final dateFormat = DateFormat('dd MMM yyyy');
    
    // Temporary variables to hold filter values
    final tempStoreId = controller.storeIdFilter.value;
    final tempStatus = controller.statusFilter.value;
    final tempStartDate = controller.startDateFilter.value;
    final tempEndDate = controller.endDateFilter.value;
    
    Get.dialog(
      AlertDialog(
        title: const Text('Filter Transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter Toko
              Obx(() => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Toko',
                  border: OutlineInputBorder(),
                ),
                value: controller.storeIdFilter.value > 0 
                    ? controller.storeIdFilter.value 
                    : null,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Toko'),
                  ),
                  ...controller.stores.map((store) {
                    return DropdownMenuItem(
                      value: store.id,
                      child: Text(store.name),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  controller.storeIdFilter.value = value ?? 0;
                },
              )),
              
              const SizedBox(height: 16),
              
              // Filter Status
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                value: controller.statusFilter.value.isNotEmpty 
                    ? controller.statusFilter.value 
                    : null,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Semua Status'),
                  ),
                  ...['pending', 'completed', 'cancelled'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(_getStatusText(status)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  controller.statusFilter.value = value ?? '';
                },
              ),
              
              const SizedBox(height: 16),
              
              // Filter Tanggal Mulai
              ListTile(
                title: const Text('Dari Tanggal'),
                subtitle: Text(
                  controller.startDateFilter.value.isNotEmpty
                      ? dateFormat.format(DateTime.parse(controller.startDateFilter.value))
                      : 'Pilih Tanggal',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: controller.startDateFilter.value.isNotEmpty
                        ? DateTime.parse(controller.startDateFilter.value)
                        : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    controller.startDateFilter.value = date.toIso8601String().split('T')[0];
                  }
                },
              ),
              
              // Filter Tanggal Selesai
              ListTile(
                title: const Text('Sampai Tanggal'),
                subtitle: Text(
                  controller.endDateFilter.value.isNotEmpty
                      ? dateFormat.format(DateTime.parse(controller.endDateFilter.value))
                      : 'Pilih Tanggal',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: controller.endDateFilter.value.isNotEmpty
                        ? DateTime.parse(controller.endDateFilter.value)
                        : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    controller.endDateFilter.value = date.toIso8601String().split('T')[0];
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset to original values
              controller.storeIdFilter.value = tempStoreId;
              controller.statusFilter.value = tempStatus;
              controller.startDateFilter.value = tempStartDate;
              controller.endDateFilter.value = tempEndDate;
              Get.back();
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Reset pagination and fetch with new filters
              controller.currentPage.value = 1;
              controller.refreshTransactions();
              Get.back();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}
