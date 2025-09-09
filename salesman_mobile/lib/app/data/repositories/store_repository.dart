import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/core/api_url.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/store_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';

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

  /// Get list of stores with optional filtering
  Future<AppResponse<List<StoreModel>>> getStores({
    int? page,
    int? perPage = 15,
    String? search,
    int? storeId,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        ApiUrl.stores,
        queryParameters: {
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
          if (search != null && search.isNotEmpty) 'search': search,
          if (storeId != null) 'store_id': storeId,
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
          message: response.message,
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

  /// Get store by ID
  Future<AppResponse<StoreModel>> getStoreById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiUrl.storeById(id),
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        final storeData = response.data!['data'];
        if (storeData != null) {
          return AppResponse<StoreModel>(
            success: true,
            data: StoreModel.fromJson(storeData),
            message: response.message,
          );
        }
      }

      return AppResponse<StoreModel>(
        success: false,
        message: response.data?['message'] ?? 'Gagal memuat detail toko',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get store by ID error: $e');
      return AppResponse<StoreModel>(
        success: false,
        message: 'Terjadi kesalahan saat memuat detail toko',
      );
    }
  }

  /// Get nearest stores based on current location
  Future<AppResponse<List<StoreModel>>> getNearestStores({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        ApiUrl.nearestStores,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          if (radius != null) 'radius': radius,
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
          message: response.message,
        );
      }

      return AppResponse<List<StoreModel>>(
        success: false,
        message: response.message ?? 'Gagal memuat toko terdekat',
        errors: response.errors,
      );
    } catch (e) {
      _logger.e('Get nearest stores error: $e');
      return AppResponse<List<StoreModel>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat toko terdekat',
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
          data: StoreModel.fromJson(response.data!['data'] ?? response.data!),
          message: response.message,
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
        ApiUrl.storeById(store.id),
        data: store.toJson(),
        fromJsonT: (json) => json,
      );

      if (response.success && response.data != null) {
        return AppResponse<StoreModel>(
          success: true,
          data: StoreModel.fromJson(response.data!['data'] ?? response.data!),
          message: response.message,
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
        ApiUrl.storeById(id),
        fromJsonT: (json) => json,
      );

      if (response.success) {
        return AppResponse<void>(
          success: true,
          message: response.message,
        );
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
