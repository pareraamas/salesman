import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class StoreRepository extends GetxService {
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

  /// Get list of stores with pagination and search
  Future<Map<String, dynamic>> getStores({
    int? page, 
    int? limit, 
    String? search,
    bool? activeOnly,
  }) async {
    try {
      final response = await _apiService.get(
        ApiUrl.stores,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );
      
      if (response['success'] == true) {
        final responseData = response['data'] is Map ? response['data'] : response;
        final dataList = responseData['data'] is List ? responseData['data'] : [];
        
        final stores = (dataList as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();
        
        return {
          'success': true,
          'data': stores,
          'pagination': responseData['meta'] ?? {},
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Gagal memuat data toko',
        'errors': response['errors'],
      };
    } catch (e) {
      _logger.e('Get stores error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memuat data toko',
      };
    }
  }

  Future<Map<String, dynamic>> getStoreById(int id) async {
    try {
      final response = await _apiService.get('${ApiUrl.storeById}$id');
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': StoreModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch store',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createStore(StoreModel store) async {
    try {
      final response = await _apiService.post(
        ApiUrl.stores,
        data: store.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': StoreModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create store',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateStore(StoreModel store) async {
    try {
      final response = await _apiService.put(
        '${ApiUrl.storeById}${store.id}',
        data: store.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': StoreModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update store',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteStore(int id) async {
    try {
      final response = await _apiService.delete('${ApiUrl.storeById}$id');
      
      if (response['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete store',
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
