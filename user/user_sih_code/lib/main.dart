import 'package:flutter/material.dart';

import 'controller/route/route_name_controller.dart';
import 'controller/route/routes_controller.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: RouteNameController.trialScreen,
      onGenerateRoute: RouteController.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
