import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/modules/store/controllers/store_controller.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';
import 'package:salesman_mobile/app/widgets/loading_indicator.dart';

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
            tooltip: 'Cari toko',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshStores(),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to store create page
          Get.toNamed(Routes.PRODUCT_CREATE);
        },
        icon: const Icon(Icons.add),
        label: const Text('Toko Baru'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final hasError = controller.errorMessage.value.isNotEmpty;
        final isEmpty = controller.stores.isEmpty;

        // Show loading indicator when loading for the first time
        if (isLoading && isEmpty) {
          return const Center(child: LoadingIndicator());
        }

        // Show error message if there's an error and no data
        if (hasError && isEmpty) {
          return _buildErrorState(context);
        }

        // Show empty state
        if (isEmpty) {
          return _buildEmptyState(context);
        }

        // Show list of stores with pull-to-refresh
        return RefreshIndicator(
          onRefresh: () => controller.refreshStores(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.stores.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom when loading more
              if (index >= controller.stores.length) {
                controller.fetchStores(loadMore: true);
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final store = controller.stores[index];
              return _buildStoreItem(context, store);
            },
          ),
        );
      }),
    );
  }

  // Build store item widget
  Widget _buildStoreItem(BuildContext context, StoreModel store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.toNamed('${Routes.STORES}/${store.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Initials
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    store.name.isNotEmpty 
                        ? store.name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
                        : '??',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name with Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: store.status == 'active' 
                                ? Colors.green[50] 
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: store.status == 'active' 
                                  ? Colors.green[200]! 
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            store.status == 'active' ? 'Aktif' : 'Nonaktif',
                            style: TextStyle(
                              color: store.status == 'active' 
                                  ? Colors.green[800] 
                                  : Colors.grey[800],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Store Code
                    if (store.code.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                        child: Text(
                          'Kode: ${store.code}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    
                    // Owner Name
                    if (store.ownerName != null && store.ownerName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              store.ownerName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Address
                    if (store.address.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Phone Number
                    if (store.phone != null && store.phone!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              store.phone!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Build error state widget
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data toko',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => controller.refreshStores(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshStores(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada toko',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + di pojok kanan bawah untuk menambahkan toko baru',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => controller.refreshStores(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Muat Ulang'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show search dialog
  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Toko'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nama toko, kode, atau pemilik',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.searchStores(value);
                  Get.back();
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan enter untuk mencari',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                controller.searchStores(query);
                Get.back();
              } else {
                Get.snackbar(
                  'Peringatan',
                  'Masukkan kata kunci pencarian',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange[50],
                  colorText: Colors.orange[900],
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }
}
