import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/repositories/consignment_repository.dart';

class ConsignmentController extends GetxController {
  final ConsignmentRepository _consignmentRepository;
  
  // Reactive state
  final RxList<ConsignmentModel> consignments = <ConsignmentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> filters = <String, dynamic>{
    'store_id': null,
    'product_id': null,
    'status': null,
    'search': null,
    'page': 1,
    'limit': 15,
  }.obs;

  ConsignmentController({required ConsignmentRepository consignmentRepository})
      : _consignmentRepository = consignmentRepository;

  @override
  void onInit() {
    super.onInit();
    fetchConsignments();
  }

  // Fetch consignments with current filters
  Future<void> fetchConsignments() async {
    try {
      if (isLoading.value) return;
      
      isLoading.value = true;
      errorMessage.value = '';
      
      // Convert store_id and product_id to int if they are not null
      final storeId = filters['store_id'] != null ? int.tryParse(filters['store_id'].toString()) : null;
      final productId = filters['product_id'] != null ? int.tryParse(filters['product_id'].toString()) : null;
      
      final response = await _consignmentRepository.getConsignments(
        storeId: storeId,
        productId: productId,
        status: filters['status'],
        page: filters['page'],
        limit: filters['limit'],
        search: filters['search'],
      );
      
      if (response.success && response.data != null) {
        final data = response.data!;
        final items = data['consignments'] as List<ConsignmentModel>? ?? [];
        
        if (filters['page'] == 1) {
          consignments.assignAll(items);
        } else {
          consignments.addAll(items);
        }
        
        // Update pagination
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        hasMore.value = (pagination['current_page'] ?? 0) < (pagination['last_page'] ?? 1);
      } else {
        errorMessage.value = response.message ?? 'Gagal memuat data konsinyasi';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Update filter and refresh data
  void updateFilter(String key, dynamic value) {
    filters[key] = value;
    filters['page'] = 1; // Reset to first page when filter changes
    fetchConsignments();
  }

  // Load more data for pagination
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    
    try {
      filters['page'] = (filters['page'] as int) + 1;
      await fetchConsignments();
    } catch (e) {
      errorMessage.value = 'Gagal memuat data tambahan: $e';
      filters['page'] = (filters['page'] as int) - 1; // Revert page on error
    }
  }
}
