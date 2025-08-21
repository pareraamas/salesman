import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final authRepo = Get.find<AuthRepository>();
    Get.lazyPut<HomeController>(() => HomeController(authRepository: authRepo));
  }
}
