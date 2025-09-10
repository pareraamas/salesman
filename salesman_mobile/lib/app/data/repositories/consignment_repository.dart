import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class ConsignmentRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 50, colors: true, printEmojis: true));

  /// Get list of consignments with optional filters
  Future<AppResponse<Map<String, dynamic>>> getConsignments({int? page, int? limit, String? search, String? status, int? storeId, int? productId}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiUrl.consignments,
        queryParameters: {
          'page': page, 
          'limit': limit, 
          'search': search, 
          'status': status, 
          'store_id': storeId, 
          'product_id': productId
        }..removeWhere((key, value) => value == null),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final dataList = response.data!['data'] is List ? response.data!['data'] : [];
        final consignments = (dataList as List).map((json) => ConsignmentModel.fromJson(json)).toList();
        
        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'consignments': consignments,
            'pagination': response.data!['meta'] ?? {},
          },
        );
      }

      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: response.message ?? 'Gagal memuat data konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get consignments error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data konsinyasi',
      );
    }
  }

  Future<AppResponse<ConsignmentModel>> getConsignmentById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.consignmentById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<ConsignmentModel>(
          success: true,
          data: ConsignmentModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ConsignmentModel>(
        success: false,
        message: response.message ?? 'Gagal mengambil data konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get consignment by id error: $e');
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Terjadi kesalahan saat mengambil data konsinyasi',
      );
    }
  }

  Future<AppResponse<ConsignmentModel>> createConsignment(ConsignmentModel consignment) async {
    // Validasi input
    if (consignment.items.isEmpty) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Minimal ada satu produk dalam konsinyasi',
      );
    }
    
    if (consignment.status.isEmpty) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Status konsinyasi tidak boleh kosong',
      );
    }
    
    if (consignment.startDate.isAfter(DateTime.now())) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Tanggal mulai tidak boleh lebih besar dari hari ini',
      );
    }
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiUrl.consignments, 
        data: consignment.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<ConsignmentModel>(
          success: true,
          data: ConsignmentModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ConsignmentModel>(
        success: false,
        message: response.message ?? 'Gagal membuat konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Create consignment error: $e');
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Terjadi kesalahan saat membuat konsinyasi',
      );
    }
  }

  Future<AppResponse<ConsignmentModel>> updateConsignment(ConsignmentModel consignment) async {
    // Validasi input
    if (consignment.items.isEmpty) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Minimal ada satu produk dalam konsinyasi',
      );
    }
    
    if (consignment.status.isEmpty) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Status konsinyasi tidak boleh kosong',
      );
    }
    
    if (consignment.startDate.isAfter(DateTime.now())) {
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Tanggal mulai tidak boleh lebih besar dari hari ini',
      );
    }
    
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiUrl.consignmentById}${consignment.id}', 
        data: consignment.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<ConsignmentModel>(
          success: true,
          data: ConsignmentModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ConsignmentModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update consignment error: $e');
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui konsinyasi',
      );
    }
  }

  Future<AppResponse<void>> deleteConsignment(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiUrl.consignmentById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        return AppResponse<void>(success: true);
      }
      
      return AppResponse<void>(
        success: false,
        message: response.message ?? 'Gagal menghapus konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Delete consignment error: $e');
      return AppResponse<void>(
        success: false,
        message: 'Terjadi kesalahan saat menghapus konsinyasi',
      );
    }
  }

  Future<AppResponse<ConsignmentModel>> updateConsignmentStatus({required int id, required String status, String? notes}) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiUrl.consignmentById}$id/update-status', 
        data: {'status': status, 'notes': notes},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<ConsignmentModel>(
          success: true,
          data: ConsignmentModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ConsignmentModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui status konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update consignment status error: $e');
      return AppResponse<ConsignmentModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui status konsinyasi',
      );
    }
  }
}
