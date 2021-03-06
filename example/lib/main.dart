import 'package:control_widgets/widgets.dart';
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
      initState: AppState.main,
      states: [
        AppState.main.build((context) => CustomHeaderPage()),
      ],
      app: (setup, home) => MaterialApp(
        key: setup.key,
        theme: setup.theme,
        onGenerateRoute: (settings) => ModalCardRoute(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: home,
          ),
          settings: settings,
        ),
      ),
    );
  }
}
