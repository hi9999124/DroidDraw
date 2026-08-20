import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layers/document_controller.dart';
import 'canvas_painter.dart';

/// The main drawing surface: infinitely pannable, pinch-zoomable, and
/// isolated in its own [RepaintBoundary] so layer-panel and toolbar
/// rebuilds never touch it.
///
/// Pan/zoom is handled entirely by [InteractiveViewer] applying a
/// GPU-composited transform to the child — it never calls back into
/// [CustomPainter.paint]. The painter only re-runs when the layer stack
/// itself changes (add/delete/reorder/edit a layer), which is exactly when
/// this widget rebuilds via `context.watch`.
class InfiniteCanvas extends StatefulWidget {
  const InfiniteCanvas({super.key});

  @override
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  // Kept in State (not recreated on rebuild) so pan/zoom position survives
  // layer-stack edits; also gives future toolbar actions (e.g. "fit to
  // screen") something to drive.
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = context.watch<DocumentController>();
    final canvasSize = Size(
      document.canvasWidth.toDouble(),
      document.canvasHeight.toDouble(),
    );

    return ColoredBox(
      color: const Color(0xFF17171A),
      child: InteractiveViewer(
        transformationController: _transformController,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.05,
        maxScale: 16,
        child: RepaintBoundary(
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: CustomPaint(
              painter: DroidDrawCanvasPainter(
                layers: document.layers,
                canvasSize: canvasSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
