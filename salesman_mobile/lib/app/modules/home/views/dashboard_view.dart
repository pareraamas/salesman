import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout), 
            onPressed: () {
              // TODO: Implement logout
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            context,
            title: 'Toko',
            icon: Iconsax.shop,
            color: Colors.blue,
            onTap: () => Get.toNamed(Routes.STORES),
          ),
          _buildDashboardItem(
            context,
            title: 'Produk',
            icon: Iconsax.box,
            color: Colors.green,
            onTap: () => Get.toNamed(Routes.PRODUCTS),
          ),
          _buildDashboardItem(
            context,
            title: 'Konsinyasi',
            icon: Iconsax.receipt_item,
            color: Colors.orange,
            onTap: () => Get.toNamed(Routes.CONSIGNMENTS),
          ),
          _buildDashboardItem(
            context,
            title: 'Transaksi',
            icon: Iconsax.receipt,
            color: Colors.purple,
            onTap: () => Get.toNamed(Routes.TRANSACTIONS),
          ),
          _buildDashboardItem(
            context,
            title: 'Laporan',
            icon: Iconsax.chart,
            color: Colors.red,
            onTap: () => Get.toNamed(Routes.REPORTS),
          ),
          _buildDashboardItem(
            context,
            title: 'Profil',
            icon: Iconsax.profile_circle,
            color: Colors.teal,
            onTap: () => Get.toNamed(Routes.PROFILE),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
