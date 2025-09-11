import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';
import 'package:salesman_mobile/app/data/repositories/transaction_repository.dart';
import 'package:salesman_mobile/app/modules/transaction/controllers/transaction_controller.dart';

class TransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionController>(
      () => TransactionController(
        transactionRepository: Get.find<TransactionRepository>(),
        storeRepository: Get.find<StoreRepository>(),
        productRepository: Get.find<ProductRepository>(),
        consignmentRepository: Get.find<ConsignmentRepository>(),
      ),
    );
    
    // Register repositories if not already registered
    Get.lazyPut<ConsignmentRepository>(() => ConsignmentRepository(), fenix: true);
  }
}
