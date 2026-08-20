import 'package:flutter/foundation.dart';

import '../models/layer.dart';

/// Owns the ordered layer stack for the current document.
///
/// [layers] is bottom-to-top, matching paint order in the canvas painter.
/// This class only holds state and applies already-decided edits; the
/// actions the UI calls (add/delete/reorder/etc.) go through
/// [DocumentController] in document_controller.dart, which wraps each edit
/// in a `Command` so it's undoable. Nothing outside that file should call
/// the mutating methods here directly.
class LayerManager extends ChangeNotifier {
  final List<Layer> _layers = [];
  String? _activeLayerId;
  final Map<String, int> _layerCounters = {};

  List<Layer> get layers => List.unmodifiable(_layers);
  String? get activeLayerId => _activeLayerId;
  Layer? get activeLayer => _layerById(_activeLayerId);

  /// Generates the next default layer name for [prefix], e.g. the third
  /// raster layer becomes "Raster Layer 3" regardless of how many vector
  /// layers exist — each prefix counts independently.
  String nextLayerName(String prefix) {
    final next = (_layerCounters[prefix] ?? 0) + 1;
    _layerCounters[prefix] = next;
    return '$prefix $next';
  }

  void insertLayer(Layer layer, int index) {
    final clampedIndex = index.clamp(0, _layers.length);
    _layers.insert(clampedIndex, layer);
    _activeLayerId = layer.id;
    notifyListeners();
  }

  void removeLayerById(String id) {
    _layers.removeWhere((layer) => layer.id == id);
    if (_activeLayerId == id) {
      _activeLayerId = _layers.isNotEmpty ? _layers.last.id : null;
    }
    notifyListeners();
  }

  void moveLayer(int oldIndex, int newIndex) {
    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);
    notifyListeners();
  }

  void replaceLayer(String id, Layer newLayer) {
    final index = _layers.indexWhere((layer) => layer.id == id);
    if (index == -1) return;
    _layers[index] = newLayer;
    notifyListeners();
  }

  void selectLayer(String? id) {
    _activeLayerId = id;
    notifyListeners();
  }

  /// Directly mutates a layer's opacity for live UI feedback (e.g. dragging
  /// a slider) without going through undo/redo. Pair with
  /// [DocumentController.commitOpacity] once the interaction ends so the
  /// whole drag becomes a single undoable step rather than one per frame.
  void previewOpacity(String id, double opacity) {
    final layer = _layerById(id);
    if (layer == null) return;
    layer.opacity = opacity;
    notifyListeners();
  }

  Layer? _layerById(String? id) {
    if (id == null) return null;
    for (final layer in _layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }
}
