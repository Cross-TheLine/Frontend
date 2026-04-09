import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

enum AppScreenOrientation {
  portrait, //세로
  guide, //둘다
  landscape, //가로
}

mixin ScreenOrientationMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  AppScreenOrientation get screenOrientation;

  bool _subscribed = false;

  void _applyOrientation() {
    switch (screenOrientation) { 
      case AppScreenOrientation.portrait: // 세로 모드 고정
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
        ]);
        break;

      case AppScreenOrientation.guide: // 가로 모드 감지 
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;

      case AppScreenOrientation.landscape: // 가로 모드 고정
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        break;
    }
  }
  

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_subscribed) {
      final route = ModalRoute.of(context);
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _subscribed = true;
      }
    }

    _applyOrientation();
  }

  @override
  void didPush() {
    _applyOrientation();
  }

  @override
  void didPopNext() {
    _applyOrientation();
  }

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void dispose() {
    if (_subscribed) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }
}