import 'package:get/get.dart';

import '../controllers/consignment_detail_controller.dart';

class ConsignmentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsignmentDetailController>(
      () => ConsignmentDetailController(),
    );
  }
}
