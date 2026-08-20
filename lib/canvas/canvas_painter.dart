import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' hide Layer;

import '../models/layer.dart';
import '../models/raster_layer.dart';
import '../models/vector_layer.dart';

/// Paints the layer stack, bottom to top, respecting each layer's
/// visibility, opacity and blend mode.
///
/// Receives an immutable snapshot of the layer list on every paint; the
/// caller ([InfiniteCanvas]) only rebuilds this when the stack actually
/// changes, not on every pointer event — panning and zooming never touch
/// this painter at all, since [InteractiveViewer] composites a transform on
/// the GPU instead of asking Flutter to repaint.
class DroidDrawCanvasPainter extends CustomPainter {
  DroidDrawCanvasPainter({
    required this.layers,
    required this.canvasSize,
  });

  final List<Layer> layers;
  final Size canvasSize;

  static const _checkerLight = Color(0xFF3A3A3F);
  static const _checkerDark = Color(0xFF2C2C30);
  static const double _checkerCell = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & canvasSize;
    canvas.save();
    canvas.clipRect(bounds);
    _paintCheckerboard(canvas, bounds);

    for (final layer in layers) {
      if (!layer.visible || layer.opacity <= 0) continue;
      _paintLayer(canvas, layer, bounds);
    }

    canvas.restore();
  }

  void _paintCheckerboard(Canvas canvas, Rect bounds) {
    final light = Paint()..color = _checkerLight;
    final dark = Paint()..color = _checkerDark;
    canvas.drawRect(bounds, light);

    var row = 0;
    for (double y = bounds.top; y < bounds.bottom; y += _checkerCell) {
      var col = row.isEven ? 1 : 0;
      for (double x = bounds.left; x < bounds.right; x += _checkerCell) {
        if (col.isOdd) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, _checkerCell, _checkerCell),
            dark,
          );
        }
        col++;
      }
      row++;
    }
  }

  void _paintLayer(Canvas canvas, Layer layer, Rect bounds) {
    // saveLayer's paint alpha implements layer opacity and its blendMode
    // implements Multiply/Screen/etc — both apply to the whole offscreen
    // layer at once when it's composited back in on restore().
    final layerPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, layer.opacity)
      ..blendMode = layer.blendMode.flutterBlendMode;
    canvas.saveLayer(bounds, layerPaint);

    if (layer is RasterLayer) {
      _paintRasterLayer(canvas, layer, bounds);
    } else if (layer is VectorLayer) {
      _paintVectorLayer(canvas, layer);
    }

    canvas.restore();
  }

  void _paintRasterLayer(Canvas canvas, RasterLayer layer, Rect bounds) {
    final image = layer.image;
    if (image == null) return;
    canvas.drawImage(image, bounds.topLeft, Paint());
  }

  void _paintVectorLayer(Canvas canvas, VectorLayer layer) {
    for (final shape in layer.shapes) {
      if (shape.fillColor != null) {
        canvas.drawPath(
          shape.path,
          Paint()
            ..color = shape.fillColor!
            ..style = PaintingStyle.fill,
        );
      }
      if (shape.strokeColor != null) {
        canvas.drawPath(
          shape.path,
          Paint()
            ..color = shape.strokeColor!
            ..style = PaintingStyle.stroke
            ..strokeWidth = shape.strokeWidth,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DroidDrawCanvasPainter oldDelegate) {
    return oldDelegate.canvasSize != canvasSize ||
        !listEquals(oldDelegate.layers, layers);
  }
}
