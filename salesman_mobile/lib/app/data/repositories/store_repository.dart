import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class StoreRepository {
  final ApiService _apiService;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 50, colors: true, printEmojis: true));

  StoreRepository({required ApiService api}) : _apiService = api;

  /// Get list of stores with pagination and search
  Future<AppResponse<List<StoreModel>>> getStores({
    int? page, 
    int? limit, 
    String? search,
    bool? activeOnly,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        ApiUrl.stores,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (activeOnly != null) 'active_only': activeOnly,
        },
        fromJsonT: (json) => json as List<dynamic>,
      );
      
      if (response.success && response.data != null) {
        final stores = (response.data as List)
            .map((store) => StoreModel.fromJson(store as Map<String, dynamic>))
            .toList();
        
        return AppResponse<List<StoreModel>>(
          success: true,
          data: stores,
          meta: response.meta,
        );
      }
      
      return AppResponse<List<StoreModel>>(
        success: false,
        message: response.message ?? 'Gagal memuat data toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get stores error: $e');
      return AppResponse<List<StoreModel>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data toko',
      );
    }
  }

  Future<AppResponse<StoreModel>> getStoreById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.storeById}$id',
        fromJsonT: (json) => json,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!),
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
        fromJsonT: (json) => json,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!),
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
        fromJsonT: (json) => json,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!),
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
        fromJsonT: (json) => json,
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
