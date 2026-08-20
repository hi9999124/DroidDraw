import 'dart:ui' as ui;

/// A single vector shape: a path plus how it should be filled/stroked.
///
/// Kept intentionally simple for Phase 1 — just enough structure for the
/// vector layer type to exist and render. The pen/shape tools that create
/// and edit these land in a later phase.
class VectorShape {
  const VectorShape({
    required this.path,
    this.fillColor,
    this.strokeColor,
    this.strokeWidth = 2.0,
  });

  final ui.Path path;
  final ui.Color? fillColor;
  final ui.Color? strokeColor;
  final double strokeWidth;
}
