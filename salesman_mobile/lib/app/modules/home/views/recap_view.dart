import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final String store;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;

  Transaction({
    required this.id,
    required this.store,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
  });
}

class Consignment {
  final String id;
  final String product;
  final String store;
  final String quantity;
  final String date;
  final String status;
  final Color statusColor;

  Consignment({
    required this.id,
    required this.product,
    required this.store,
    required this.quantity,
    required this.date,
    required this.status,
    required this.statusColor,
  });
}

class RecapView extends StatelessWidget {
  const RecapView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rekap'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Transaksi'),
              Tab(text: 'Konsinyasi'),
            ],
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const TabBarView(
          children: [
            _TransactionTab(),
            _ConsignmentTab(),
          ],
        ),
      ),
    );
  }
}

class _TransactionTab extends StatelessWidget {
  const _TransactionTab();

  @override
  Widget build(BuildContext context) {
    final transactions = [
      Transaction(
        id: 'TRX-001',
        store: 'Toko Sembako Maju',
        date: '10 Agustus 2023',
        amount: 'Rp 1.250.000',
        status: 'Selesai',
        statusColor: Colors.green,
      ),
      Transaction(
        id: 'TRX-002',
        store: 'Warung Makan Enak',
        date: '9 Agustus 2023',
        amount: 'Rp 850.000',
        status: 'Selesai',
        statusColor: Colors.green,
      ),
      Transaction(
        id: 'TRX-003',
        store: 'Toko Sejahtera',
        date: '8 Agustus 2023',
        amount: 'Rp 1.500.000',
        status: 'Pending',
        statusColor: Colors.orange,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              transaction.store,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('ID: ${transaction.id}'),
                Text(transaction.date),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: transaction.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.status,
                        style: TextStyle(
                          color: transaction.statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConsignmentTab extends StatelessWidget {
  const _ConsignmentTab();

  @override
  Widget build(BuildContext context) {
    final consignments = [
      Consignment(
        id: 'KSN-001',
        product: 'Minyak Goreng 2L',
        store: 'Toko Sembako Maju',
        quantity: '10 pcs',
        date: '10 Agustus 2023',
        status: 'Aktif',
        statusColor: Colors.blue,
      ),
      Consignment(
        id: 'KSN-002',
        product: 'Gula Pasir 1kg',
        store: 'Warung Makan Enak',
        quantity: '20 pcs',
        date: '9 Agustus 2023',
        status: 'Aktif',
        statusColor: Colors.blue,
      ),
      Consignment(
        id: 'KSN-003',
        product: 'Tepung Terigu 1kg',
        store: 'Toko Sejahtera',
        quantity: '15 pcs',
        date: '5 Agustus 2023',
        status: 'Selesai',
        statusColor: Colors.green,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: consignments.length,
      itemBuilder: (context, index) {
        final consignment = consignments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              consignment.product,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Toko: ${consignment.store}'),
                Text('Jumlah: ${consignment.quantity}'),
                Text('Tanggal: ${consignment.date}'),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: consignment.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      consignment.status,
                      style: TextStyle(
                        color: consignment.statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
