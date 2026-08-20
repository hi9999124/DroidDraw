import 'blend_mode.dart';
import 'layer.dart';
import 'vector_shape.dart';

/// A layer made of scalable vector shapes rather than pixels.
///
/// Shapes are immutable value objects; edits (from the future pen/shape
/// tools) replace entries in [shapes] rather than mutating a path in place,
/// which is what lets undo/redo work by swapping list snapshots instead of
/// diffing or copying pixel buffers.
class VectorLayer extends Layer {
  VectorLayer({
    required super.id,
    required super.name,
    List<VectorShape> shapes = const [],
    super.visible,
    super.opacity,
    super.blendMode,
  }) : shapes = List.unmodifiable(shapes);

  final List<VectorShape> shapes;

  @override
  LayerType get type => LayerType.vector;

  @override
  VectorLayer copyWith({
    String? name,
    bool? visible,
    double? opacity,
    LayerBlendMode? blendMode,
    List<VectorShape>? shapes,
  }) {
    return VectorLayer(
      id: id,
      name: name ?? this.name,
      shapes: shapes ?? this.shapes,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
    );
  }
}
