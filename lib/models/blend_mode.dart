import 'dart:ui' as ui;

/// The set of blend modes exposed in the layer panel.
///
/// Wraps [ui.BlendMode] so the UI offers a curated, illustration-app-style
/// vocabulary (Normal/Multiply/Screen and a few extras) instead of Flutter's
/// full blend mode enum, most of which (e.g. `clear`, `dstIn`) make no sense
/// for a layer stack.
enum LayerBlendMode {
  normal,
  multiply,
  screen,
  overlay,
  darken,
  lighten;

  ui.BlendMode get flutterBlendMode {
    switch (this) {
      case LayerBlendMode.normal:
        return ui.BlendMode.srcOver;
      case LayerBlendMode.multiply:
        return ui.BlendMode.multiply;
      case LayerBlendMode.screen:
        return ui.BlendMode.screen;
      case LayerBlendMode.overlay:
        return ui.BlendMode.overlay;
      case LayerBlendMode.darken:
        return ui.BlendMode.darken;
      case LayerBlendMode.lighten:
        return ui.BlendMode.lighten;
    }
  }

  String get label {
    switch (this) {
      case LayerBlendMode.normal:
        return 'Normal';
      case LayerBlendMode.multiply:
        return 'Multiply';
      case LayerBlendMode.screen:
        return 'Screen';
      case LayerBlendMode.overlay:
        return 'Overlay';
      case LayerBlendMode.darken:
        return 'Darken';
      case LayerBlendMode.lighten:
        return 'Lighten';
    }
  }
}
