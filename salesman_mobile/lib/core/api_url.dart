class ApiUrl {
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String userProfile = '/api/auth/me';

  // Store endpoints
  static const String stores = '/api/stores';
  static String storeById(int id) => '$stores/$id';

  // Product endpoints
  static const String products = '/api/products';
  static String productById(int id) => '$products/$id';

  // Consignment endpoints
  static const String consignments = '/api/consignments';
  static String consignmentById(int id) => '$consignments/$id';
  static String consignmentStatus(int id) => '$consignments/$id/status';

  // Transaction endpoints
  static const String transactions = '/api/transactions';
  static String transactionById(int id) => '$transactions/$id';
  static String transactionItems(int transactionId) => '$transactions/$transactionId/items';
  
  // Report endpoints
  static const String reports = '/api/reports';
  static String salesReport = '$reports/sales';
  static String consignmentReport = '$reports/consignments';
}
