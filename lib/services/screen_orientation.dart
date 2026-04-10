import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final RouteObserver<ModalRoute<dynamic>> appRouteObserver =
    RouteObserver<ModalRoute<dynamic>>();

enum AppScreenOrientation {
  portrait, //세로
  guide, //둘다
  landscape, //가로
}

Future<void> applyAppScreenOrientation(AppScreenOrientation orientation) {
  return SystemChrome.setPreferredOrientations(
    _preferredOrientationsFor(orientation),
  );
}

Future<void> waitForAppliedOrientation(
  BuildContext context,
  AppScreenOrientation orientation, {
  Duration timeout = const Duration(milliseconds: 700),
}) async {
  if (orientation == AppScreenOrientation.guide) {
    return;
  }

  if (!_isContextMounted(context) ||
      _isUiOrientationMatched(context, orientation)) {
    return;
  }

  final Completer<void> completer = Completer<void>();
  final _OrientationMetricsObserver observer = _OrientationMetricsObserver(
    onMetricsChanged: () {
      if (!_isContextMounted(context) || completer.isCompleted) {
        return;
      }

      if (_isUiOrientationMatched(context, orientation)) {
        completer.complete();
      }
    },
  );

  WidgetsBinding.instance.addObserver(observer);

  try {
    await Future.any<void>([
      completer.future,
      Future<void>.delayed(timeout),
    ]);
  } finally {
    WidgetsBinding.instance.removeObserver(observer);
  }
}

List<DeviceOrientation> _preferredOrientationsFor(
  AppScreenOrientation orientation,
) {
  switch (orientation) {
    case AppScreenOrientation.portrait:
      return const [
        DeviceOrientation.portraitUp,
      ];

    case AppScreenOrientation.guide:
      return const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];

    case AppScreenOrientation.landscape:
      return const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
  }
}

bool _isUiOrientationMatched(
  BuildContext context,
  AppScreenOrientation orientation,
) {
  if (orientation == AppScreenOrientation.guide) {
    return true;
  }

  final Size size = View.of(context).physicalSize;
  final bool isPortrait = size.height >= size.width;

  switch (orientation) {
    case AppScreenOrientation.portrait:
      return isPortrait;
    case AppScreenOrientation.landscape:
      return !isPortrait;
    case AppScreenOrientation.guide:
      return true;
  }
}

bool _isContextMounted(BuildContext context) {
  return context is Element ? context.mounted : true;
}

class _OrientationMetricsObserver with WidgetsBindingObserver {
  _OrientationMetricsObserver({required this.onMetricsChanged});

  final VoidCallback onMetricsChanged;

  @override
  void didChangeMetrics() {
    onMetricsChanged();
  }
}

mixin ScreenOrientationMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  AppScreenOrientation get screenOrientation;

  bool _subscribed = false;

  void _applyOrientation() {
    applyAppScreenOrientation(screenOrientation);
  }

  void _applyOrientationAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _applyOrientation();
    });
  }

  @override
  void initState() {
    super.initState();
    _applyOrientation();
    _applyOrientationAfterFrame();
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
    _applyOrientationAfterFrame();
  }

  @override
  void didPush() {
    _applyOrientation();
    _applyOrientationAfterFrame();
  }

  @override
  void didPopNext() {
    _applyOrientation();
    _applyOrientationAfterFrame();
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
