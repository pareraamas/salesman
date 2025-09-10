import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/consignment_create_controller.dart';

class ConsignmentCreateView extends GetView<ConsignmentCreateController> {
  const ConsignmentCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Konsinyasi Baru'),
        actions: [
          TextButton(
            onPressed: controller.isLoading.value ? null : controller.submitForm,
            child: Obx(() => controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Simpan')),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Message
              Obx(() => controller.errorMessage.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink()),

              // Store Selection
              _buildDropdownField(
                label: 'Toko',
                hint: 'Pilih Toko',
                controller: controller.storeController,
                onTap: () => _showStoreSelection(context),
                validator: (value) =>
                    controller.selectedStore.value == null
                        ? 'Pilih toko'
                        : null,
              ),

              const SizedBox(height: 16),

              // Product Selection
              _buildDropdownField(
                label: 'Produk',
                hint: 'Pilih Produk',
                controller: controller.productController,
                onTap: () => _showProductSelection(context),
                validator: (value) =>
                    controller.selectedProduct.value == null
                        ? 'Pilih produk'
                        : null,
              ),

              const SizedBox(height: 16),

              // Quantity
              const Text(
                'Jumlah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: controller.decrementQuantity,
                  ),
                  Obx(() => Text(
                        controller.quantity.value.toString(),
                        style: const TextStyle(fontSize: 18),
                      )),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: controller.incrementQuantity,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Start Date
              _buildDateField(
                label: 'Tanggal Mulai',
                controller: controller.startDateController,
                onTap: () => controller.selectDate(context, true),
              ),

              const SizedBox(height: 16),

              // End Date (Optional)
              _buildDateField(
                label: 'Tanggal Selesai (Opsional)',
                controller: controller.endDateController,
                onTap: () => controller.selectDate(context, false),
                isRequired: false,
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: controller.notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: IgnorePointer(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
              ),
              validator: isRequired
                  ? (value) => value!.isEmpty ? 'Field ini wajib diisi' : null
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  void _showStoreSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Pilih Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.stores.length,
                  itemBuilder: (context, index) {
                    final store = controller.stores[index];
                    return ListTile(
                      title: Text(store.name),
                      subtitle: Text(store.address),
                      onTap: () {
                        controller.selectStore(store);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Pilih Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'Harga: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(product.price)}',
                      ),
                      onTap: () {
                        controller.selectProduct(product);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
