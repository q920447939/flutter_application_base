import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../ui/page/error_screen.dart';

class ErrorRoute extends GoRouteData {
  ErrorRoute({required this.error});

  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ErrorScreenPage(error: error);
}
