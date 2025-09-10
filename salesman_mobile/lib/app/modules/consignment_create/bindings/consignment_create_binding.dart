import 'package:get/get.dart';
import '../controllers/consignment_create_controller.dart';

class ConsignmentCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsignmentCreateController>(
      () => ConsignmentCreateController(),
    );
  }
}
