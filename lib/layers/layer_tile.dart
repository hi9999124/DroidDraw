import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/blend_mode.dart';
import '../models/layer.dart';
import '../models/raster_layer.dart';
import '../theme/app_theme.dart';
import 'document_controller.dart';

/// One row in the [LayerPanel]: thumbnail, name, visibility toggle, opacity
/// slider, blend mode dropdown, drag handle and delete action.
class LayerTile extends StatefulWidget {
  const LayerTile({
    super.key,
    required this.layer,
    required this.index,
    required this.isActive,
  });

  final Layer layer;
  final int index;
  final bool isActive;

  @override
  State<LayerTile> createState() => _LayerTileState();
}

class _LayerTileState extends State<LayerTile> {
  // Captured when an opacity drag starts, so the whole drag can be
  // committed as a single undoable step when it ends.
  Layer? _dragStartSnapshot;

  @override
  Widget build(BuildContext context) {
    final document = context.read<DocumentController>();
    final layer = widget.layer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isActive ? AppColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isActive ? AppColors.accent : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => document.selectLayer(layer.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Thumbnail(layer: layer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      layer.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: layer.visible ? 'Hide layer' : 'Show layer',
                    iconSize: 18,
                    icon: Icon(
                      layer.visible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: layer.visible
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => document.toggleVisibility(layer.id),
                  ),
                  IconButton(
                    tooltip: 'Delete layer',
                    iconSize: 18,
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                    onPressed: () => document.deleteLayer(layer.id),
                  ),
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 32,
                    child: Icon(
                      Icons.opacity_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: layer.opacity,
                        onChangeStart: (_) {
                          _dragStartSnapshot = layer.copyWith();
                        },
                        onChanged: (value) {
                          document.previewOpacity(layer.id, value);
                        },
                        onChangeEnd: (value) {
                          final before = _dragStartSnapshot;
                          if (before != null) {
                            document.commitOpacity(layer.id, before, value);
                          }
                          _dragStartSnapshot = null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${(layer.opacity * 100).round()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: _BlendModeDropdown(
                      value: layer.blendMode,
                      onChanged: (mode) => document.setBlendMode(
                        layer.id,
                        mode,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.layer});

  final Layer layer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        color: AppColors.surface,
      ),
      child: Icon(
        layer is RasterLayer ? Icons.image_rounded : Icons.gesture_rounded,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _BlendModeDropdown extends StatelessWidget {
  const _BlendModeDropdown({required this.value, required this.onChanged});

  final LayerBlendMode value;
  final ValueChanged<LayerBlendMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<LayerBlendMode>(
        value: value,
        isDense: true,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        items: LayerBlendMode.values
            .map(
              (mode) => DropdownMenuItem(
                value: mode,
                child: Text(mode.label),
              ),
            )
            .toList(),
        onChanged: (mode) {
          if (mode != null) onChanged(mode);
        },
      ),
    );
  }
}
