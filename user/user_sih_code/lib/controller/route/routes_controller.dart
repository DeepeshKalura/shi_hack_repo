import 'package:flutter/material.dart';

import '../../view/screen/trial_screen.dart';
import 'route_name_controller.dart';

class RouteController {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNameController.trialScreen:
        return MaterialPageRoute(
          builder: (_) => const TrialScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
