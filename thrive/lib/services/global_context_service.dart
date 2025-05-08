import 'package:flutter/widgets.dart';

class GlobalContextService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get globalContext {
    return navigatorKey.currentContext!;
  }
}
