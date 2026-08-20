import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/command_history.dart';
import '../models/blend_mode.dart';
import '../models/layer.dart';
import '../models/raster_layer.dart';
import '../models/vector_layer.dart';
import 'layer_commands.dart';
import 'layer_manager.dart';

const _uuid = Uuid();

/// Single entry point the UI (and, later, drawing tools) talks to.
///
/// Bundles the [LayerManager] (state) with the [CommandHistory]
/// (undo/redo) so every edit that mutates the layer stack goes through a
/// `Command` and is automatically undoable. Phase 2's brush/pen tools are
/// expected to depend on this same controller — they'll add their own
/// `addStroke`-style methods here that build a stroke `Command` and hand it
/// to [commandHistory], exactly like [addRasterLayer] does below.
class DocumentController extends ChangeNotifier {
  DocumentController({
    required this.canvasWidth,
    required this.canvasHeight,
  }) {
    layerManager.addListener(notifyListeners);
    commandHistory.addListener(notifyListeners);
    // Seed a first raster layer so the canvas is never empty on launch.
    addRasterLayer();
  }

  final int canvasWidth;
  final int canvasHeight;

  final LayerManager layerManager = LayerManager();
  final CommandHistory commandHistory = CommandHistory();

  List<Layer> get layers => layerManager.layers;
  String? get activeLayerId => layerManager.activeLayerId;
  bool get canUndo => commandHistory.canUndo;
  bool get canRedo => commandHistory.canRedo;

  void undo() => commandHistory.undo();
  void redo() => commandHistory.redo();

  void addRasterLayer() {
    final layer = RasterLayer(
      id: _uuid.v4(),
      name: layerManager.nextLayerName('Raster Layer'),
      width: canvasWidth,
      height: canvasHeight,
    );
    commandHistory.execute(AddLayerCommand(
      layerManager: layerManager,
      layer: layer,
      index: layerManager.layers.length,
    ));
  }

  void addVectorLayer() {
    final layer = VectorLayer(
      id: _uuid.v4(),
      name: layerManager.nextLayerName('Vector Layer'),
    );
    commandHistory.execute(AddLayerCommand(
      layerManager: layerManager,
      layer: layer,
      index: layerManager.layers.length,
    ));
  }

  void deleteLayer(String id) {
    final index = layerManager.layers.indexWhere((layer) => layer.id == id);
    if (index == -1) return;
    final layer = layerManager.layers[index];
    commandHistory.execute(RemoveLayerCommand(
      layerManager: layerManager,
      layer: layer,
      index: index,
    ));
  }

  void reorderLayer(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    commandHistory.execute(ReorderLayerCommand(
      layerManager: layerManager,
      oldIndex: oldIndex,
      newIndex: newIndex,
    ));
  }

  void toggleVisibility(String id) {
    final layer = _layerById(id);
    if (layer == null) return;
    commandHistory.execute(UpdateLayerCommand(
      layerManager: layerManager,
      layerId: id,
      before: layer.copyWith(),
      after: layer.copyWith(visible: !layer.visible),
      label: 'Toggle visibility',
    ));
  }

  /// Live opacity feedback while a slider is being dragged — bypasses
  /// undo/redo. Call [commitOpacity] once the drag ends.
  void previewOpacity(String id, double opacity) =>
      layerManager.previewOpacity(id, opacity);

  /// Commits a completed opacity drag as a single undoable step, using the
  /// snapshot captured before the drag started as the "before" state.
  void commitOpacity(String id, Layer before, double opacity) {
    commandHistory.execute(UpdateLayerCommand(
      layerManager: layerManager,
      layerId: id,
      before: before,
      after: before.copyWith(opacity: opacity),
      label: 'Set opacity',
    ));
  }

  void setBlendMode(String id, LayerBlendMode mode) {
    final layer = _layerById(id);
    if (layer == null) return;
    commandHistory.execute(UpdateLayerCommand(
      layerManager: layerManager,
      layerId: id,
      before: layer.copyWith(),
      after: layer.copyWith(blendMode: mode),
      label: 'Set blend mode',
    ));
  }

  void selectLayer(String id) => layerManager.selectLayer(id);

  Layer? _layerById(String id) {
    for (final layer in layerManager.layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  @override
  void dispose() {
    layerManager.dispose();
    commandHistory.dispose();
    super.dispose();
  }
}
