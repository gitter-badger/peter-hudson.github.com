import 'dart:html' as dom;
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:di/di.dart';
import 'package:logging/logging.dart';
import 'package:perf_api/perf_api.dart';

import 'lib/main_controller.dart';
import 'components/twitter/twitter.dart';



class MyAppModule extends Module {
  MyAppModule() {
    type(Twitter);
    type(MainController);
    type(Profiler, implementedBy: Profiler); // comment out to enable profiling
    type(RouteInitializer, implementedBy: PageRouteInitializer);
    factory(NgRoutingUsePushState,
        (_) => new NgRoutingUsePushState.value(false));
  }
}


class PageRouteInitializer implements RouteInitializer {

  init(Router router, ViewFactory view) {
    router.root
      ..addRoute(
        defaultRoute: true,        
        name: 'index',
        path: '/index',
        enter: view('dart/parts/index.html')
      )..addRoute(
        name: 'about',
        path: '/about',
        enter: view('dart/parts/about.html')
      );
  }
}


main() {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((LogRecord r) => print(r.message) );
  ngBootstrap(module: new MyAppModule());
}
