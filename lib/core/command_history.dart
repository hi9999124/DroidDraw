import 'package:flutter/foundation.dart';

import 'command.dart';

/// Stack-based undo/redo history.
///
/// Tools and layer actions call [execute] instead of mutating state
/// directly; that's what makes their edits undoable for free. History is
/// capped at [maxHistoryLength] so long sessions don't grow the stacks
/// unboundedly — the oldest entries are simply dropped, never replayed.
///
/// This is deliberately the *entire* undo/redo system for now: Phase 1 has
/// no drawing tools yet, so the only [Command]s that exist are the layer
/// commands in lib/layers/layer_commands.dart. Phase 2's brush engine hooks
/// in by executing its own `Command` implementations here.
class CommandHistory extends ChangeNotifier {
  CommandHistory({this.maxHistoryLength = 200});

  final int maxHistoryLength;

  final List<Command> _undoStack = [];
  final List<Command> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  List<Command> get undoStack => List.unmodifiable(_undoStack);
  List<Command> get redoStack => List.unmodifiable(_redoStack);

  /// Runs [command] and pushes it onto the undo stack. Clears the redo
  /// stack, since redoing past a fresh edit would resurrect a branch of
  /// history that no longer applies.
  void execute(Command command) {
    command.execute();
    _undoStack.add(command);
    if (_undoStack.length > maxHistoryLength) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    final command = _undoStack.removeLast();
    command.undo();
    _redoStack.add(command);
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    final command = _redoStack.removeLast();
    command.execute();
    _undoStack.add(command);
    notifyListeners();
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    notifyListeners();
  }
}
