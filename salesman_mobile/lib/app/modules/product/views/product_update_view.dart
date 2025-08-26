import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/product/controllers/product_controller.dart';
import 'package:salesman_mobile/app/widgets/custom_app_bar.dart';
import 'package:salesman_mobile/app/widgets/custom_button.dart';
import 'package:salesman_mobile/app/widgets/custom_text_field.dart';
import 'package:salesman_mobile/core/theme/app_colors.dart';
import 'package:salesman_mobile/core/theme/app_text_styles.dart';

class ProductUpdateView extends GetView<ProductController> {
  const ProductUpdateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get product ID from route parameters
    final productId = Get.parameters['id'] ?? '';
    
    // Load product data when view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productId.isNotEmpty) {
        controller.getProductById(int.parse(productId));
      } else {
        Get.back(); // Go back if no product ID is provided
      }
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Produk',
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentProduct.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final productId = Get.parameters['id'];
                      if (productId != null && productId.isNotEmpty) {
                        controller.getProductById(int.parse(productId));
                      }
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image Upload
                GestureDetector(
                  onTap: () {
                    // TODO: Implement image picker
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey300,
                        width: 1.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ubah Foto Produk',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Name
                CustomTextField(
                  controller: controller.nameController,
                  label: 'Nama Produk *',
                  hint: 'Masukkan nama produk',
                  validator: controller.validateName,
                ),
                const SizedBox(height: 16),
                
                // Code
                CustomTextField(
                  controller: controller.codeController,
                  label: 'Kode Produk *',
                  hint: 'Masukkan kode produk',
                  validator: controller.validateCode,
                ),
                const SizedBox(height: 16),
                
                // Price
                CustomTextField(
                  controller: controller.priceController,
                  label: 'Harga *',
                  hint: 'Masukkan harga',
                  keyboardType: TextInputType.number,
                  validator: controller.validatePrice,
                ),
                const SizedBox(height: 16),
                
                // Description
                CustomTextField(
                  controller: controller.descriptionController,
                  label: 'Deskripsi',
                  hint: 'Masukkan deskripsi produk (opsional)',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                
                const SizedBox(height: 16),
                
                // Update Button
                Obx(
                  () => CustomButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            final productId = Get.parameters['id'];
                            if (productId != null && productId.isNotEmpty) {
                              controller.updateProduct(int.parse(productId));
                            }
                          },
                    isLoading: controller.isLoading.value,
                    child: Text(
                      'Perbarui Produk',
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Delete Button
                Obx(
                  () => TextButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            final shouldDelete = await Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Hapus Produk'),
                                content: const Text('Apakah Anda yakin ingin menghapus produk ini? Tindakan ini tidak dapat dibatalkan.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Batal', style: TextStyle(color: AppColors.grey600)),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (shouldDelete == true) {
                              final productId = Get.parameters['id'];
                              if (productId != null && productId.isNotEmpty) {
                                await controller.deleteProduct(int.parse(productId));
                              }
                            }
                          },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    label: Text(
                      'Hapus Produk',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
