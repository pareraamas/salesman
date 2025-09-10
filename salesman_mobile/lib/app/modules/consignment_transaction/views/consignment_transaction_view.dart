import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesman_mobile/app/data/models/consignment_transaction_model.dart';
import 'package:salesman_mobile/app/modules/consignment_transaction/controllers/consignment_transaction_controller.dart';
import 'package:salesman_mobile/app/widgets/empty_state.dart';
import 'package:salesman_mobile/app/widgets/error_state.dart';
import 'package:salesman_mobile/app/widgets/loading_state.dart';

class ConsignmentTransactionView extends GetView<ConsignmentTransactionController> {
  const ConsignmentTransactionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi Konsinyasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(context),
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
            onRetry: controller.loadTransactions,
          );
        }

        if (controller.transactions.isEmpty) {
          return EmptyState(
            message: 'Belum ada transaksi',
            onRefresh: controller.refreshTransactions,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTransactions,
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.transactions.length + 1, // +1 for loading indicator
            itemBuilder: (context, index) {
              if (index < controller.transactions.length) {
                final transaction = controller.transactions[index];
                return _buildTransactionCard(transaction);
              } else {
                return controller.isLoading.value
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }
            },
          ),
        );
      }),
      bottomNavigationBar: _buildSummaryBar(),
    );
  }

  Widget _buildTransactionCard(ConsignmentTransactionModel transaction) {
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');
    final date = DateTime.tryParse(transaction.transactionDate) ?? DateTime.now();
    final isSale = transaction.transactionType == 'sale';
    final isReturn = transaction.transactionType == 'return';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSale
              ? Colors.green.shade100
              : isReturn
                  ? Colors.blue.shade100
                  : Colors.orange.shade100,
          child: Icon(
            isSale ? Icons.shopping_cart : isReturn ? Icons.reply : Icons.adjust,
            color: isSale
                ? Colors.green
                : isReturn
                    ? Colors.blue
                    : Colors.orange,
          ),
        ),
        title: Text(
          isSale
              ? 'Penjualan'
              : isReturn
                  ? 'Retur'
                  : 'Penyesuaian',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.quantity} item • ${dateFormat.format(date)}',
        ),
        trailing: Text(
          '${isSale ? '+' : isReturn ? '+' : '±'}${transaction.quantity}',
          style: TextStyle(
            color: isSale
                ? Colors.green
                : isReturn
                    ? Colors.blue
                    : Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          // Navigate to transaction detail if needed
          // Get.toNamed(Routes.CONSIGNMENT_TRANSACTION_DETAIL, arguments: {'id': transaction.id});
        },
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Obx(() {
      final totalSales = controller.getTotalQuantityByType('sale');
      final totalReturns = controller.getTotalQuantityByType('return');
      final totalAdjustments = controller.getTotalQuantityByType('adjustment');
      final netQuantity = totalSales - totalReturns + totalAdjustments;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem('Terjual', totalSales, Colors.green),
            _buildSummaryItem('Retur', totalReturns, Colors.blue),
            _buildSummaryItem('Penyesuaian', totalAdjustments, Colors.orange),
            _buildSummaryItem('Total', netQuantity, Colors.indigo, isBold: true),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, int value, Color color, {bool isBold = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    String? selectedType = 'sale';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Transaksi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Transaksi',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'sale',
                      child: Text('Penjualan'),
                    ),
                    const DropdownMenuItem(
                      value: 'return',
                      child: Text('Retur'),
                    ),
                    const DropdownMenuItem(
                      value: 'adjustment',
                      child: Text('Penyesuaian'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan jumlah';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final quantity = int.tryParse(quantityController.text) ?? 0;
                if (quantity <= 0) {
                  Get.snackbar(
                    'Error',
                    'Jumlah harus lebih dari 0',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                final success = await controller.createTransaction(
                  transactionType: selectedType!,
                  quantity: quantity,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );

                if (success) {
                  Get.back();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
