import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:salesman_mobile/app/data/models/transaction_model.dart';
import 'package:salesman_mobile/app/modules/transaction/controllers/transaction_controller.dart';

class TransactionDetailView extends StatefulWidget {
  final int transactionId;
  
  const TransactionDetailView({Key? key, required this.transactionId}) : super(key: key);

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  late int transactionId;

  @override
  void initState() {
    super.initState();
    transactionId = widget.transactionId;
  }

  void _showStatusUpdateDialog(String status, String message) {
    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi $message'),
        content: Text('Apakah Anda yakin ingin $message transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              final controller = Get.find<TransactionController>();
              bool success = false;
              
              if (status == 'cancelled') {
                success = await controller.cancelTransaction(transactionId);
              } else if (status == 'completed') {
                success = await controller.completeTransaction(transactionId);
              }
              
              if (success && mounted) {
                setState(() {});
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: status == 'cancelled' ? Colors.red : Colors.green,
            ),
            child: Text(status == 'cancelled' ? 'Batalkan' : 'Selesaikan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    
    final dateFormat = DateFormat('dd MMMM yyyy HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: FutureBuilder<TransactionModel?>(
        future: _loadTransactionDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat detail transaksi'));
          }
          
          if (!snapshot.hasData) {
            return const Center(child: Text('Data transaksi tidak ditemukan'));
          }
          
          final transaction = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Share Button
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'INV-${transaction.id.toString().padLeft(6, '0')}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () {
                                    _shareTransaction(transaction);
                                  },
                                ),
                                _buildStatusChip(transaction.status),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (transaction.store != null) ...[
                          Text(
                            'Toko: ${transaction.store!.name}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                        ],
                        
                        Text(
                          'Tanggal: ${dateFormat.format(DateTime.parse(transaction.transactionDate!))}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        
                        if (transaction.notes?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Catatan: ${transaction.notes}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        
                        // Action Buttons
                        if (transaction.status == 'pending') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showStatusUpdateDialog('cancelled', 'pembatalan'),
                                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                                  label: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showStatusUpdateDialog('completed', 'penyelesaian'),
                                  icon: const Icon(Icons.check_circle_outline, size: 18),
                                  label: const Text('Selesaikan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Items List
                Text(
                  'Daftar Barang',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transaction.items?.length ?? 0,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = transaction.items?[index];
                      if (item == null) return const SizedBox.shrink();
                      return ListTile(
                        title: Text(item.product?.name ?? 'Produk ${index + 1}'),
                        subtitle: Text('${item.quantity} x ${currencyFormat.format(item.price)}'),
                        trailing: Text(
                          currencyFormat.format(item.price * item.quantity),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
                
                // Summary
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', currencyFormat.format(transaction.totalAmount)),
                        if (transaction.discount != null && transaction.discount! > 0)
                          _buildSummaryRow('Diskon', '-${currencyFormat.format(transaction.discount)}'),
                        if (transaction.tax != null && transaction.tax! > 0)
                          _buildSummaryRow('Pajak', currencyFormat.format(transaction.tax)),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Total',
                          currencyFormat.format(transaction.grandTotal),
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.shade100;
        statusText = 'Selesai';
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade100;
        statusText = 'Menunggu';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.shade100;
        statusText = 'Dibatalkan';
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }
  
  Future<TransactionModel?> _loadTransactionDetail() async {
    final controller = Get.find<TransactionController>();
    return await controller.getTransactionById(transactionId);
  }

  void _shareTransaction(TransactionModel transaction) {
    try {
      final dateFormat = DateFormat('dd MMMM yyyy HH:mm');
      final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      
      // Build share text
      final buffer = StringBuffer();
      buffer.writeln('📋 *Detail Transaksi*');
      buffer.writeln('====================');
      buffer.writeln('📄 No. Invoice: INV-${transaction.id.toString().padLeft(6, '0')}');
      buffer.writeln('📅 Tanggal: ${dateFormat.format(DateTime.parse(transaction.transactionDate!))}');
      buffer.writeln('🏪 Toko: ${transaction.store?.name ?? '-'}');
      buffer.writeln('---------------------');
      buffer.writeln('🛒 *Daftar Barang*');
      
      // Add items
      for (var item in transaction.items ?? []) {
        buffer.writeln('• ${item.product?.name ?? 'Produk'} (${item.quantity} x ${currencyFormat.format(item.price)})');
      }
      
      buffer.writeln('---------------------');
      buffer.writeln('💵 Subtotal: ${currencyFormat.format(transaction.totalAmount)}');
      if (transaction.discount != null && transaction.discount! > 0) {
        buffer.writeln('💲 Diskon: -${currencyFormat.format(transaction.discount)}');
      }
      if (transaction.tax != null && transaction.tax! > 0) {
        buffer.writeln('🏛️ Pajak: ${currencyFormat.format(transaction.tax)}');
      }
      buffer.writeln('💰 *Total: ${currencyFormat.format(transaction.grandTotal)}*');
      
      if (transaction.notes?.isNotEmpty ?? false) {
        buffer.writeln('---------------------');
        buffer.writeln('📝 Catatan: ${transaction.notes}');
      }
      
      // Add a thank you message
      buffer.writeln('\nTerima kasih telah berbelanja!');
      
      // Share the content
      Share.share(
        buffer.toString(),
        subject: 'Detail Transaksi INV-${transaction.id.toString().padLeft(6, '0')}',
      );
    } catch (e) {
      Get.snackbar(
        'Gagal berbagi',
        'Terjadi kesalahan saat berbagi detail transaksi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

