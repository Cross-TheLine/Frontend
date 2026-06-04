import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes.dart';
import '../../services/screen_orientation.dart';

class CameraOrientationHandoffScreen extends StatefulWidget {
  const CameraOrientationHandoffScreen({super.key});

  @override
  State<CameraOrientationHandoffScreen> createState() =>
      _CameraOrientationHandoffScreenState();
}

class _CameraOrientationHandoffScreenState
    extends State<CameraOrientationHandoffScreen> {
  bool _didStart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didStart) return;
      _didStart = true;
      _enterCamera();
    });
  }

  Future<void> _enterCamera() async {
    await applyAppScreenOrientation(AppScreenOrientation.landscape);

    if (!mounted) return;

    await waitForAppliedOrientation(
      context,
      AppScreenOrientation.landscape,
      timeout: const Duration(milliseconds: 1000),
    );

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.videoTake);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(),
      ),
    );
  }
}
