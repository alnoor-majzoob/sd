import 'dart:async';
import 'stream_import_service.dart';
import 'import_isolate.dart';
import 'import_progress.dart';

/// High-level service that orchestrates Excel import operations.
///
/// Wraps [StreamImportService] to provide two modes:
/// - **Into an existing workspace**: for when a user already has a workspace open
/// - **As a new workspace**: for first-run / workspace creation
///
/// Exposes a progress stream so the UI can display real-time import updates.
class DatabaseService {
  final String dbPath;
  final StreamImportService _importService = StreamImportService();

  DatabaseService({required this.dbPath});

  /// Stream of real-time import progress events.
  /// Subscribe to this in the UI to show live import status.
  Stream<ImportProgress> get importProgressStream => _importService.progressStream;

  /// Whether an import is currently running.
  bool get isImporting => _importService.isRunning;

  /// Import Excel data INTO an existing workspace by [workspaceId].
  ///
  /// This is the primary method used when a user has already opened a workspace
  /// and wants to import/refresh data for it. The workspace's existing data
  /// will be cleared before the import begins.
  ///
  /// Progress events are emitted through [importProgressStream].
  Future<ImportResult> importIntoWorkspace({
    required String filePath,
    required int workspaceId,
  }) {
    return _importService.importIntoWorkspace(
      filePath: filePath,
      workspaceId: workspaceId,
      dbPath: dbPath,
    );
  }

  /// Import Excel data as a NEW workspace with [workspaceName].
  ///
  /// Use this for the initial workspace creation flow where no workspace
  /// exists yet. A fresh workspace record is created, then data is imported.
  ///
  /// Progress events are emitted through [importProgressStream].
  Future<ImportResult> importAsNewWorkspace({
    required String filePath,
    required String workspaceName,
  }) {
    return _importService.importAsNewWorkspace(
      filePath: filePath,
      workspaceName: workspaceName,
      dbPath: dbPath,
    );
  }

  /// Cancel the currently running import operation.
  /// The isolate will be killed and state reset to idle.
  Future<void> cancelImport() => _importService.cancel();

  /// Clean up all resources (call when shutting down the app).
  void dispose() => _importService.dispose();
}