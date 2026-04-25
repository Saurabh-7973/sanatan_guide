import 'package:flutter/material.dart';

mixin NavLoggerMixin<T extends StatefulWidget> on State<T> {
  String get screenName;

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 OPEN  $screenName');
  }

  @override
  void dispose() {
    debugPrint('🔴 CLOSE $screenName');
    super.dispose();
  }
}
