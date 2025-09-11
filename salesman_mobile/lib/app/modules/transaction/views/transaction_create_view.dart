import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/models/transaction_item_model.dart';
import 'package:salesman_mobile/app/modules/transaction/controllers/transaction_controller.dart';
import 'package:salesman_mobile/app/modules/transaction/views/transaction_item_dialog.dart';

class TransactionCreateView extends GetView<TransactionController> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat('dd MMMM yyyy');
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  TransactionCreateView({Key? key}) : super(key: key);

  Future<void> _showAddItemDialog() async {
    final result = await Get.dialog<TransactionItemModel>(
      const TransactionItemDialog(),
      barrierDismissible: false,
    );

    if (result != null) {
      await controller.addTransactionItem(
        product: result.product!,
        quantity: result.quantity,
        price: result.price,
      );
    }
  }
  
  Future<void> _editItem(int index, TransactionItemModel item) async {
    final result = await Get.dialog<dynamic>(
      TransactionItemDialog(
        item: item,
        index: index,
        isEditing: true,
      ),
      barrierDismissible: false,
    );

    if (result == false) {
      // Delete the item if result is false (delete button pressed)
      controller.removeTransactionItem(index);
      Get.snackbar(
        'Berhasil',
        'Item berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else if (result is TransactionItemModel) {
      // Update the item if result is a TransactionItemModel
      await controller.updateTransactionItem(
        index: index,
        product: result.product!,
        quantity: result.quantity,
        price: result.price,
      );
      Get.snackbar(
        'Berhasil',
        'Item berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (controller.transactionItems.isEmpty) {
        Get.snackbar('Error', 'Tambah minimal satu item transaksi');
        return;
      }

      try {
        await controller.createTransaction();
        Get.back(result: true);
        Get.snackbar('Sukses', 'Transaksi berhasil dibuat');
      } catch (e) {
        Get.snackbar('Error', 'Gagal membuat transaksi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Transaksi Baru'),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Selection
              _buildStoreField(),
              const SizedBox(height: 16),
              
              // Transaction Date
              _buildDateField(),
              const SizedBox(height: 16),
              
              // Items List
              _buildItemsList(),
              const SizedBox(height: 16),
              
              // Add Item Button
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : _showAddItemDialog,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Item'),
              )),
              const SizedBox(height: 24),
              
              // Summary
              _buildSummary(),
              const SizedBox(height: 24),
              
              // Notes
              _buildNotesField(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStoreField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Selection
        const Text(
          'Toko *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<StoreModel>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            hintText: 'Pilih Toko',
          ),
          value: controller.selectedStore.value,
          items: controller.stores.map((store) {
            return DropdownMenuItem<StoreModel>(
              value: store,
              child: Text(store.name),
            );
          }).toList(),
          onChanged: (store) {
            if (store != null) {
              controller.onStoreChanged(store);
            }
          },
          validator: (value) {
            if (value == null) return 'Pilih toko';
            return null;
          },
        )),
        
        // Consignment Selection
        const SizedBox(height: 16),
        const Text(
          'Konsinyasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: controller.availableConsignments.isEmpty
              ? const Text('Tidak ada konsinyasi aktif')
              : DropdownButtonHideUnderline(
                  child: DropdownButton<ConsignmentModel>(
                    isExpanded: true,
                    value: controller.selectedConsignment.value,
                    hint: const Text('Pilih Konsinyasi'),
                    items: controller.availableConsignments.map((consignment) {
                      return DropdownMenuItem<ConsignmentModel>(
                        value: consignment,
                        child: Text('${consignment.code} - ${consignment.store?.name ?? 'Toko'}'),
                      );
                    }).toList(),
                    onChanged: (consignment) {
                      controller.selectedConsignment.value = consignment;
                    },
                  ),
                ),
        )),
      ],
    );
  }
  
  Widget _buildDateField() {
    return Obx(() => InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tanggal Transaksi',
        border: OutlineInputBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_dateFormat.format(controller.transactionDate.value)),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: Get.context!,
                initialDate: controller.transactionDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                controller.transactionDate.value = date;
              }
            },
          ),
        ],
      ),
    ));
  }
  
  Widget _buildItemsList() {
    return Obx(() {
      if (controller.transactionItems.isEmpty) {
        return const Center(
          child: Text('Belum ada item transaksi'),
        );
      }
      
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.transactionItems.length,
        itemBuilder: (context, index) {
          final item = controller.transactionItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(item.product?.name ?? ''),
              subtitle: Text('${item.quantity} x ${_currencyFormat.format(item.price)}'),
              trailing: Text(
                _currencyFormat.format(item.price * item.quantity),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => _editItem(index, item),
            ),
          );
        },
      );
    });
  }
  
  Widget _buildSummary() {
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ringkasan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow('Subtotal', controller.subtotal),
            _buildSummaryRow('Diskon', controller.discount),
            _buildSummaryRow('Pajak (10%)', controller.calculatedTax),
            const Divider(),
            _buildSummaryRow('Total', controller.calculatedTotal, isTotal: true),
          ],
        ),
      ),
    ));
  }
  
  Widget _buildSummaryRow(String label, RxDouble value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Obx(() => Text(
          _currencyFormat.format(value.value),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
          ),
        )),
      ],
    );
  }
  
  Widget _buildNotesField() {
    return TextFormField(
      controller: controller.notesController,
      decoration: const InputDecoration(
        labelText: 'Catatan',
        border: OutlineInputBorder(),
        hintText: 'Tulis catatan (opsional)',
      ),
      maxLines: 3,
      enabled: !controller.isLoading.value,
    );
  }
  
}
