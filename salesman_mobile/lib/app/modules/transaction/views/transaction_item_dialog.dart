import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/models/transaction_item_model.dart';
import 'package:salesman_mobile/app/modules/transaction/controllers/transaction_controller.dart';

class TransactionItemDialog extends StatefulWidget {
  final TransactionItemModel? item;
  final int? index;
  final ProductModel? initialProduct;
  final int initialQuantity;
  final double initialPrice;
  final bool isEditing;

  const TransactionItemDialog({
    Key? key,
    this.item,
    this.index,
    this.initialProduct,
    this.initialQuantity = 1,
    this.initialPrice = 0,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _TransactionItemDialogState createState() => _TransactionItemDialogState();
}

class _TransactionItemDialogState extends State<TransactionItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  ProductModel? _selectedProduct;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _selectedProduct = widget.item!.product;
      _quantityController.text = '${widget.item!.quantity}';
      _priceController.text = '${widget.item!.price}';
    } else if (widget.initialProduct != null) {
      _selectedProduct = widget.initialProduct;
      _quantityController.text = '${widget.initialQuantity}';
      _priceController.text = '${widget.initialPrice}';
    } else {
      _quantityController.text = '1';
      _priceController.text = '0';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    
    return AlertDialog(
      title: Text(widget.item == null ? 'Tambah Item' : 'Edit Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Selection
              DropdownButtonFormField<ProductModel>(
                decoration: const InputDecoration(
                  labelText: 'Produk *',
                  border: OutlineInputBorder(),
                ),
                value: _selectedProduct,
                items: controller.products.map((product) {
                  return DropdownMenuItem<ProductModel>(
                    value: product,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                    if (value != null) {
                      _priceController.text = value.price.toString();
                    }
                  });
                },
                validator: (value) {
                  if (value == null) return 'Pilih produk';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Price
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Satuan *',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan harga';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Harga tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              // Subtotal
              Obx(() {
                final qty = int.tryParse(_quantityController.text) ?? 0;
                final price = double.tryParse(_priceController.text) ?? 0;
                final subtotal = qty * price;
                
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (match) => '${match[1]}.',
                      )}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      actions: [
        _buildButtons(),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        if (widget.isEditing) ...[
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () {
                // Return false to indicate delete action
                Get.back(result: false);
              },
              child: const Text('Hapus'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveItem,
            child: Text(widget.isEditing ? 'Update' : 'Simpan'),
          ),
        ),
      ],
    );
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState?.validate() ?? false) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0;

      if (_selectedProduct == null) {
        Get.snackbar('Error', 'Pilih produk terlebih dahulu');
        return;
      }

      if (quantity <= 0) {
        Get.snackbar('Error', 'Jumlah tidak valid');
        return;
      }

      if (price <= 0) {
        Get.snackbar('Error', 'Harga tidak valid');
        return;
      }

      final controller = Get.find<TransactionController>();
      _isLoading.value = true;

      try {
        if (widget.item != null) {
          // Update existing item
          await controller.updateTransactionItem(
            index: widget.index!,
            product: _selectedProduct!,
            quantity: quantity,
            price: price,
          );
        } else if (widget.isEditing) {
          // Update item in create form
          final updatedItem = TransactionItemModel(
            id: 0, // Temporary ID
            transactionId: 0, // Will be set when creating transaction
            productId: _selectedProduct!.id,
            product: _selectedProduct!,
            quantity: quantity,
            price: price,
            subtotal: price * quantity,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          );
          Get.back(result: updatedItem);
          return;
        } else {
          // Add new item
          await controller.addTransactionItem(
            product: _selectedProduct!,
            quantity: quantity,
            price: price,
          );
        }
        _isLoading.value = false;
        Get.back(result: true);
      } catch (e) {
        _isLoading.value = false;
        Get.snackbar('Error', 'Gagal menyimpan item: $e');
      }
    }
  }
}
