import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class RootRouteObserver extends AutoRouteObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('New route pushed: ${route.settings.name}');
  }

  // only override to observer tab routes
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    debugPrint('Tab route visited: ${route.name}');
  }

  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    debugPrint('Tab route re-visited: ${route.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint(
      'Route popped: from: ${route.settings.name} to: ${previousRoute?.settings.name}',
    );
  }
}
