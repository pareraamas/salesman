import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/transaction_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class TransactionRepository extends GetxService {
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

  /// Get list of transactions with filters
  Future<Map<String, dynamic>> getTransactions({
    int? page,
    int? limit,
    String? search,
    String? status,
    int? storeId,
    int? consignmentId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _apiService.get(
        ApiUrl.transactions,
        queryParameters: {
          'page': page,
          'limit': limit,
          'search': search,
          'status': status,
          'store_id': storeId,
          'consignment_id': consignmentId,
          'start_date': startDate,
          'end_date': endDate,
        }..removeWhere((key, value) => value == null),
      );
      
      if (response['success'] == true) {
        final responseData = response['data'] is Map ? response['data'] : response;
        final dataList = responseData['data'] is List ? responseData['data'] : [];
        
        final transactions = (dataList as List)
            .map((transaction) => TransactionModel.fromJson(transaction))
            .toList();
            
        return {
          'success': true,
          'data': transactions,
          'pagination': responseData['meta'] ?? {},
        };
      }
      
      return {
        'success': false,
        'message': response['message'] ?? 'Gagal memuat data transaksi',
        'errors': response['errors'],
      };
    } catch (e) {
      _logger.e('Get transactions error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat memuat data transaksi',
      };
    }
  }

  Future<Map<String, dynamic>> getTransactionById(int id) async {
    try {
      final response = await _apiService.get('${ApiUrl.transactionById}$id');
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': TransactionModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _apiService.post(
        ApiUrl.transactions,
        data: transaction.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': TransactionModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await _apiService.put(
        '${ApiUrl.transactionById}${transaction.id}',
        data: transaction.toJson(),
      );
      
      if (response['success'] == true) {
        return {
          'success': true,
          'data': TransactionModel.fromJson(response['data']['data']),
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update transaction',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteTransaction(int id) async {
    try {
      final response = await _apiService.delete('${ApiUrl.transactionById}$id');
      
      if (response['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete transaction',
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
