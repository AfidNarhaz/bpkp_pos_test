import 'package:bpkp_pos_test/router/routers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routers.splash,
      getPages: Routers.routes,
    ),
  );
}
