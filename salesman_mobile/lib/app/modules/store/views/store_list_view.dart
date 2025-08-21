import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/store/controllers/store_controller.dart';

class StoreListView extends GetView<StoreController> {
  const StoreListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Toko'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              // Navigasi ke peta toko
              // Get.toNamed(Routes.STORE_MAP);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add store
          // Get.toNamed('${Routes.STORES}/add');
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshStores(),
        child: Obx(() {
          if (controller.isLoading.value && controller.stores.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terjadi kesalahan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(controller.errorMessage.value),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchStores(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (controller.stores.isEmpty) {
            return const Center(child: Text('Tidak ada toko yang ditemukan'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.stores.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.stores.length) {
                controller.fetchStores(loadMore: true);
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final store = controller.stores[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(store.name),
                  subtitle: Text(store.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Get.toNamed(
                      '/stores/${store.id}',
                      arguments: store.toJson(),
                    );
                  },
                ),
              );
            },
          );
        }),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Toko'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama toko...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => controller.searchStores(value),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.searchStores('');
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
