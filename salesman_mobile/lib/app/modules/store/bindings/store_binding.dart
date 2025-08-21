import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/store_repository.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/modules/store/controllers/store_controller.dart';

class StoreBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreRepository>(
      () => StoreRepository(api: Get.find<ApiService>()),
    );
    
    Get.lazyPut<StoreController>(
      () => StoreController(
        storeRepository: Get.find<StoreRepository>(),
      ),
    );
  }
}
