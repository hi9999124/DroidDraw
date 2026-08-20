import 'blend_mode.dart';

enum LayerType { raster, vector }

/// Common interface for everything that can sit in the layer stack.
///
/// [RasterLayer] and [VectorLayer] (in this same directory) are the two
/// concrete implementations. The canvas painter and layer panel only ever
/// depend on this interface, so a third layer type (e.g. text or adjustment
/// layers) can be added later without touching either.
abstract class Layer {
  Layer({
    required this.id,
    required this.name,
    this.visible = true,
    double opacity = 1.0,
    this.blendMode = LayerBlendMode.normal,
  }) : _opacity = opacity.clamp(0.0, 1.0).toDouble();

  final String id;

  String name;
  bool visible;
  LayerBlendMode blendMode;

  double _opacity;
  double get opacity => _opacity;
  set opacity(double value) => _opacity = value.clamp(0.0, 1.0).toDouble();

  LayerType get type;

  /// Returns a copy with the given fields replaced.
  ///
  /// This is what powers undo/redo for layer-metadata edits: instead of
  /// snapshotting the whole document, [UpdateLayerCommand] snapshots one
  /// `Layer` object before and after the edit, which stays cheap no matter
  /// how large the canvas or how many layers exist.
  Layer copyWith({
    String? name,
    bool? visible,
    double? opacity,
    LayerBlendMode? blendMode,
  });
}
