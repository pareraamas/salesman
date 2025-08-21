import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/product_repository.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/modules/product/controllers/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize API Service if not already initialized
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    
    // Initialize Repository
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(api: Get.find<ApiService>()),
      fenix: true,
    );
    
    // Initialize Controller
    Get.lazyPut<ProductController>(
      () => ProductController(productRepository: Get.find()),
      fenix: true,
    );
  }
}
