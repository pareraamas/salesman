import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/product_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class ProductRepository extends GetxService {
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

  /// Get list of products with pagination and search
  Future<Map<String, dynamic>> getProducts({
    int? page, 
    int? limit, 
    String? search,
    int? storeId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiUrl.products,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
        },
      );
      
      if (response['success'] == true) {
        final responseData = response['data'] is Map ? response['data'] : response;
        final dataList = responseData['data'] is List ? responseData['data'] : [];
        
        final products = (dataList as List)
            .map((product) => ProductModel.fromJson(product))
            .toList();
        
        return {
          'success': true,
          'data': products,
          'pagination': responseData['meta'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Gagal memuat data produk',
          'errors': response['errors'],
        };
      }
    } catch (e) {
      _logger.e('Get products error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memuat data produk',
      };
    }
  }

  Future<Map<String, dynamic>> getProductById(int id) async {
    try {
      final response = await _apiService.get('${ApiUrl.productById}$id');
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ProductModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch product',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createProduct(ProductModel product) async {
    try {
      final response = await _apiService.post(
        ApiUrl.products,
        data: product.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ProductModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create product',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateProduct(ProductModel product) async {
    try {
      final response = await _apiService.put(
        '${ApiUrl.productById}${product.id}',
        data: product.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': ProductModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update product',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      final response = await _apiService.delete('${ApiUrl.productById}$id');
      
      if (response['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete product',
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
