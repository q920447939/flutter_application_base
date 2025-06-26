import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_base/ui/page/base/home/home_index_page.dart';
import 'package:go_router/go_router.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import '../../getx/controller/manager_gex_controller.dart';

part 'shell_default_router.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    bottomBarIndexLogic.setCurrIndex(0);
    return HomeIndexPage();
  }
}
