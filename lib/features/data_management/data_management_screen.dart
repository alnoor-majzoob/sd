import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/scheduling_provider.dart';
import '../../src/database/app_database.dart';
import '../../src/database/database_service.dart';
import '../../src/database/import_progress.dart';
import '../../src/database/repositories/course_repository.dart';
import '../../src/database/repositories/trainer_repository.dart';
import '../../src/database/repositories/venue_repository.dart';
import '../../src/database/repositories/repository_provider.dart';
import '../../src/database/model_mapper.dart';
import '../../src/models/workbook_data.dart' as wb;
import '../../src/models/generated_schedule_row.dart';
import '../../src/models/lookup_values.dart';
import '../../src/validation/validation_issue.dart';
import '../../src/validation/workbook_validator.dart';

// ─────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────

final _activeStepProvider = StateProvider<int>((ref) => 0);

/// Tracks whether an import is currently in progress.
final _isImportingProvider = StateProvider<bool>((ref) => false);

/// Holds the current import progress received from the isolate stream.
final _importProgressProvider = StateProvider<ImportProgress>(
  (ref) => ImportProgress.idle(),
);

/// Fetches data counts for a workspace concurrently.
final _workspaceDataCountsProvider = FutureProvider.family<Map<String, int>, int>(
  (ref, workspaceId) async {
    final repos = GetIt.I<RepositoryProvider>();

    final results = await Future.wait([
      repos.courseRepo.getCoursesByWorkspace(workspaceId),
      repos.trainerRepo.getTrainersByWorkspace(workspaceId),
      repos.venueRepo.getVenuesByWorkspace(workspaceId),
    ]);

    return {
      'courses': results[0].length,
      'trainers': results[1].length,
      'venues': results[2].length,
    };
  },
);

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  StreamSubscription<ImportProgress>? _importSubscription;

  @override
  void dispose() {
    _importSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final workspacesAsync = ref.watch(workspacesProvider);
    final activeStep = ref.watch(_activeStepProvider);

    if (workspaceId == null) {
      return Center(child: Text(context.tr('select_workspace_first')));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('data_onboarding'), style: Theme.of(context).textTheme.displayLarge),
                  Text(context.trArgs('workspace_id_label', [workspaceId.toString()]),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StepTab(
                label: context.tr('import_step_1'),
                isActive: activeStep == 0,
                onTap: () => ref.read(_activeStepProvider.notifier).state = 0,
              ),
              _StepTab(
                label: context.tr('import_step_2'),
                isActive: activeStep == 1,
                onTap: () => ref.read(_activeStepProvider.notifier).state = 1,
              ),
              _StepTab(
                label: context.tr('import_step_3'),
                isActive: activeStep == 2,
                onTap: () => ref.read(_activeStepProvider.notifier).state = 2,
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 32),
          if (activeStep == 0)
            _buildImportStep(context, ref, workspaceId, workspacesAsync),
          if (activeStep == 1) _ValidationReportPanel(workspaceId: workspaceId),
          if (activeStep == 2) _DataManagersPanel(workspaceId: workspaceId),
        ],
      ),
    );
  }

  Widget _buildImportStep(
    BuildContext context,
    WidgetRef ref,
    int workspaceId,
    AsyncValue<List<ScheduleWorkspace>> workspacesAsync,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: Column(
            children: [
              _DropzoneCard(onBrowse: () => _handleImport(context, ref, workspaceId)),
              const SizedBox(height: 24),
              // Streaming progress panel — replaces the old static file row
              const _ImportProgressPanel(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 35,
          child: Column(
            children: [
              workspacesAsync.when(
                loading: () => const _RecentUploadsPanel(workspaces: []),
                error: (_, __) => const _RecentUploadsPanel(workspaces: []),
                data: (workspaces) {
                  final sorted = List<ScheduleWorkspace>.from(workspaces)
                    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
                  return _RecentUploadsPanel(workspaces: sorted.take(5).toList());
                },
              ),
              const SizedBox(height: 24),
              _DataSummaryPanel(workspaceId: workspaceId),
            ],
          ),
        ),
      ],
    );
  }

  /// Handles the full import lifecycle:
  /// 1. Pick file
  /// 2. Subscribe to the isolate progress stream
  /// 3. Call importIntoWorkspace (targets active workspace by ID)
  /// 4. Update providers and show snackbar on completion
  Future<void> _handleImport(BuildContext context, WidgetRef ref, int workspaceId) async {
    // Cancel any previous subscription
    await _importSubscription?.cancel();

    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final _ = result.files.single.name;

    // Reset progress state and mark as importing
    ref.read(_importProgressProvider.notifier).state = ImportProgress.idle();
    ref.read(_isImportingProvider.notifier).state = true;

    // Subscribe to progress stream from the isolate
    final dbService = GetIt.I<DatabaseService>();
    _importSubscription = dbService.importProgressStream.listen(
      (progress) {
        // Update progress in Riverpod state — UI rebuilds automatically
        ref.read(_importProgressProvider.notifier).state = progress;

        if (progress.stage == ImportStage.done) {
          // Refresh all workspace data after successful import
          ref.invalidate(_workspaceDataCountsProvider(workspaceId));
          ref.invalidate(workspacesProvider);
          ref.invalidate(_validationIssuesProvider(workspaceId));
        }

        if (progress.stage == ImportStage.done || progress.stage == ImportStage.error) {
          ref.read(_isImportingProvider.notifier).state = false;
        }
      },
      onError: (err) {
        ref.read(_importProgressProvider.notifier).state = ImportProgress.error('$err');
        ref.read(_isImportingProvider.notifier).state = false;
      },
    );

    // Start import into the ACTIVE workspace (the bug fix!)
    try {
      final importResult = await dbService.importIntoWorkspace(
        filePath: filePath,
        workspaceId: workspaceId,
      );

      if (!context.mounted) return;

      if (importResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.trArgs('import_complete_snack', [workspaceId.toString()])),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.trArgs('import_failed_snack', [importResult.error.toString()])),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ref.read(_importProgressProvider.notifier).state = ImportProgress.error('$e');
      ref.read(_isImportingProvider.notifier).state = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.trArgs('import_error_snack', [e.toString()])), backgroundColor: AppColors.error),
      );
    }
  }
}

// ─────────────────────────────────────────────
// STEP TABS
// ─────────────────────────────────────────────

class _StepTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StepTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 40,
                color: AppColors.secondary,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// IMPORT STEP
// ─────────────────────────────────────────────

class _DropzoneCard extends StatelessWidget {
  final VoidCallback onBrowse;

  const _DropzoneCard({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.secondary),
          ),
          const SizedBox(height: 16),
          Text(context.tr('drag_drop_files'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              context.tr('upload_hint'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onBrowse,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(context.tr('browse_files')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STREAMING IMPORT PROGRESS PANEL
// ─────────────────────────────────────────────

class _ImportProgressPanel extends ConsumerWidget {
  const _ImportProgressPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(_importProgressProvider);
    final isImporting = ref.watch(_isImportingProvider);

    // Hidden when not importing and in idle state
    if (!isImporting && progress.stage == ImportStage.idle) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _panelColor(progress.stage),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(progress.stage), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon + label + cancel button
          Row(
            children: [
              _StageIcon(stage: progress.stage),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stageLabel(progress.stage, context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _textColor(progress.stage),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress.message.isEmpty ? _stageDescription(progress.stage, context) : progress.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _textColor(progress.stage).withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                ),
              ),
              if (progress.stage == ImportStage.error || progress.stage == ImportStage.done)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  tooltip: context.tr('dismiss'),
                  onPressed: () {
                    ref.read(_isImportingProvider.notifier).state = false;
                    ref.read(_importProgressProvider.notifier).state = ImportProgress.idle();
                  },
                )
              else if (isImporting)
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white70, size: 20),
                  tooltip: context.tr('cancel_import'),
                  onPressed: () async {
                    await GetIt.I<DatabaseService>().cancelImport();
                    ref.read(_isImportingProvider.notifier).state = false;
                    ref.read(_importProgressProvider.notifier).state = ImportProgress.idle();
                  },
                ),
            ],
          ),

          // Progress bar + count (only for stages with a total count)
          if (progress.totalCount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress.percentage,
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${progress.currentCount} / ${progress.totalCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              context.trArgs('percent_complete', [(progress.percentage * 100).toStringAsFixed(0)]),
              style: TextStyle(
                color: _textColor(progress.stage).withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],

          // Error details
          if (progress.stage == ImportStage.error) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                progress.message,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // Done — show workspace ID
          if (progress.stage == ImportStage.done && progress.workspaceId != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  context.trArgs('data_loaded_workspace', [progress.workspaceId.toString()]),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _panelColor(ImportStage stage) {
    switch (stage) {
      case ImportStage.error:
        return AppColors.error;
      case ImportStage.done:
        return Colors.green.shade700;
      case ImportStage.idle:
        return AppColors.surfaceContainerLowest;
      default:
        return AppColors.secondary;
    }
  }

  Color _borderColor(ImportStage stage) {
    switch (stage) {
      case ImportStage.error:
        return AppColors.error.withValues(alpha: 0.4);
      case ImportStage.done:
        return Colors.green.shade400;
      case ImportStage.idle:
        return AppColors.outlineVariant;
      default:
        return AppColors.secondary.withValues(alpha: 0.4);
    }
  }

  Color _textColor(ImportStage stage) {
    switch (stage) {
      case ImportStage.idle:
        return AppColors.onSurface;
      default:
        return Colors.white;
    }
  }

  String _stageLabel(ImportStage stage, BuildContext context) {
    switch (stage) {
      case ImportStage.idle:
        return context.tr('idle_stage');
      case ImportStage.parsing:
        return context.tr('parsing_stage');
      case ImportStage.savingCourses:
        return context.tr('saving_courses_stage');
      case ImportStage.savingTrainers:
        return context.tr('saving_trainers_stage');
      case ImportStage.savingVenues:
        return context.tr('saving_venues_stage');
      case ImportStage.savingCalendar:
        return context.tr('saving_calendar_stage');
      case ImportStage.savingAssignedCourses:
        return context.tr('saving_assigned_stage');
      case ImportStage.savingUnavailableDates:
        return context.tr('saving_unavailable_stage');
      case ImportStage.finalizing:
        return context.tr('finalizing_stage');
      case ImportStage.done:
        return context.tr('done_stage');
      case ImportStage.error:
        return context.tr('error_stage');
    }
  }

  String _stageDescription(ImportStage stage, BuildContext context) {
    switch (stage) {
      case ImportStage.parsing:
        return context.tr('parsing_description');
      case ImportStage.savingCourses:
        return context.tr('saving_courses_description');
      case ImportStage.savingTrainers:
        return context.tr('saving_trainers_description');
      case ImportStage.savingVenues:
        return context.tr('saving_venues_description');
      case ImportStage.savingCalendar:
        return context.tr('saving_calendar_description');
      case ImportStage.savingAssignedCourses:
        return context.tr('saving_assigned_description');
      case ImportStage.savingUnavailableDates:
        return context.tr('saving_unavailable_description');
      case ImportStage.finalizing:
        return context.tr('finalizing_description');
      case ImportStage.done:
        return context.tr('done_description');
      case ImportStage.error:
        return context.tr('error_description');
      default:
        return '';
    }
  }
}

class _StageIcon extends StatelessWidget {
  final ImportStage stage;
  const _StageIcon({required this.stage});

  @override
  Widget build(BuildContext context) {
    if (stage == ImportStage.done) {
      return const Icon(Icons.check_circle, color: Colors.white, size: 28);
    }
    if (stage == ImportStage.error) {
      return const Icon(Icons.error_outline, color: Colors.white, size: 28);
    }
    if (stage == ImportStage.idle) {
      return const Icon(Icons.hourglass_empty, color: AppColors.onSurfaceVariant, size: 28);
    }
    // Spinning icon for active stages
    return const _SpinningImportIcon();
  }
}

class _SpinningImportIcon extends StatefulWidget {
  const _SpinningImportIcon();

  @override
  State<_SpinningImportIcon> createState() => _SpinningImportIconState();
}

class _SpinningImportIconState extends State<_SpinningImportIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: const Icon(Icons.sync, color: Colors.white, size: 28),
        );
      },
    );
  }
}

class _RecentUploadsPanel extends StatelessWidget {
  final List<ScheduleWorkspace> workspaces;

  const _RecentUploadsPanel({required this.workspaces});

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('recent_workspaces'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * 12,
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          if (workspaces.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.tr('no_workspaces_yet'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            )
          else
            ...workspaces.map((ws) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ws.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(_formatTimestamp(ws.timestamp), style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _DataSummaryPanel extends ConsumerWidget {
  final int workspaceId;

  const _DataSummaryPanel({required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = ref.watch(_workspaceDataCountsProvider(workspaceId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.tr('data_summary'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.05 * 12,
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              countsAsync.when(
                data: (counts) {
                  final total = counts.values.fold(0, (a, b) => a + b);
                  if (total == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: Text('$total',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          countsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(context.trArgs('failed_to_load', [err.toString()]), style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
            data: (counts) {
              final total = counts.values.fold(0, (a, b) => a + b);
              if (total == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    context.tr('no_data_yet'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [
                  _SummaryRow(label: context.tr('summary_courses'), count: counts['courses'] ?? 0, icon: Icons.school),
                  const SizedBox(height: 8),
                  _SummaryRow(label: context.tr('summary_trainers'), count: counts['trainers'] ?? 0, icon: Icons.person),
                  const SizedBox(height: 8),
                  _SummaryRow(label: context.tr('summary_venues'), count: counts['venues'] ?? 0, icon: Icons.location_on),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _SummaryRow({required this.label, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        Text('$count', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// VALIDATION REPORT — Uses WorkbookValidator
// ─────────────────────────────────────────────

final _validationIssuesProvider = FutureProvider.family<List<ValidationIssue>, int>(
  (ref, workspaceId) async {
    final repos = GetIt.I<RepositoryProvider>();
    final db = GetIt.I<AppDatabase>();

    // Load all data concurrently
    final results = await Future.wait([
      repos.courseRepo.getCoursesByWorkspace(workspaceId),
      repos.trainerRepo.getTrainersByWorkspace(workspaceId),
      repos.venueRepo.getVenuesByWorkspace(workspaceId),
      repos.calendarRepo.getCalendarByWorkspace(workspaceId),
      repos.scheduleRepo.getSchedulesByWorkspace(workspaceId),
      // Query AssignedCourses directly from database
      (db.select(db.assignedCourses)..where((t) => t.workspaceId.equals(workspaceId))).get(),
    ]);

    // Use database results directly
    final dbAssignedCourses = results[5] as List<AssignedCourse>;
    final dbSchedules = results[4] as List<Schedule>;

    final domainSchedules = dbSchedules.map((dbS) {
      return GeneratedScheduleRow(
        scheduleId: dbS.id.toString(),
        courseId: null,
        courseName: null,
        startDate: dbS.startDate,
        endDate: dbS.endDate,
        durationDays: null,
        trainer1: null,
        trainer2: null,
        venue: null,
        citySite: null,
        expectedTrainees: null,
        status: dbS.status,
        conflictFlag: null,
        score: null,
        notes: null,
      );
    }).toList();

    final domainCourses = (results[0] as List<Course>)
        .map(ModelMapper.mapCourse)
        .toList();
    final domainCalendar = (results[3] as List<CalendarDay>)
        .map(ModelMapper.mapCalendarDay)
        .toList();
    final domainAssigned = dbAssignedCourses
        .map(ModelMapper.mapAssignedCourse)
        .toList();

    final data = wb.WorkbookData(
      courses: domainCourses,
      trainers: [],
      venues: [],
      calendar: domainCalendar,
      assignedCourses: domainAssigned,
      generatedSchedule: domainSchedules,
      lookups: const LookupValues(priorities: [], deliveryTypes: [], venueTypes: [], statuses: [], yesNo: []),
    );

    return WorkbookValidator().validate(data);
  },
);

class _ValidationReportPanel extends ConsumerWidget {
  final int workspaceId;

  const _ValidationReportPanel({required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(_validationIssuesProvider(workspaceId));

    return issuesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(context.trArgs('failed_validation', [err.toString()]), style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (issues) {
        final errors = issues.where((i) => i.severity == ValidationSeverity.error).toList();
        final warnings = issues.where((i) => i.severity == ValidationSeverity.warning).toList();
        final isClean = errors.isEmpty && warnings.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(context.tr('validation_report'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isClean
                        ? Colors.green.shade50
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isClean
                        ? context.tr('all_clear')
                        : '${context.trArgs('count_errors', [errors.length.toString()])}, ${context.trArgs('count_warnings', [warnings.length.toString()])}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isClean ? Colors.green.shade800 : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary chips
            Row(
              children: [
                _ValidationChip(
                  label: context.trArgs('count_errors', [errors.length.toString()]),
                  color: AppColors.error,
                  icon: Icons.error_outline,
                  isActive: errors.isNotEmpty,
                ),
                const SizedBox(width: 12),
                _ValidationChip(
                  label: context.trArgs('count_warnings', [warnings.length.toString()]),
                  color: Colors.amber.shade700,
                  icon: Icons.warning_amber,
                  isActive: warnings.isNotEmpty,
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (isClean)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr('validation_passed'),
                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Errors section
              if (errors.isNotEmpty) ...[
                _SectionHeader(label: context.tr('errors_section'), count: errors.length, color: AppColors.error),
                const SizedBox(height: 8),
                ...errors.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _IssueCard(issue: issue),
                    )),
                const SizedBox(height: 16),
              ],

              // Warnings section
              if (warnings.isNotEmpty) ...[
                _SectionHeader(label: context.tr('warnings_section'), count: warnings.length, color: Colors.amber.shade700),
                const SizedBox(height: 8),
                ...warnings.map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _IssueCard(issue: issue),
                    )),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SectionHeader({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.trArgs('issue_count', [count.toString()]),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
        ),
      ],
    );
  }
}

class _IssueCard extends StatelessWidget {
  final ValidationIssue issue;

  const _IssueCard({required this.issue});

  IconData get _icon =>
      issue.severity == ValidationSeverity.error ? Icons.error : Icons.warning_amber;

  Color get _color =>
      issue.severity == ValidationSeverity.error ? AppColors.error : Colors.amber.shade700;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 16, color: _color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Sheet: ${issue.sheet}  ·  Entity: ${issue.entityId}  ·  Field: ${issue.field}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ValidationChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isActive;

  const _ValidationChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? color : AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isActive ? color : AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? color : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DATA MANAGERS — With Validated Edit Dialogs
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// DATA MANAGERS — Card-Based with Full Edit Sheets
// ─────────────────────────────────────────────

class _DataManagersPanel extends ConsumerStatefulWidget {
  final int workspaceId;

  const _DataManagersPanel({required this.workspaceId});

  @override
  ConsumerState<_DataManagersPanel> createState() => _DataManagersPanelState();
}

class _DataManagersPanelState extends ConsumerState<_DataManagersPanel> {
  int _entityTab = 0;
  int _refreshKey = 0;

  void _refresh() => setState(() => _refreshKey++);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, label: Text(context.tr('entity_tab_courses')), icon: const Icon(Icons.school)),
                ButtonSegment(value: 1, label: Text(context.tr('entity_tab_trainers')), icon: const Icon(Icons.person)),
                ButtonSegment(value: 2, label: Text(context.tr('entity_tab_venues')), icon: const Icon(Icons.location_on)),
              ],
              selected: {_entityTab},
              onSelectionChanged: (v) => setState(() => _entityTab = v.first),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(context.tr('refresh')),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_entityTab == 0)
          _CoursesManager(key: ValueKey('courses_$_refreshKey'), workspaceId: widget.workspaceId, onEdit: _refresh, onDelete: _refresh),
        if (_entityTab == 1)
          _TrainersManager(key: ValueKey('trainers_$_refreshKey'), workspaceId: widget.workspaceId, onEdit: _refresh, onDelete: _refresh),
        if (_entityTab == 2)
          _VenuesManager(key: ValueKey('venues_$_refreshKey'), workspaceId: widget.workspaceId, onEdit: _refresh, onDelete: _refresh),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// COURSES MANAGER
// ─────────────────────────────────────────────

class _CoursesManager extends ConsumerWidget {
  final int workspaceId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CoursesManager({
    super.key,
    required this.workspaceId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = GetIt.I<CourseRepository>().getCoursesByWorkspace(workspaceId);

    return FutureBuilder<List<Course>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return _EmptyState(
            icon: Icons.school_outlined,
            message: context.tr('no_courses_yet'),
            subMessage: context.tr('no_courses_sub'),
          );
        }

        return Column(
          children: courses.map((c) => _CourseCard(
            course: c,
            onEdit: () async {
              await _showCourseEditSheet(context, c);
              onEdit();
            },
            onDelete: () async {
              final confirm = await _confirmDelete(context, context.tr('delete_course'), context.trArgs('delete_confirm', [c.courseId]));
              if (confirm == true) {
                await GetIt.I<CourseRepository>().deleteCourse(c.id);
                onDelete();
              }
            },
          )).toList(),
        );
      },
    );
  }
}

class _CourseCard extends StatefulWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({required this.course, required this.onEdit, required this.onDelete});

  @override
  State<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<_CourseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.course;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          // ── Header row ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Course icon with specialty color
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, size: 20, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  // Main info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c.courseId,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'monospace',
                                  ),
                            ),
                            if ((c.priority ?? '').isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _Badge(label: c.priority ?? '', color: _priorityColor(c.priority ?? '')),
                            ],
                            if (c.deliveryType.toLowerCase() == 'online' || c.deliveryType.toLowerCase() == 'virtual') ...[
                              const SizedBox(width: 8),
                              _Badge(label: 'Online', color: Colors.blue),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Key metrics
                  _MetricChip(icon: Icons.calendar_today, label: '${c.durationDays}d'),
                  const SizedBox(width: 8),
                  _MetricChip(icon: Icons.people, label: '${c.expectedTrainees}'),
                  const SizedBox(width: 8),
                  if ((c.specialty ?? '').isNotEmpty)
                    _MetricChip(icon: Icons.category, label: c.specialty ?? ''),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          // ── Expanded detail ──
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Two-column field grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FieldGrid(fields: [
                          _FieldItem(label: 'Course Name (EN)', value: c.name),
                          _FieldItem(label: 'Course Name (AR)', value: (c.courseNameAr ?? '').isEmpty ? '—' : (c.courseNameAr ?? '')),
                          _FieldItem(label: 'Specialty', value: (c.specialty ?? '').isEmpty ? '—' : (c.specialty ?? '')),
                          _FieldItem(label: 'Delivery Type', value: c.deliveryType),
                          _FieldItem(label: 'Priority', value: (c.priority ?? '').isEmpty ? '—' : (c.priority ?? '')),
                          _FieldItem(label: 'Beneficiary', value: (c.beneficiary ?? '').isEmpty ? '—' : (c.beneficiary ?? '')),
                        ]),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _FieldGrid(fields: [
                          _FieldItem(label: 'Duration (days)', value: '${c.durationDays}'),
                          _FieldItem(label: 'Hours/Day', value: '${c.hoursPerDay}'),
                          _FieldItem(label: 'Expected Trainees', value: '${c.expectedTrainees}'),
                          _FieldItem(label: 'Preferred City', value: (c.preferredCitySite ?? '').isEmpty ? '—' : (c.preferredCitySite ?? '')),
                          _FieldItem(label: 'Earliest Start', value: c.earliestStart != null ? _fmtDate(c.earliestStart!) : '—'),
                          _FieldItem(label: 'Latest End', value: c.latestEnd != null ? _fmtDate(c.latestEnd!) : '—'),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FieldGrid(fields: [
                          _FieldItem(label: 'Fixed Date', value: c.fixedDate != null ? _fmtDate(c.fixedDate!) : '— (flexible)'),
                        ]),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _FieldGrid(fields: [
                          _FieldItem(label: 'Notes', value: c.notes ?? '—'),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(context.tr('edit_course')),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        label: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _FieldItem {
  final String label;
  final String value;
  _FieldItem({required this.label, required this.value});
}

class _FieldGrid extends StatelessWidget {
  final List<_FieldItem> fields;
  const _FieldGrid({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  f.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// TRAINERS MANAGER
// ─────────────────────────────────────────────

class _TrainersManager extends ConsumerWidget {
  final int workspaceId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrainersManager({
    super.key,
    required this.workspaceId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = GetIt.I<TrainerRepository>().getTrainersByWorkspace(workspaceId);

    return FutureBuilder<List<Trainer>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final trainers = snapshot.data ?? [];
        if (trainers.isEmpty) {
          return _EmptyState(
            icon: Icons.person_outline,
            message: context.tr('no_trainers_yet'),
            subMessage: context.tr('no_trainers_sub'),
          );
        }

        return Column(
          children: trainers.map((t) => _TrainerCard(
            trainer: t,
            onEdit: () async {
              await _showTrainerEditSheet(context, t);
              onEdit();
            },
            onDelete: () async {
              final confirm = await _confirmDelete(context, context.tr('delete_trainer'), context.trArgs('delete_confirm', [t.trainerId]));
              if (confirm == true) {
                await GetIt.I<TrainerRepository>().deleteTrainer(t.id);
                onDelete();
              }
            },
          )).toList(),
        );
      },
    );
  }
}

class _TrainerCard extends StatefulWidget {
  final Trainer trainer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TrainerCard({required this.trainer, required this.onEdit, required this.onDelete});

  @override
  State<_TrainerCard> createState() => _TrainerCardState();
}

class _TrainerCardState extends State<_TrainerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.trainer;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person, size: 20, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(t.trainerId, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                            if ((t.trainerType ?? '').isNotEmpty) ...[
                              const SizedBox(width: 8),
                              _Badge(label: t.trainerType ?? '', color: Colors.teal),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(t.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if ((t.specialty ?? '').isNotEmpty) _MetricChip(icon: Icons.category, label: t.specialty ?? ''),
                  if ((t.city ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _MetricChip(icon: Icons.location_on, label: t.city ?? ''),
                  ],
                  if ((t.maxDaysPerMonth ?? 0) > 0) ...[
                    const SizedBox(width: 8),
                    _MetricChip(icon: Icons.event_busy, label: '≤${t.maxDaysPerMonth ?? 0}d/mo'),
                  ],
                  const SizedBox(width: 12),
                  AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _FieldGrid(fields: [
                        _FieldItem(label: 'Name', value: t.name),
                        _FieldItem(label: 'Specialty', value: (t.specialty ?? '').isNotEmpty ? (t.specialty ?? '') : '—'),
                        _FieldItem(label: 'City', value: (t.city ?? '').isEmpty ? '—' : (t.city ?? '')),
                        _FieldItem(label: 'Type', value: (t.trainerType ?? '').isEmpty ? '—' : (t.trainerType ?? '')),
                      ])),
                      const SizedBox(width: 24),
                      Expanded(child: _FieldGrid(fields: [
                        _FieldItem(label: 'Max Days/Month', value: '${t.maxDaysPerMonth}'),
                        _FieldItem(label: 'Max Consecutive Days', value: '${t.maxConsecutiveDays}'),
                        _FieldItem(label: 'Cost/Day', value: (t.costPerDay ?? 0) > 0 ? '\$${(t.costPerDay ?? 0).toStringAsFixed(2)}' : '—'),
                        _FieldItem(label: 'Notes', value: t.notes ?? '—'),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(onPressed: widget.onEdit, icon: const Icon(Icons.edit, size: 16), label: Text(context.tr('edit_trainer')), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(onPressed: widget.onDelete, icon: const Icon(Icons.delete, size: 16, color: Colors.red), label: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VENUES MANAGER
// ─────────────────────────────────────────────

class _VenuesManager extends ConsumerWidget {
  final int workspaceId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VenuesManager({
    super.key,
    required this.workspaceId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = GetIt.I<VenueRepository>().getVenuesByWorkspace(workspaceId);

    return FutureBuilder<List<Venue>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final venues = snapshot.data ?? [];
        if (venues.isEmpty) {
          return _EmptyState(
            icon: Icons.location_on_outlined,
            message: context.tr('no_venues_yet'),
            subMessage: context.tr('no_venues_sub'),
          );
        }

        return Column(
          children: venues.map((v) => _VenueCard(
            venue: v,
            onEdit: () async {
              await _showVenueEditSheet(context, v);
              onEdit();
            },
            onDelete: () async {
              final confirm = await _confirmDelete(context, context.tr('delete_venue'), context.trArgs('delete_confirm', [v.venueId]));
              if (confirm == true) {
                await GetIt.I<VenueRepository>().deleteVenue(v.id);
                onDelete();
              }
            },
          )).toList(),
        );
      },
    );
  }
}

class _VenueCard extends StatefulWidget {
  final Venue venue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VenueCard({required this.venue, required this.onEdit, required this.onDelete});

  @override
  State<_VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends State<_VenueCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.venue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(top: const Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on, size: 20, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(v.venueId, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'monospace')),
                            const SizedBox(width: 8),
                            _Badge(label: v.venueType, color: Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(v.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _MetricChip(icon: Icons.people, label: '${v.capacity} cap.'),
                  if ((v.city ?? '').isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _MetricChip(icon: Icons.location_city, label: v.city ?? ''),
                  ],
                  const SizedBox(width: 12),
                  AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _FieldGrid(fields: [
                        _FieldItem(label: 'Name', value: v.name),
                        _FieldItem(label: 'Type', value: v.venueType),
                        _FieldItem(label: 'City', value: (v.city ?? '').isEmpty ? '—' : (v.city ?? '')),
                      ])),
                      const SizedBox(width: 24),
                      Expanded(child: _FieldGrid(fields: [
                        _FieldItem(label: 'Capacity', value: '${v.capacity}'),
                        _FieldItem(label: 'Available From', value: v.availableFrom != null ? _fmtDate(v.availableFrom!) : '—'),
                        _FieldItem(label: 'Available To', value: v.availableTo != null ? _fmtDate(v.availableTo!) : '—'),
                      ])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FieldGrid(fields: [
                    _FieldItem(label: 'Equipment Notes', value: v.equipmentNotes ?? '—'),
                  ]),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(onPressed: widget.onEdit, icon: const Icon(Icons.edit, size: 16), label: Text(context.tr('edit_venue')), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(onPressed: widget.onDelete, icon: const Icon(Icons.delete, size: 16, color: Colors.red), label: Text(context.tr('delete'), style: const TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), side: const BorderSide(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;

  const _EmptyState({required this.icon, required this.message, required this.subMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subMessage, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EDIT BOTTOM SHEETS
// ─────────────────────────────────────────────

Future<void> _showCourseEditSheet(BuildContext context, Course course) async {
  final nameCtl = TextEditingController(text: course.name);
  final arNameCtl = TextEditingController(text: course.courseNameAr);
  final specCtl = TextEditingController(text: course.specialty);
  final durCtl = TextEditingController(text: course.durationDays.toString());
  final hrsCtl = TextEditingController(text: course.hoursPerDay.toString());
  final traineesCtl = TextEditingController(text: course.expectedTrainees.toString());
  final cityCtl = TextEditingController(text: course.preferredCitySite);
  final benefCtl = TextEditingController(text: course.beneficiary);
  final delCtl = TextEditingController(text: course.deliveryType);
  final priorityCtl = TextEditingController(text: course.priority);
  final notesCtl = TextEditingController(text: course.notes ?? '');

  DateTime? earliest = course.earliestStart;
  DateTime? latest = course.latestEnd;
  DateTime? fixed = course.fixedDate;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.school, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('edit_course'), style: Theme.of(context).textTheme.titleLarge),
                      Text(course.courseId, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SheetSection(title: context.tr('basic_info_section')),
              _SheetTextField(controller: nameCtl, label: context.tr('course_name_en'), hint: context.tr('hint_course_name_en')),
              _SheetTextField(controller: arNameCtl, label: context.tr('course_name_ar'), hint: context.tr('hint_course_name_ar')),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: specCtl, label: context.tr('specialty'), hint: context.tr('hint_specialty'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: priorityCtl, label: context.tr('priority'), hint: context.tr('hint_priority'))),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: delCtl, label: context.tr('delivery_type'), hint: context.tr('hint_delivery_type'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: benefCtl, label: context.tr('beneficiary'), hint: context.tr('hint_beneficiary'))),
                ],
              ),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('schedule_capacity_section')),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: durCtl, label: context.tr('duration_days'), hint: context.tr('hint_duration_days'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: hrsCtl, label: context.tr('hours_per_day'), hint: context.tr('hint_hours_per_day'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: traineesCtl, label: context.tr('expected_trainees'), hint: context.tr('hint_expected_trainees'), keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: cityCtl, label: context.tr('preferred_city'), hint: context.tr('hint_preferred_city'))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DateField(label: context.tr('earliest_start'), value: earliest, onChanged: (d) => setSheetState(() => earliest = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _DateField(label: context.tr('latest_end'), value: latest, onChanged: (d) => setSheetState(() => latest = d))),
                ],
              ),
              _DateField(label: context.tr('fixed_date'), value: fixed, onChanged: (d) => setSheetState(() => fixed = d)),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('notes')),
              _SheetTextField(controller: notesCtl, label: context.tr('notes'), hint: context.tr('hint_notes'), maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await GetIt.I<CourseRepository>().updateCourse(
                      course.id,
                      name: nameCtl.text,
                      courseNameAr: arNameCtl.text.isNotEmpty ? arNameCtl.text : null,
                      specialty: specCtl.text.isNotEmpty ? specCtl.text : null,
                      durationDays: int.tryParse(durCtl.text),
                      hoursPerDay: int.tryParse(hrsCtl.text),
                      expectedTrainees: int.tryParse(traineesCtl.text),
                      preferredCitySite: cityCtl.text.isNotEmpty ? cityCtl.text : null,
                      beneficiary: benefCtl.text.isNotEmpty ? benefCtl.text : null,
                      deliveryType: delCtl.text.isNotEmpty ? delCtl.text : null,
                      priority: priorityCtl.text.isNotEmpty ? priorityCtl.text : null,
                      earliestStart: earliest,
                      latestEnd: latest,
                      fixedDate: fixed,
                      notes: notesCtl.text.isNotEmpty ? notesCtl.text : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(context.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  for (final c in [nameCtl, arNameCtl, specCtl, durCtl, hrsCtl, traineesCtl, cityCtl, benefCtl, delCtl, priorityCtl, notesCtl]) {
    c.dispose();
  }
}

Future<void> _showTrainerEditSheet(BuildContext context, Trainer trainer) async {
  final nameCtl = TextEditingController(text: trainer.name);
  final specCtl = TextEditingController(text: trainer.specialty ?? '');
  final cityCtl = TextEditingController(text: trainer.city);
  final typeCtl = TextEditingController(text: trainer.trainerType);
  final maxDaysCtl = TextEditingController(text: trainer.maxDaysPerMonth.toString());
  final maxConsecCtl = TextEditingController(text: trainer.maxConsecutiveDays.toString());
  final costCtl = TextEditingController(text: (trainer.costPerDay ?? 0) > 0 ? trainer.costPerDay.toString() : '');
  final notesCtl = TextEditingController(text: trainer.notes ?? '');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('edit_trainer'), style: Theme.of(context).textTheme.titleLarge),
                      Text(trainer.trainerId, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 24),
              _SheetSection(title: context.tr('identity_section')),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: nameCtl, label: context.tr('full_name'), hint: context.tr('hint_full_name'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: typeCtl, label: context.tr('type'), hint: context.tr('hint_type'))),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: specCtl, label: context.tr('specialty'), hint: context.tr('hint_specialty_trainer'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: cityCtl, label: context.tr('city'), hint: context.tr('hint_city'))),
                ],
              ),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('constraints_section')),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: maxDaysCtl, label: context.tr('max_days_month'), hint: context.tr('hint_max_days_month'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: maxConsecCtl, label: context.tr('max_consecutive_days'), hint: context.tr('hint_max_consecutive'), keyboardType: TextInputType.number)),
                ],
              ),
              _SheetTextField(controller: costCtl, label: context.tr('cost_per_day'), hint: context.tr('hint_cost_per_day'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('notes')),
              _SheetTextField(controller: notesCtl, label: context.tr('notes'), hint: context.tr('hint_notes_additional'), maxLines: 3),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await GetIt.I<TrainerRepository>().updateTrainer(
                      trainer.id,
                      name: nameCtl.text,
                      specialty: specCtl.text.isNotEmpty ? specCtl.text : null,
                      city: cityCtl.text.isNotEmpty ? cityCtl.text : null,
                      trainerType: typeCtl.text.isNotEmpty ? typeCtl.text : null,
                      maxDaysPerMonth: int.tryParse(maxDaysCtl.text),
                      maxConsecutiveDays: int.tryParse(maxConsecCtl.text),
                      costPerDay: double.tryParse(costCtl.text),
                      notes: notesCtl.text.isNotEmpty ? notesCtl.text : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(context.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  for (final c in [nameCtl, specCtl, cityCtl, typeCtl, maxDaysCtl, maxConsecCtl, costCtl, notesCtl]) {
    c.dispose();
  }
}

Future<void> _showVenueEditSheet(BuildContext context, Venue venue) async {
  final nameCtl = TextEditingController(text: venue.name);
  final capCtl = TextEditingController(text: venue.capacity.toString());
  final typeCtl = TextEditingController(text: venue.venueType);
  final cityCtl = TextEditingController(text: venue.city);
  final equipCtl = TextEditingController(text: venue.equipmentNotes ?? '');

  DateTime? availFrom = venue.availableFrom;
  DateTime? availTo = venue.availableTo;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.location_on, color: Colors.purple),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('edit_venue'), style: Theme.of(context).textTheme.titleLarge),
                      Text(venue.venueId, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace', color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 24),
              _SheetSection(title: context.tr('identity_capacity_section')),
              Row(
                children: [
                  Expanded(flex: 2, child: _SheetTextField(controller: nameCtl, label: context.tr('venue_name'), hint: context.tr('hint_venue_name'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: capCtl, label: context.tr('capacity'), hint: context.tr('hint_capacity'), keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _SheetTextField(controller: typeCtl, label: context.tr('type'), hint: context.tr('hint_type_venue'))),
                  const SizedBox(width: 12),
                  Expanded(child: _SheetTextField(controller: cityCtl, label: context.tr('city'), hint: context.tr('hint_city_venue'))),
                ],
              ),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('availability_window_section')),
              Row(
                children: [
                  Expanded(child: _DateField(label: context.tr('available_from'), value: availFrom, onChanged: (d) => setSheetState(() => availFrom = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _DateField(label: context.tr('available_to'), value: availTo, onChanged: (d) => setSheetState(() => availTo = d))),
                ],
              ),
              const SizedBox(height: 20),
              _SheetSection(title: context.tr('equipment_section')),
              _SheetTextField(controller: equipCtl, label: context.tr('equipment_notes'), hint: context.tr('hint_equipment_notes'), maxLines: 2),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await GetIt.I<VenueRepository>().updateVenue(
                      venue.id,
                      name: nameCtl.text,
                      capacity: int.tryParse(capCtl.text),
                      venueType: typeCtl.text.isNotEmpty ? typeCtl.text : null,
                      city: cityCtl.text.isNotEmpty ? cityCtl.text : null,
                      availableFrom: availFrom,
                      availableTo: availTo,
                      equipmentNotes: equipCtl.text.isNotEmpty ? equipCtl.text : null,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(context.tr('save_changes'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  for (final c in [nameCtl, capCtl, typeCtl, cityCtl, equipCtl]) {
    c.dispose();
  }
}

// ─────────────────────────────────────────────
// SHARED SHEET WIDGETS
// ─────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  final String title;
  const _SheetSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;

  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final display = value != null
        ? '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'
        : context.tr('not_set');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              onChanged(picked);
            },
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(value != null ? display : context.tr('pick_date')),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────

Future<bool?> _confirmDelete(BuildContext ctx, String title, String msg) {
  return showDialog<bool>(
    context: ctx,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(ctx.tr('cancel'))),
        TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: Text(ctx.tr('delete'))),
      ],
    ),
  );
}