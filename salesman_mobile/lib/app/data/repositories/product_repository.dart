import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class ProductRepository {
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

  ProductRepository({required ApiService api}) : _apiService = api;

  /// Get list of products with pagination and search
  Future<AppResponse<Map<String, dynamic>>> getProducts({
    int? page, 
    int? limit, 
    String? search,
    int? storeId,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiUrl.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'store_id': storeId,
        }..removeWhere((key, value) => value == null),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        final dataList = response.data!['data'] is List ? response.data!['data'] : [];
        final products = (dataList as List)
            .map((product) => ProductModel.fromJson(product))
            .toList();
        
        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'products': products,
            'pagination': response.data!['meta'] ?? {},
          },
        );
      }
      
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: response.message ?? 'Gagal memuat data produk',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get products error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data produk',
      );
    }
  }

  Future<AppResponse<ProductModel>> getProductById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.productById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<ProductModel>(
          success: true,
          data: ProductModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ProductModel>(
        success: false,
        message: response.message ?? 'Gagal mengambil data produk',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get product by id error: $e');
      return AppResponse<ProductModel>(
        success: false,
        message: 'Terjadi kesalahan saat mengambil data produk',
      );
    }
  }

  Future<AppResponse<ProductModel>> createProduct(ProductModel product) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiUrl.products,
        data: product.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<ProductModel>(
          success: true,
          data: ProductModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ProductModel>(
        success: false,
        message: response.message ?? 'Gagal membuat produk',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Create product error: $e');
      return AppResponse<ProductModel>(
        success: false,
        message: 'Terjadi kesalahan saat membuat produk',
      );
    }
  }

  Future<AppResponse<ProductModel>> updateProduct(ProductModel product) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiUrl.productById}${product.id}',
        data: product.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success && response.data != null) {
        return AppResponse<ProductModel>(
          success: true,
          data: ProductModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<ProductModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui produk',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update product error: $e');
      return AppResponse<ProductModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui produk',
      );
    }
  }

  Future<AppResponse<void>> deleteProduct(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiUrl.productById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );
      
      if (response.success) {
        return AppResponse<void>(success: true);
      }
      
      return AppResponse<void>(
        success: false,
        message: response.message ?? 'Gagal menghapus produk',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Delete product error: $e');
      return AppResponse<void>(
        success: false,
        message: 'Terjadi kesalahan saat menghapus produk',
      );
    }
  }
}
