import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:salesman_mobile/app/data/models/app_response.dart';
import 'package:salesman_mobile/app/data/models/consignment_transaction_model.dart';
import 'package:salesman_mobile/app/data/sources/api_service.dart';
import 'package:salesman_mobile/app/core/api_url.dart';

class ConsignmentTransactionRepository {
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

  /// Get list of consignment transactions
  Future<AppResponse<List<ConsignmentTransactionModel>>> getConsignmentTransactions(
    int consignmentId, {
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiUrl.consignments}/$consignmentId/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
        }..removeWhere((key, value) => value == null),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final dataList = response.data!['data'] is List ? response.data!['data'] : [];
        final transactions = (dataList as List)
            .map((json) => ConsignmentTransactionModel.fromJson(json))
            .toList();

        return AppResponse<List<ConsignmentTransactionModel>>(
          success: true,
          data: transactions,
          message: response.message,
        );
      }

      return AppResponse<List<ConsignmentTransactionModel>>(
        success: false,
        message: response.message ?? 'Gagal memuat data transaksi konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Get consignment transactions error: $e');
      return AppResponse<List<ConsignmentTransactionModel>>(
        success: false,
        message: 'Terjadi kesalahan saat memuat data transaksi konsinyasi',
      );
    }
  }

  /// Create a new consignment transaction
  Future<AppResponse<ConsignmentTransactionModel>> createConsignmentTransaction(
    int consignmentId, {
    required String transactionType,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '${ApiUrl.consignments}/$consignmentId/transactions',
        data: {
          'transaction_type': transactionType,
          'quantity': quantity,
          'notes': notes,
        }..removeWhere((key, value) => value == null),
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return AppResponse<ConsignmentTransactionModel>(
          success: true,
          data: ConsignmentTransactionModel.fromJson(response.data!['data']),
          message: response.message,
        );
      }

      return AppResponse<ConsignmentTransactionModel>(
        success: false,
        message: response.message ?? 'Gagal membuat transaksi konsinyasi',
        errors: response.errors,
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.e('Create consignment transaction error: $e');
      return AppResponse<ConsignmentTransactionModel>(
        success: false,
        message: 'Terjadi kesalahan saat membuat transaksi konsinyasi',
      );
    }
  }
}
