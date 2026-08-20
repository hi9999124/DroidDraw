import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'canvas/infinite_canvas.dart';
import 'layers/document_controller.dart';
import 'layers/layer_panel.dart';
import 'theme/app_theme.dart';
import 'theme/glass_surface.dart';

/// Assembles the Phase 1 screen: a full-bleed [InfiniteCanvas], a floating
/// top toolbar, and a [LayerPanel] that slides in from the right edge.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _layersVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: InfiniteCanvas()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _Toolbar(
                layersVisible: _layersVisible,
                onToggleLayers: () {
                  setState(() => _layersVisible = !_layersVisible);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: _layersVisible ? 12 : -340,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 76, bottom: 12),
                child: const LayerPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.layersVisible, required this.onToggleLayers});

  final bool layersVisible;
  final VoidCallback onToggleLayers;

  @override
  Widget build(BuildContext context) {
    final document = context.watch<DocumentController>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: GlassSurface(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.brush_rounded, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            const Text(
              'DroidDraw',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Undo',
              icon: const Icon(Icons.undo_rounded, size: 20),
              onPressed: document.canUndo ? document.undo : null,
            ),
            IconButton(
              tooltip: 'Redo',
              icon: const Icon(Icons.redo_rounded, size: 20),
              onPressed: document.canRedo ? document.redo : null,
            ),
            IconButton(
              tooltip:
                  layersVisible ? 'Hide layers panel' : 'Show layers panel',
              icon: Icon(
                layersVisible ? Icons.layers_rounded : Icons.layers_outlined,
                color:
                    layersVisible ? AppColors.accent : AppColors.textPrimary,
                size: 20,
              ),
              onPressed: onToggleLayers,
            ),
          ],
        ),
      ),
    );
  }
}
