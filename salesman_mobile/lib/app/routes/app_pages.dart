import 'package:get/get.dart';
import 'package:salesman_mobile/app/modules/auth/views/register_view.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import 'package:salesman_mobile/app/modules/product/bindings/product_binding.dart';
import 'package:salesman_mobile/app/modules/product/views/product_list_view.dart';
import 'package:salesman_mobile/app/modules/product/views/product_create_view.dart';
import 'package:salesman_mobile/app/modules/store/bindings/store_binding.dart';
import 'package:salesman_mobile/app/modules/store/views/store_detail_view.dart';
import 'package:salesman_mobile/app/modules/store/views/store_list_view.dart';
import 'package:salesman_mobile/app/core/middleware/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;
  static const HOME = Routes.HOME;

  static final routes = [
    // Auth Routes
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(tag: 'login'),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(tag: 'register'),
    ),

    // Main Routes
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
      children: [
        // Nested routes for home tabs if needed
      ],
    ),

    // Feature Routes
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => const ProductListView(),
      binding: ProductBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PRODUCT_CREATE,
      page: () => const ProductCreateView(),
      binding: ProductBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.STORES,
      page: () => const StoreListView(),
      binding: StoreBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.STORE_DETAIL,
      page: () => const StoreDetailView(),
      binding: StoreBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
