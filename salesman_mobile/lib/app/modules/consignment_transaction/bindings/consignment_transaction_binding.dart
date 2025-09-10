import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_transaction_repository.dart';
import 'package:salesman_mobile/app/modules/consignment_transaction/controllers/consignment_transaction_controller.dart';

class ConsignmentTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsignmentTransactionRepository>(
      () => ConsignmentTransactionRepository(),
      fenix: true,
    );
    Get.lazyPut<ConsignmentTransactionController>(
      () => ConsignmentTransactionController(),
    );
  }
}
