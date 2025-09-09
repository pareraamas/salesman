import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  // Base URL from environment variable
  static String get baseUrl => dotenv.get('API_URL', fallback: 'http://localhost:8000/api');

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';

  // Store Endpoints
  static const String stores = '/stores';
  static String storeById(int id) => '/stores/$id';
  static const String nearestStores = '/stores/nearest';

  // Product Endpoints
  static const String products = '/products';
  static String productById(int id) => '/products/$id';
  static const String productCategories = '/product-categories';

  // Consignment Endpoints
  static const String consignments = '/consignments';
  static String consignmentById(int id) => '/consignments/$id';
  static String consignmentTransactions(int id) => '/consignments/$id/transactions';

  // Transaction Endpoints
  static const String transactions = '/transactions';
  static String transactionById(int id) => '/transactions/$id';
  static const String transactionsSummary = '/transactions/summary';

  // Report Endpoints
  static const String reports = '/reports';
  static const String salesReport = '/reports/sales';
  static const String consignmentReport = '/reports/consignments';
  static const String performanceReport = '/reports/performance';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
