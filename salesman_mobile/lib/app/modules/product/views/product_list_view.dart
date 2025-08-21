import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/product/controllers/product_controller.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(Routes.PRODUCT_CREATE),
            tooltip: 'Tambah Produk',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.PRODUCT_CREATE),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshProducts,
        child: Obx(() {
          if (controller.isLoading.value && controller.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refreshProducts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (controller.products.isEmpty) {
            return const Center(child: Text('Tidak ada produk tersedia'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.products.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.products.length) {
                if (!controller.isLoading.value) {
                  controller.fetchProducts(loadMore: true);
                }
                return const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }

              final product = controller.products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.shopping_bag, color: Colors.blue),
                            ),
                          )
                        : const Icon(Icons.shopping_bag, color: Colors.blue),
                  ),
                  title: Text(product.name),
                  subtitle: Text('Stok: ${product.stock} pcs • Rp${product.price.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to product detail
                    Get.toNamed(
                      '${Routes.PRODUCT_DETAIL.replaceAll(':id', product.id.toString())}',
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
}
