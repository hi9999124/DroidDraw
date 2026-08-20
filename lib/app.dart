import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'layers/document_controller.dart';
import 'theme/app_theme.dart';

/// Root widget: wires up the document (layers + undo/redo) provider and the
/// app-wide dark theme, then hands off to [HomeScreen].
class DroidDrawApp extends StatelessWidget {
  const DroidDrawApp({super.key});

  static const int defaultCanvasWidth = 2048;
  static const int defaultCanvasHeight = 2048;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentController(
        canvasWidth: defaultCanvasWidth,
        canvasHeight: defaultCanvasHeight,
      ),
      child: MaterialApp(
        title: 'DroidDraw',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
