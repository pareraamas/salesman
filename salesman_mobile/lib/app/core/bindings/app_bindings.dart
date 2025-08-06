import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/data/repositories/transaction_repository.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize API Service
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);

    // Initialize Repositories
    Get.lazyPut<AuthRepository>(() => AuthRepository(), fenix: true);

    Get.lazyPut<StoreRepository>(() => StoreRepository(api: Get.find<ApiService>()), fenix: true);

    Get.lazyPut<ProductRepository>(() => ProductRepository(api: Get.find<ApiService>()), fenix: true);

    // ConsignmentRepository and TransactionRepository use Get.find<ApiService>() directly
    // So we don't need to pass it through the constructor
    Get.lazyPut<ConsignmentRepository>(() => ConsignmentRepository(), fenix: true);

    Get.lazyPut<TransactionRepository>(() => TransactionRepository(), fenix: true);
  }
}
