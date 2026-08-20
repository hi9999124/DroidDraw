import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/layer.dart';
import '../theme/app_theme.dart';
import '../theme/glass_surface.dart';
import 'document_controller.dart';
import 'layer_tile.dart';

/// Right-hand panel for managing the layer stack: add, delete, reorder,
/// toggle visibility, adjust opacity and blend mode. Every mutating action
/// here goes through [DocumentController], so it's undoable via the
/// toolbar's undo/redo buttons.
class LayerPanel extends StatelessWidget {
  const LayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final document = context.watch<DocumentController>();
    // Panel shows topmost layer first; the underlying list is bottom-to-top
    // (paint order), so it's displayed reversed.
    final displayLayers = document.layers.reversed.toList();

    return GlassSurface(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PanelHeader(document: document),
            const Divider(height: 1),
            Flexible(
              child: displayLayers.isEmpty
                  ? const _EmptyState()
                  : ReorderableListView.builder(
                      shrinkWrap: true,
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: displayLayers.length,
                      onReorder: (oldIndex, newIndex) =>
                          _handleReorder(document, oldIndex, newIndex),
                      itemBuilder: (context, index) {
                        final layer = displayLayers[index];
                        return LayerTile(
                          key: ValueKey(layer.id),
                          layer: layer,
                          index: index,
                          isActive: layer.id == document.activeLayerId,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleReorder(
    DocumentController document,
    int oldIndex,
    int newIndex,
  ) {
    final count = document.layers.length;
    if (oldIndex < newIndex) newIndex -= 1;
    // Displayed indices are reversed relative to the bottom-to-top layer
    // array, so translate before/after applying the move.
    final realOld = count - 1 - oldIndex;
    final realNew = count - 1 - newIndex;
    document.reorderLayer(realOld, realNew);
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.document});

  final DocumentController document;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          const Text(
            'Layers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          PopupMenuButton<LayerType>(
            tooltip: 'Add layer',
            icon: const Icon(Icons.add_rounded, size: 22),
            onSelected: (type) {
              if (type == LayerType.raster) {
                document.addRasterLayer();
              } else {
                document.addVectorLayer();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: LayerType.raster,
                child: Text('Raster layer'),
              ),
              PopupMenuItem(
                value: LayerType.vector,
                child: Text('Vector layer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Text(
        'No layers yet',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
