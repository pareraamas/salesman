part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();

  // Auth
  static const LOGIN = _Paths.LOGIN;
  
  // Main
  static const DASHBOARD = _Paths.DASHBOARD;
  static const HOME = _Paths.HOME;
  
  // Features
  static const STORES = _Paths.STORES;
  static const STORE_DETAIL = _Paths.STORE_DETAIL;
  static const PRODUCTS = _Paths.PRODUCTS;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const CONSIGNMENTS = _Paths.CONSIGNMENTS;
  static const CONSIGNMENT_DETAIL = _Paths.CONSIGNMENT_DETAIL;
  static const TRANSACTIONS = _Paths.TRANSACTIONS;
  static const TRANSACTION_DETAIL = _Paths.TRANSACTION_DETAIL;
  static const REPORTS = _Paths.REPORTS;
  static const PROFILE = _Paths.PROFILE;
}

abstract class _Paths {
  _Paths._();

  // Auth
  static const LOGIN = '/login';
  
  // Main
  static const DASHBOARD = '/dashboard';
  static const HOME = '/home';
  
  // Features
  static const STORES = '/stores';
  static const STORE_DETAIL = '/stores/:id';
  static const PRODUCTS = '/products';
  static const PRODUCT_DETAIL = '/products/:id';
  static const CONSIGNMENTS = '/consignments';
  static const CONSIGNMENT_DETAIL = '/consignments/:id';
  static const TRANSACTIONS = '/transactions';
  static const TRANSACTION_DETAIL = '/transactions/:id';
  static const REPORTS = '/reports';
  static const PROFILE = '/profile';
}
