import 'package:bpkp_pos_test/view/auth/login_page.dart';
import 'package:bpkp_pos_test/view/home/home_page.dart';
import 'package:bpkp_pos_test/view/splash_page.dart';
import 'package:bpkp_pos_test/view/transaksi/transaksi_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get.dart';

class Routers {
  static const splash = '/splash';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const transaksi = '/transaksi';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: transaksi,
      page: () => const TransaksiPage(showBackButton: false),
    ),
  ];
}
