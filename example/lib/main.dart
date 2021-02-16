import 'package:flutter/material.dart';
import 'package:flutter_control/core.dart';

import 'custom_header.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ControlRoot(
      states: [
        AppState.main.build((context) => CustomHeaderPage()),
      ],
      app: (setup, home) => MaterialApp(
        key: setup.key,
        home: home,
        theme: setup.theme,
      ),
    );
  }
}
