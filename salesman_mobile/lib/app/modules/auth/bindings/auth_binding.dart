import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/auth_repository.dart';

import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  final String? tag;

  AuthBinding({this.tag});

  @override
  void dependencies() {
    final authRepo = AuthRepository();

    // Initialize controller with dependencies
    Get.lazyPut<AuthController>(() => AuthController(authRepository: authRepo), tag: tag);
  }
}
