import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';
import 'package:salesman_mobile/app/data/repositories/transaction_repository.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Initialize API Service
    await Get.putAsync(() => ApiService().init());
    
    // Initialize Repositories
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => StoreRepository(), fenix: true);
    Get.lazyPut(() => ProductRepository(), fenix: true);
    Get.lazyPut(() => ConsignmentRepository(), fenix: true);
    Get.lazyPut(() => TransactionRepository(), fenix: true);
  }
}
