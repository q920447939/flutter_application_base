import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'bottom_bar_navigator.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  GoRouterState state;
  final Widget? child;
  ScaffoldWithNavBar({required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: BottomBarNavigator());
  }
}
