import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/product/controllers/product_controller.dart';
import 'package:salesman_mobile/app/widgets/custom_app_bar.dart';
import 'package:salesman_mobile/app/widgets/custom_button.dart';
import 'package:salesman_mobile/app/widgets/custom_text_field.dart';
import 'package:salesman_mobile/core/theme/app_colors.dart';
import 'package:salesman_mobile/core/theme/app_text_styles.dart';

class ProductCreateView extends GetView<ProductController> {
  const ProductCreateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tambah Produk',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
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
                        'Tambahkan Foto Produk',
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
              
              // Kode
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
                prefixText: 'Rp ',
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
              
              // Submit Button
              Obx(() => CustomButton(
                    onPressed: controller.isLoading.value ? null : controller.submitProductForm,
                    isLoading: controller.isLoading.value,
                    child: Text(
                      'Simpan Produk',
                      style: AppTextStyles.buttonText,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
