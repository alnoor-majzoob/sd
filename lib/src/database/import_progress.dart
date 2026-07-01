/// Represents the current stage of a streaming import operation.
enum ImportStage {
  idle,
  parsing,
  savingCourses,
  savingTrainers,
  savingVenues,
  savingCalendar,
  savingAssignedCourses,
  savingUnavailableDates,
  finalizing,
  done,
  error,
}

/// A progress update emitted by the import isolate as it processes
/// each chunk of data. Published via StreamImportService.progressStream.
class ImportProgress {
  final ImportStage stage;
  final int currentCount;
  final int totalCount;
  final double percentage;
  final String message;
  final int? workspaceId;

  const ImportProgress({
    required this.stage,
    this.currentCount = 0,
    this.totalCount = 0,
    this.percentage = 0.0,
    this.message = '',
    this.workspaceId,
  });

  factory ImportProgress.idle() => const ImportProgress(
        stage: ImportStage.idle,
        message: 'Waiting for import...',
      );

  factory ImportProgress.parsingStarted() => const ImportProgress(
        stage: ImportStage.parsing,
        message: 'Parsing Excel file...',
      );

  factory ImportProgress.saving({
    required ImportStage stage,
    required int current,
    required int total,
    required String entityName,
  }) {
    final pct = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    return ImportProgress(
      stage: stage,
      currentCount: current,
      totalCount: total,
      percentage: pct,
      message: '$entityName ($current / $total)',
    );
  }

  factory ImportProgress.stageStarted({
    required ImportStage stage,
    required int total,
    required String entityName,
    required String message,
  }) {
    return ImportProgress(
      stage: stage,
      currentCount: 0,
      totalCount: total,
      percentage: 0.0,
      message: message,
    );
  }

  factory ImportProgress.done(int workspaceId) => ImportProgress(
        stage: ImportStage.done,
        percentage: 1.0,
        message: 'Import complete',
        workspaceId: workspaceId,
      );

  factory ImportProgress.error(String msg) => ImportProgress(
        stage: ImportStage.error,
        message: msg,
      );
}