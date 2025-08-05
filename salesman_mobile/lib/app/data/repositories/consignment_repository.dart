import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/consignment_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class ConsignmentRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  /// Get list of consignments with optional filters
  Future<Map<String, dynamic>> getConsignments({
    int? page,
    int? limit,
    String? search,
    String? status,
    int? storeId,
    int? productId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiUrl.consignments,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'status': status,
          'store_id': storeId,
          'product_id': productId,
        }..removeWhere((key, value) => value == null),
      );
      
      if (response['success'] == true) {
        final responseData = response['data'] is Map ? response['data'] : response;
        final dataList = responseData['data'] is List ? responseData['data'] : [];
        
        final consignments = (dataList as List)
            .map((consignment) => ConsignmentModel.fromJson(consignment))
            .toList();
            
        return {
          'success': true,
          'data': consignments,
          'pagination': responseData['meta'] ?? {},
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Gagal memuat data konsinyasi',
        'errors': response['errors'],
      };
    } catch (e) {
      _logger.e('Get consignments error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memuat data konsinyasi',
      };
    }
  }

  Future<Map<String, dynamic>> getConsignmentById(int id) async {
    try {
      final response = await _apiService.get('${ApiUrl.consignmentById}$id');
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ConsignmentModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch consignment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createConsignment(ConsignmentModel consignment) async {
    try {
      final response = await _apiService.post(
        ApiUrl.consignments,
        data: consignment.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ConsignmentModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create consignment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateConsignment(ConsignmentModel consignment) async {
    try {
      final response = await _apiService.put(
        '${ApiUrl.consignmentById}${consignment.id}',
        data: consignment.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ConsignmentModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update consignment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteConsignment(int id) async {
    try {
      final response = await _apiService.delete('${ApiUrl.consignmentById}$id');
      
      if (response['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete consignment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateConsignmentStatus({
    required int id,
    required String status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiUrl.consignmentById}$id/update-status',
        data: {
          'status': status,
          'notes': notes,
        },
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ConsignmentModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update consignment status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
