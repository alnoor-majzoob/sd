import 'dart:async';
import 'dart:isolate';
import 'import_isolate.dart';
import 'import_progress.dart';

/// Parameter bundle passed to the import isolate entry point.
/// Using a named class (not a raw Map) gives us type safety and
/// self-documenting field names at the isolate boundary.
class ImportWorkerParams {
  final String filePath;
  final int? workspaceId;
  final String? workspaceName;
  final String? dbPath;
  final SendPort sendPort;

  ImportWorkerParams({
    required this.filePath,
    this.workspaceId,
    this.workspaceName,
    this.dbPath,
    required this.sendPort,
  });
}

/// Manages a streaming import operation backed by a dedicated isolate.
///
/// The isolate parses the Excel file and writes data in stages, emitting
/// progress messages through a broadcast stream. The main UI subscribes
/// to that stream to show real-time progress without blocking the render loop.
///
/// Supports two modes:
/// - **Import into existing workspace**: pass [workspaceId]
/// - **Import as new workspace**: leave [workspaceId] null, provide [workspaceName]
class StreamImportService {
  StreamController<ImportProgress>? _controller;
  StreamSubscription? _receiveSubscription;
  Isolate? _isolate;
  ReceivePort? _receivePort;
  bool _isRunning = false;

  /// Whether an import is currently in progress.
  bool get isRunning => _isRunning;

  /// Stream of progress events. Subscribe to receive real-time updates.
  Stream<ImportProgress> get progressStream {
    _controller ??= StreamController<ImportProgress>.broadcast();
    return _controller!.stream;
  }

  /// Import data into an existing workspace by [workspaceId].
  ///
  /// The active workspace from Riverpod state should be passed here.
  /// If the workspace already has data, it will be cleared before re-import.
  Future<ImportResult> importIntoWorkspace({
    required String filePath,
    required int workspaceId,
    required String dbPath,
  }) {
    return _run(
      filePath: filePath,
      workspaceId: workspaceId,
      dbPath: dbPath,
    );
  }

  /// Import data into a NEW workspace (original behaviour).
  /// Use this for the initial workspace creation flow.
  Future<ImportResult> importAsNewWorkspace({
    required String filePath,
    required String workspaceName,
    required String dbPath,
  }) {
    return _run(
      filePath: filePath,
      workspaceId: null,
      workspaceName: workspaceName,
      dbPath: dbPath,
    );
  }

  Future<ImportResult> _run({
    required String filePath,
    int? workspaceId,
    String? workspaceName,
    required String dbPath,
  }) async {
    // Cancel any previous import before starting a new one
    await cancel();

    _isRunning = true;
    _controller = StreamController<ImportProgress>.broadcast();
    _receivePort = ReceivePort();

    final completer = Completer<ImportResult>();

    _receiveSubscription = _receivePort!.listen((message) {
      if (message is ImportProgress) {
        _controller?.add(message);

        if (message.stage == ImportStage.done) {
          completer.complete(ImportResult(message.workspaceId ?? 0, true));
          _cleanup();
        } else if (message.stage == ImportStage.error) {
          completer.complete(ImportResult(0, false, message.message));
          _cleanup();
        }
      } else if (message is ImportResult) {
        // Legacy final result (fallback if no progress messages were sent)
        if (message.success) {
          _controller?.add(ImportProgress.done(message.workspaceId));
          completer.complete(message);
        } else {
          _controller?.add(ImportProgress.error(message.error ?? 'Unknown error'));
          completer.complete(message);
        }
        _cleanup();
      }
    });

    try {
      _isolate = await Isolate.spawn(
        importWorker,
        ImportWorkerParams(
          filePath: filePath,
          workspaceId: workspaceId,
          workspaceName: workspaceName,
          dbPath: dbPath,
          sendPort: _receivePort!.sendPort,
        ),
      );
    } catch (e) {
      _controller?.add(ImportProgress.error('Failed to spawn import isolate: $e'));
      _cleanup();
      completer.complete(ImportResult(0, false, '$e'));
    }

    return completer.future;
  }

  /// Cancel the currently running import, kill the isolate,
  /// and reset the service to idle state.
  Future<void> cancel() async {
    _cleanup();
    _isRunning = false;
    // Emit idle state so the UI resets
    _controller?.add(ImportProgress.idle());
  }

  void _cleanup() {
    _isRunning = false;
    _receiveSubscription?.cancel();
    _receiveSubscription = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
    // Don't close the controller here — we keep it alive for the stream
    // to allow late subscribers to read final state
  }

  void dispose() {
    _cleanup();
    _controller?.close();
    _controller = null;
  }
}