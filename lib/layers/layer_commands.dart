import '../core/command.dart';
import '../models/layer.dart';
import 'layer_manager.dart';

/// Inserts [layer] at [index]; undoing removes it again.
class AddLayerCommand extends Command {
  AddLayerCommand({
    required this.layerManager,
    required this.layer,
    required this.index,
  });

  final LayerManager layerManager;
  final Layer layer;
  final int index;

  @override
  void execute() => layerManager.insertLayer(layer, index);

  @override
  void undo() => layerManager.removeLayerById(layer.id);

  @override
  String get label => 'Add ${layer.name}';
}

/// Removes [layer] (captured at its [index]); undoing re-inserts it there.
class RemoveLayerCommand extends Command {
  RemoveLayerCommand({
    required this.layerManager,
    required this.layer,
    required this.index,
  });

  final LayerManager layerManager;
  final Layer layer;
  final int index;

  @override
  void execute() => layerManager.removeLayerById(layer.id);

  @override
  void undo() => layerManager.insertLayer(layer, index);

  @override
  String get label => 'Delete ${layer.name}';
}

/// Moves a layer from [oldIndex] to [newIndex] (bottom-to-top array
/// indices); undoing moves it back.
class ReorderLayerCommand extends Command {
  ReorderLayerCommand({
    required this.layerManager,
    required this.oldIndex,
    required this.newIndex,
  });

  final LayerManager layerManager;
  final int oldIndex;
  final int newIndex;

  @override
  void execute() => layerManager.moveLayer(oldIndex, newIndex);

  @override
  void undo() => layerManager.moveLayer(newIndex, oldIndex);

  @override
  String get label => 'Reorder layer';
}

/// Swaps a layer's metadata (name, visibility, opacity, blend mode) between
/// two lightweight snapshots. Used for every layer-property edit — it
/// snapshots one [Layer] object, never the canvas pixels, so it stays cheap
/// regardless of document size.
class UpdateLayerCommand extends Command {
  UpdateLayerCommand({
    required this.layerManager,
    required this.layerId,
    required this.before,
    required this.after,
    required this.label,
  });

  final LayerManager layerManager;
  final String layerId;
  final Layer before;
  final Layer after;

  @override
  final String label;

  @override
  void execute() => layerManager.replaceLayer(layerId, after);

  @override
  void undo() => layerManager.replaceLayer(layerId, before);
}
