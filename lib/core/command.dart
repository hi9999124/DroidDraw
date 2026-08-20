/// A single undoable unit of work.
///
/// The undo/redo system is command-based rather than snapshot-based: each
/// [Command] knows how to apply and reverse one specific edit (add a layer,
/// change its opacity, stroke a brush path, ...). This keeps undo cheap
/// regardless of canvas size, since the document is never copied wholesale.
abstract class Command {
  /// Applies the edit. Called once when the command is first executed via
  /// [CommandHistory.execute], and again on every redo.
  void execute();

  /// Reverses [execute]. Must leave the document exactly as it was before
  /// [execute] ran.
  void undo();

  /// Short label for the action, e.g. for a history list or debug log.
  String get label;
}
