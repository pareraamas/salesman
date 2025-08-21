import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/data/sources/local_service.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

// Pastikan untuk menginisialisasi LocalService di main()
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await LocalService.init();
//   runApp(MyApp());
// }

class AuthMiddleware extends GetMiddleware {
  @override
  // Prioritas middleware, semakin kecil semakin diutamakan
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    developer.log('🔐 [AuthMiddleware] Memeriksa akses ke rute: $route', name: 'AUTH');

    // Daftar rute yang tidak memerlukan autentikasi
    final publicRoutes = [
      Routes.LOGIN,
      Routes.REGISTER,
      // Tambahkan rute publik lainnya di sini
    ];

    // Jika rute saat ini adalah rute publik, lanjutkan
    if (publicRoutes.contains(route)) {
      developer.log('✅ [AuthMiddleware] Rute publik, diizinkan: $route', name: 'AUTH');
      return null;
    }

    try {
      // Gunakan metode sinkron untuk mengecek status login
      final isLoggedIn = LocalService.isLoggedInSync();
      developer.log('🔍 [AuthMiddleware] Status login: $isLoggedIn', name: 'AUTH');

      // Jika belum login, arahkan ke halaman login
      if (!isLoggedIn) {
        developer.log('🚫 [AuthMiddleware] Belum login, mengarahkan ke login', name: 'AUTH');
        return const RouteSettings(name: Routes.LOGIN);
      }

      developer.log('✅ [AuthMiddleware] Sudah login, lanjutkan ke: $route', name: 'AUTH');
      // Jika sudah login, lanjutkan ke rute yang diminta
      return null;
    } catch (e) {
      developer.log('⚠️ [AuthMiddleware] Error saat memeriksa auth: $e', name: 'AUTH', error: e, stackTrace: StackTrace.current);
      // Default ke halaman login jika terjadi error
      return const RouteSettings(name: Routes.LOGIN);
    }
  }
}
