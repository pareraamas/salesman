import 'package:get/get.dart';
import '../controllers/consignment_edit_controller.dart';

class ConsignmentEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsignmentEditController>(
      () => ConsignmentEditController(),
    );
  }
}
