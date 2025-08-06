import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class StoreRepository {
  final ApiService _apiService;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  StoreRepository({required ApiService api}) : _apiService = api;

  /// Get list of stores with pagination and search
  Future<AppResponse<Map<String, dynamic>>> getStores({
    int? page, 
    int? limit, 
    String? search,
    bool? activeOnly,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiUrl.stores,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'active_only': activeOnly,
        }..removeWhere((key, value) => value == null),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        final dataList = response.data!['data'] is List ? response.data!['data'] : [];
        final stores = (dataList as List)
            .map((store) => StoreModel.fromJson(store))
            .toList();
        
        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'stores': stores,
            'pagination': response.data!['meta'] ?? {},
          },
        );
      }
      
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: response.message ?? 'Gagal memuat data toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get stores error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data toko',
      );
    }
  }

  Future<AppResponse<StoreModel>> getStoreById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.storeById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<StoreModel>(
        success: false,
        message: response.message ?? 'Gagal mengambil data toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get store by id error: $e');
      return AppResponse<StoreModel>(
        success: false,
        message: 'Terjadi kesalahan saat mengambil data toko',
      );
    }
  }

  Future<AppResponse<StoreModel>> createStore(StoreModel store) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiUrl.stores,
        data: store.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<StoreModel>(
        success: false,
        message: response.message ?? 'Gagal membuat toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Create store error: $e');
      return AppResponse<StoreModel>(
        success: false,
        message: 'Terjadi kesalahan saat membuat toko',
      );
    }
  }

  Future<AppResponse<StoreModel>> updateStore(StoreModel store) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiUrl.storeById}${store.id}',
        data: store.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<StoreModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update store error: $e');
      return AppResponse<StoreModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui toko',
      );
    }
  }

  Future<AppResponse<void>> deleteStore(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiUrl.storeById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success) {
        return AppResponse<void>(success: true);
      }
      
      return AppResponse<void>(
        success: false,
        message: response.message ?? 'Gagal menghapus toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Delete store error: $e');
      return AppResponse<void>(
        success: false,
        message: 'Terjadi kesalahan saat menghapus toko',
      );
    }
  }
}
