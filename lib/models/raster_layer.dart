import 'dart:ui' as ui;

import 'blend_mode.dart';
import 'layer.dart';

/// A bitmap layer.
///
/// Phase 1 only carries the canvas-sized pixel buffer as an optional
/// [ui.Image]; the brush engine landing in Phase 2 is what actually paints
/// into it. Until then a raster layer renders as an empty (fully
/// transparent) sheet sized [width] x [height].
class RasterLayer extends Layer {
  RasterLayer({
    required super.id,
    required super.name,
    required this.width,
    required this.height,
    this.image,
    super.visible,
    super.opacity,
    super.blendMode,
  });

  final int width;
  final int height;

  /// Rendered pixel content. Null until a brush/fill tool paints into it.
  final ui.Image? image;

  @override
  LayerType get type => LayerType.raster;

  @override
  RasterLayer copyWith({
    String? name,
    bool? visible,
    double? opacity,
    LayerBlendMode? blendMode,
    ui.Image? image,
  }) {
    return RasterLayer(
      id: id,
      name: name ?? this.name,
      width: width,
      height: height,
      image: image ?? this.image,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
    );
  }
}
