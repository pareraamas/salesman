import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  // Base URL from environment variable
  static String get baseUrl => dotenv.get('BASE_URL', fallback: 'http://localhost:8000/api');

  // Auth Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';
  static const String user = '/user';

  // Store Endpoints
  static const String stores = '/stores';
  static const String storeById = '/stores/';
  static const String storesList = '/stores/list';

  // Product Endpoints
  static const String products = '/products';
  static const String productById = '/products/';
  static const String productsList = '/products/list';

  // Consignment Endpoints
  static const String consignments = '/consignments';
  static const String consignmentById = '/consignments/';
  static const String consignmentsList = '/consignments/list';
  static const String activeConsignments = '/consignments/active';
  static const String consignmentTransactions = '/consignments/';

  // Transaction Endpoints
  static const String transactions = '/transactions';
  static const String transactionById = '/transactions/';
  static const String transactionsSummary = '/transactions/summary';

  // Helper method to get full URL
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
