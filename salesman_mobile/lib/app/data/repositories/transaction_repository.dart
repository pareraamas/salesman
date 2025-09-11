import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/transaction_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class TransactionRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 50, colors: true, printEmojis: true));

  /// Get list of transactions with filters
  Future<AppResponse<Map<String, dynamic>>> getTransactions({
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
      final response = await _apiService.get<Map<String, dynamic>>(
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
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final dataList = response.data!['data'] is List ? response.data!['data'] : [];
        final transactions = (dataList as List)
            .map((transaction) => TransactionModel.fromJson(transaction))
            .toList();

        return AppResponse<Map<String, dynamic>>(
          success: true,
          data: {
            'transactions': transactions,
            'pagination': response.data!['meta'] ?? {},
          },
        );
      }

      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: response.message ?? 'Gagal memuat data transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get transactions error: $e');
      return AppResponse<Map<String, dynamic>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data transaksi',
      );
    }
  }

  Future<AppResponse<TransactionModel>> getTransactionById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.transactionById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<TransactionModel>(
          success: true,
          data: TransactionModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<TransactionModel>(
        success: false,
        message: response.message ?? 'Gagal mengambil data transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get transaction by id error: $e');
      return AppResponse<TransactionModel>(
        success: false,
        message: 'Terjadi kesalahan saat mengambil data transaksi',
      );
    }
  }

  Future<AppResponse<TransactionModel>> createTransaction(TransactionModel transaction) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiUrl.transactions, 
        data: transaction.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<TransactionModel>(
          success: true,
          data: TransactionModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<TransactionModel>(
        success: false,
        message: response.message ?? 'Gagal membuat transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Create transaction error: $e');
      return AppResponse<TransactionModel>(
        success: false,
        message: 'Terjadi kesalahan saat membuat transaksi',
      );
    }
  }

  Future<AppResponse<TransactionModel>> updateTransaction(TransactionModel transaction) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiUrl.transactionById}${transaction.id}', 
        data: transaction.toJson(),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<TransactionModel>(
          success: true,
          data: TransactionModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<TransactionModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update transaction error: $e');
      return AppResponse<TransactionModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui transaksi',
      );
    }
  }

  Future<AppResponse<void>> deleteTransaction(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiUrl.transactionById}$id',
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success) {
        return AppResponse<void>(success: true);
      }
      
      return AppResponse<void>(
        success: false,
        message: response.message ?? 'Gagal menghapus transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Delete transaction error: $e');
      return AppResponse<void>(
        success: false,
        message: 'Terjadi kesalahan saat menghapus transaksi',
      );
    }
  }

  Future<AppResponse<TransactionModel>> updateTransactionStatus(int id, String status) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '${ApiUrl.transactionById}$id/status',
        data: {'status': status},
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<TransactionModel>(
          success: true,
          data: TransactionModel.fromJson(response.data!['data']),
        );
      }
      
      return AppResponse<TransactionModel>(
        success: false,
        message: response.message ?? 'Gagal memperbarui status transaksi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Update transaction status error: $e');
      return AppResponse<TransactionModel>(
        success: false,
        message: 'Terjadi kesalahan saat memperbarui status transaksi',
      );
    }
  }
}
