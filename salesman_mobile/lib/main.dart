import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:salesman_mobile/app/core/bindings/app_bindings.dart';
import 'package:salesman_mobile/app/routes/app_pages.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize bindings

  runApp(
    GetMaterialApp(
      title: dotenv.get('APP_NAME', fallback: 'Salesman App'),
      initialRoute: AppPages.INITIAL,
      initialBinding: AppBindings(),
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
    ),
  );
}
