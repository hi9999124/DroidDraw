# DroidDraw

A free, open-source mobile illustration and painting app — think a combined
Illustrator + Photoshop + ibis Paint, built with Flutter so it compiles to a
real installable APK. This is a from-scratch portfolio project; **Phase 1**
(core canvas + layer system) is what's implemented so far.

## What's built in Phase 1

- **Feature-based project structure** under `lib/`: `canvas/`, `layers/`,
  `tools/`, `models/`, plus `core/` (undo/redo, shared by both layers and
  future tools) and `theme/` (dark glass-panel design system).
- **Infinite, pannable, pinch-zoomable canvas** (`lib/canvas/`) — an
  `InteractiveViewer` with unbounded `boundaryMargin` wraps a
  `RepaintBoundary`-isolated `CustomPainter`. Pan/zoom is a GPU-composited
  transform; the painter only re-runs when the layer stack actually changes
  (see `DroidDrawCanvasPainter.shouldRepaint`), never on every pointer frame.
- **Layer data model** (`lib/models/`) — an abstract `Layer` interface with
  two concrete types, `RasterLayer` (bitmap, holds an optional `ui.Image`)
  and `VectorLayer` (a list of `VectorShape` path/paint pairs), so the canvas
  and layer panel only ever depend on the interface.
- **Layer panel UI** (`lib/layers/`) — add layer (raster or vector), delete,
  drag-to-reorder (`ReorderableListView`), visibility toggle, opacity slider,
  and a blend mode dropdown (Normal/Multiply/Screen/Overlay/Darken/Lighten),
  rendered as a translucent, blurred glass panel that slides in from the
  right edge.
- **Command-based undo/redo scaffolding** (`lib/core/`) — a `Command`
  interface (`execute()`/`undo()`) and a stack-based `CommandHistory`.
  Every layer panel action (add, delete, reorder, visibility, opacity, blend
  mode) already goes through a `Command`, so undo/redo works end-to-end
  today, even though no drawing tools exist yet. History snapshots are
  lightweight `Layer` metadata objects, never full canvas/pixel state, so
  undo stays cheap regardless of document size.
- **`lib/tools/`** ships a single `Tool` abstract class stubbing the
  interface future brush/pen/shape tools will implement — intentionally no
  implementations yet, per the Phase 1 scope.
- **GitHub Actions workflow** (`.github/workflows/build-apk.yml`) — runs
  `flutter analyze`, `flutter test`, and `flutter build apk --debug` on every
  push/PR, and uploads the resulting `app-debug.apk` as a workflow artifact.

## A note on this sandbox's build verification

`flutter analyze` and `flutter test` were run and pass cleanly in the
environment that produced this code. `flutter build apk` could **not** be run
locally here: this sandbox's network policy blocks `dl.google.com` outright
(confirmed via both a direct download attempt and apt's official
`google-android-*-installer` packages, which fetch from the same host), so
the Android SDK itself couldn't be installed in this session. Nothing in the
Dart/Flutter code depends on that — the Android project is untouched
`flutter create` scaffolding. The GitHub Actions workflow above builds the
APK on GitHub's own runners, which have the Android SDK preinstalled and
unrestricted network access, and its artifact is a real, installable debug
APK. Watch the Actions tab on the first push to confirm the build passes and
grab `droiddraw-debug-apk` from the run's artifacts; on your own machine,
`flutter build apk --debug` should work directly.

## Running it

```bash
flutter pub get
flutter run            # on a connected device/emulator
flutter build apk --debug   # produces build/app/outputs/flutter-apk/app-debug.apk
```

## What Phase 2 (raster brush engine) will need from this foundation

- **A real pixel surface to paint into.** `RasterLayer.image` is currently
  always `null` — Phase 1 never writes pixels. Phase 2 needs to decide how a
  brush stroke becomes a `ui.Image` (likely: paint into an offscreen
  `PictureRecorder`/`Canvas`, rasterize via `Picture.toImage`, and store the
  result back on the layer), and how that interacts with `RasterLayer`
  currently being an immutable-ish value object (`copyWith` returns a new
  instance) — expect to either make image updates cheaper than a full
  `copyWith`, or introduce a mutable pixel-buffer path specifically for
  in-progress strokes.
- **A gesture layer above `InteractiveViewer`.** Right now `InfiniteCanvas`
  only handles pan/zoom via `InteractiveViewer`'s own gestures. Drawing needs
  a tool-aware gesture detector that captures single-pointer strokes for
  painting while still letting two-finger gestures fall through to pan/zoom
  — and needs pointer positions transformed from screen space into canvas
  space using the current `TransformationController` matrix (already kept in
  `InfiniteCanvas`'s `State`, exposed for exactly this).
- **Tool implementations of `lib/tools/tool.dart`'s `Tool` interface.** The
  interface's `onStrokeStart`/`onStrokeUpdate`/`onStrokeEnd` lifecycle is
  already shaped around "build up a stroke, commit one `Command` at the
  end" — a `BrushStrokeCommand` (or similar) should capture a before/after
  image (or a diff/dirty-rect) of the active `RasterLayer` and go through
  `DocumentController`/`CommandHistory` exactly like the layer commands in
  `lib/layers/layer_commands.dart` do today. That command needs to target
  the currently *active* layer, which `DocumentController.activeLayerId`
  already tracks.
- **Performance work on the painter for high-frequency updates.** Phase 1's
  `shouldRepaint` is tuned for occasional layer-stack edits (add/delete/
  reorder/opacity commit), not 60fps brush strokes. Phase 2 will likely want
  a separate, higher-frequency repaint path for the *actively drawn* layer
  (e.g. its own `RepaintBoundary`/`CustomPainter` layered above the
  composited stack) so a brush stroke doesn't force a full recomposite of
  every other layer on each frame.
- **Brush settings state** (size, opacity, hardness, color, texture) and a
  toolbar/tool-picker UI — nothing here yet; `lib/tools/` is currently just
  the one interface file.
- **Color picker and current-color state**, since no tool or UI for picking
  color exists in Phase 1.

## Project structure

```
lib/
  main.dart              entry point
  app.dart                root widget: theme + Provider setup
  home_screen.dart         screen: canvas + toolbar + layer panel
  core/
    command.dart            Command interface (execute/undo)
    command_history.dart    stack-based undo/redo manager
  models/
    layer.dart               abstract Layer interface
    raster_layer.dart         bitmap layer
    vector_layer.dart         vector shape layer
    vector_shape.dart         one path + fill/stroke
    blend_mode.dart           curated LayerBlendMode enum
  layers/
    layer_manager.dart        owns the layer stack (state only)
    layer_commands.dart       Add/Remove/Reorder/UpdateLayerCommand
    document_controller.dart  UI entry point: layers + undo/redo
    layer_panel.dart          the layer list panel
    layer_tile.dart            one layer row (visibility/opacity/blend/drag)
  canvas/
    infinite_canvas.dart      InteractiveViewer + RepaintBoundary + CustomPaint
    canvas_painter.dart        paints the layer stack
  tools/
    tool.dart                  Tool interface stub (no implementations yet)
  theme/
    app_theme.dart              color tokens + ThemeData
    glass_surface.dart           reusable blurred glass panel widget
```

## License

MIT — see [LICENSE](LICENSE).
