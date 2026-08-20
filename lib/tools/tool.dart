import 'dart:ui';

/// Contract every drawing tool (brush, pen, shape, eraser, ...) will
/// implement starting in Phase 2.
///
/// Nothing implements this yet — Phase 1 ships only the canvas, layer
/// system, and undo/redo scaffolding. This interface exists now so the
/// wiring is decided before any tool lands: a real implementation builds up
/// a `Command` (see lib/core/command.dart) as the pointer moves and hands it
/// to `CommandHistory.execute` on [onStrokeEnd], so a whole stroke becomes a
/// single undoable step instead of one command per pointer-move event.
abstract class Tool {
  /// Human-readable name shown in the toolbar.
  String get name;

  /// Called when the tool becomes the active tool, and when it stops being
  /// active, respectively.
  void onActivate() {}
  void onDeactivate() {}

  /// Pointer lifecycle in canvas-space coordinates (already transformed out
  /// of the InteractiveViewer viewport, into the active raster/vector
  /// layer's coordinate space).
  void onStrokeStart(Offset canvasPosition) {}
  void onStrokeUpdate(Offset canvasPosition) {}
  void onStrokeEnd() {}
}
