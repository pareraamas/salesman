import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';
import 'package:salesman_mobile/app/modules/consignment/controllers/consignment_controller.dart';

class ConsignmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsignmentController>(
      () => ConsignmentController(
        consignmentRepository: ConsignmentRepository(),
      ),
    );
  }
}
