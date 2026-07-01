import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../core/theme/app_colors.dart';
import '../../core/state/scheduling_provider.dart';
import '../../src/database/app_database.dart' as db;
import '../../src/database/model_mapper.dart';
import '../../core/localization/app_localizations.dart';
import '../../src/genetic/conflict_detector.dart';
import '../../src/genetic/schedule_chromosome.dart';
import '../../src/models/course.dart';
import '../../src/models/venue.dart' as domain;
import '../../src/models/calendar_day.dart';
import '../../src/models/assigned_course.dart';
import '../../src/models/trainer.dart';
import '../../src/export/schedule_export_service.dart';
import '../../src/utils/course_color_service.dart';

// ─────────────────────────────────────────────────────
// REACTIVE FILTER STATE PROVIDERS
// ─────────────────────────────────────────────────────

final selectedCourseFilterProvider = StateProvider<String?>((ref) => null);
final selectedVenueFilterProvider = StateProvider<String?>((ref) => null);
final selectedTrainerFilterProvider = StateProvider<String?>((ref) => null);
final selectedTimeframeProvider = StateProvider<String>((ref) => 'All');
final selectedStatusFilterProvider = StateProvider<String>((ref) => 'all');

// ─────────────────────────────────────────────────────
// PROVIDERS — Load all data needed for schedule display
// ─────────────────────────────────────────────────────

/// Fetches venues for a workspace and maps Drift → domain Venue.
final _scheduleVenuesProvider =
    FutureProvider.family<List<domain.Venue>, int>((ref, workspaceId) async {
  final database = GetIt.I<db.AppDatabase>();
  final dbVenues = await (database.select(database.venues)
        ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();

  final result = <domain.Venue>[];
  for (final v in dbVenues) {
    final unavailable = await (database.select(database.venueUnavailableDates)
          ..where((ud) => ud.venueId.equals(v.id)))
        .get();
    result
        .add(ModelMapper.mapVenue(v, unavailable.map((u) => u.date).toList()));
  }
  return result;
});

/// Fetches trainers for a workspace and maps Drift -> domain Trainer.
final _scheduleTrainersProvider =
    FutureProvider.family<List<Trainer>, int>((ref, workspaceId) async {
  final database = GetIt.I<db.AppDatabase>();
  final dbTrainers = await (database.select(database.trainers)
        ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  return dbTrainers.map((t) => ModelMapper.mapTrainer(t, [])).toList();
});

/// Fetches calendar days for a workspace.
final _scheduleCalendarProvider =
    FutureProvider.family<List<CalendarDay>, int>((ref, workspaceId) async {
  final database = GetIt.I<db.AppDatabase>();
  final rows = await (database.select(database.calendarDays)
        ..where((t) => t.workspaceId.equals(workspaceId))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]))
      .get();
  return rows.map(ModelMapper.mapCalendarDay).toList();
});

/// Fetches courses for a workspace and maps Drift → domain Course.
final _scheduleCoursesProvider =
    FutureProvider.family<Map<String, Course>, int>((ref, workspaceId) async {
  final database = GetIt.I<db.AppDatabase>();
  final dbCourses = await (database.select(database.courses)
        ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  return {for (final c in dbCourses) c.courseId: ModelMapper.mapCourse(c)};
});

/// Fetches assigned courses for a workspace and maps Drift → domain AssignedCourse.
final _scheduleAssignedProvider =
    FutureProvider.family<Map<String, AssignedCourse>, int>(
        (ref, workspaceId) async {
  final database = GetIt.I<db.AppDatabase>();
  final dbAssigned = await (database.select(database.assignedCourses)
        ..where((t) => t.workspaceId.equals(workspaceId)))
      .get();
  return {
    for (final a in dbAssigned) a.assignedId: ModelMapper.mapAssignedCourse(a)
  };
});

/// Computed: applies reactive filters to group schedule rows by venue and date range.
final _scheduleGridDataProvider =
    FutureProvider.family<ScheduleGridData, int>((ref, workspaceId) async {
  final venueFilter = ref.watch(selectedVenueFilterProvider);
  final trainerFilter = ref.watch(selectedTrainerFilterProvider);
  final timeframeFilter = ref.watch(selectedTimeframeProvider);
  final statusFilter = ref.watch(selectedStatusFilterProvider);

  final schedulesAsync = ref.watch(activeScheduleProvider(workspaceId));
  final venuesAsync = ref.watch(_scheduleVenuesProvider(workspaceId));
  final calendarAsync = ref.watch(_scheduleCalendarProvider(workspaceId));
  final coursesAsync = ref.watch(_scheduleCoursesProvider(workspaceId));
  final assignedAsync = ref.watch(_scheduleAssignedProvider(workspaceId));

  final schedules = schedulesAsync.valueOrNull ?? [];
  final venues = venuesAsync.valueOrNull ?? [];
  final calendar = calendarAsync.valueOrNull ?? [];
  final coursesById = coursesAsync.valueOrNull ?? {};
  final assignedById = assignedAsync.valueOrNull ?? {};

  // 1. Filter Venues (Rows)
  var filteredVenues = venueFilter != null
      ? venues.where((v) => v.venueId == venueFilter).toList()
      : venues;

  // 2. Filter Calendar Days (Columns)
  var workingDays =
      calendar.where((d) => d.isWorkingDay && !d.isHoliday).toList();
  if (workingDays.isNotEmpty) {
    final firstDay = workingDays.first.date;
    if (timeframeFilter == 'Week') {
      workingDays = workingDays
          .where((d) => d.date.difference(firstDay).inDays < 7)
          .toList();
    } else if (timeframeFilter == 'Month') {
      workingDays = workingDays
          .where((d) => d.date.difference(firstDay).inDays < 30)
          .toList();
    }
  }

  if (schedules.isEmpty) {
    return ScheduleGridData(
      venues: filteredVenues,
      workingDays: workingDays,
      cells: {},
      coursesById: coursesById,
    );
  }

  final cells = <String, List<ScheduleCell>>{};

  // 3. Filter Schedule Cells
  for (final schedule in schedules) {
    final assigned = assignedById[schedule.assignedCourseId];
    if (assigned == null) continue;

    final courseId = assigned.courseId;
    final trainerId = assigned.trainerId;
    final course = coursesById[courseId];

    if (trainerFilter != null && trainerId != trainerFilter) continue;
    if (statusFilter == 'conflicts' && schedule.status != 'conflict') continue;
    if (statusFilter == 'published' && schedule.status != 'published') continue;

    final venueId = schedule.venueId ?? '_online_';
    final startDate = DateTime(schedule.startDate.year,
        schedule.startDate.month, schedule.startDate.day);
    final endDate = DateTime(
        schedule.endDate.year, schedule.endDate.month, schedule.endDate.day);

    var current = startDate;
    while (!current.isAfter(endDate)) {
      final dateKey = _dateKey(current);
      final key = '$venueId|$dateKey';
      cells.putIfAbsent(key, () => []).add(ScheduleCell(
            scheduleId: schedule.id.toString(),
            assignedId: schedule.assignedCourseId,
            courseId: courseId,
            courseName: (course != null && course.courseNameAr.isNotEmpty)
                ? (course.courseNameEn.isNotEmpty
                    ? '${course.courseNameEn}\n${course.courseNameAr}'
                    : course.courseNameAr)
                : (course?.courseNameEn ?? courseId),
            durationHours: course?.hoursPerDay ?? 8,
            startTime: _formatTime(schedule.startDate),
            endTime: _formatTime(schedule.endDate),
            trainerId: trainerId,
            status: schedule.status,
          ));
      current = current.add(const Duration(days: 1));
    }
  }

  if (trainerFilter != null && venueFilter == null) {
    final activeVenueIds = cells.keys.map((k) => k.split('|')[0]).toSet();
    filteredVenues = filteredVenues
        .where((v) => activeVenueIds.contains(v.venueId))
        .toList();
  }

  return ScheduleGridData(
    venues: filteredVenues,
    workingDays: workingDays,
    cells: cells,
    coursesById: coursesById,
  );
});

/// Computed: runs ConflictDetector on the schedule and returns issues.
final _scheduleIssuesProvider =
    FutureProvider.family<List<ConflictDetail>, int>((ref, workspaceId) async {
  final schedulesAsync = ref.watch(activeScheduleProvider(workspaceId));
  final assignedAsync = ref.watch(_scheduleAssignedProvider(workspaceId));
  final coursesAsync = ref.watch(_scheduleCoursesProvider(workspaceId));
  final venuesAsync = ref.watch(_scheduleVenuesProvider(workspaceId));
  final calendarAsync = ref.watch(_scheduleCalendarProvider(workspaceId));

  final schedules = schedulesAsync.valueOrNull ?? [];
  final assignedList = assignedAsync.valueOrNull?.values.toList() ?? [];
  final coursesList = coursesAsync.valueOrNull?.values.toList() ?? [];
  final venues = venuesAsync.valueOrNull ?? [];
  final calendar = calendarAsync.valueOrNull ?? [];

  if (schedules.isEmpty || calendar.isEmpty) return [];

  final calendarByKey = {for (final d in calendar) _dateKey(d.date): d};

  final genes = schedules.map((s) {
    final startCal = calendarByKey[_dateKey(s.startDate)];
    final endCal = calendarByKey[_dateKey(s.endDate)];

    return CourseGene(
      assignedCourseId: s.assignedCourseId,
      venueId: s.venueId,
      startCalendarDay: startCal,
      endCalendarDay: endCal,
    );
  }).toList();

  final chromosome = ScheduleChromosome(courseGenes: genes);
  final detector = ConflictDetector(
    assignedCourses: assignedList,
    courses: coursesList,
    venues: venues,
    calendar: calendar,
  );

  return detector.detect(chromosome).details;
});

// ─────────────────────────────────────────────────────
// DATA TYPES
// ─────────────────────────────────────────────────────

class ScheduleGridData {
  final List<domain.Venue> venues;
  final List<CalendarDay> workingDays;

  /// Map from "venueId|dateKey" → cells for that slot
  final Map<String, List<ScheduleCell>> cells;
  final Map<String, Course> coursesById;

  const ScheduleGridData({
    required this.venues,
    required this.workingDays,
    required this.cells,
    required this.coursesById,
  });

  bool get isEmpty => venues.isEmpty && workingDays.isEmpty;
}

class ScheduleCell {
  final String scheduleId;
  final String assignedId;
  final String courseId;
  final String courseName;
  final int durationHours;
  final String startTime;
  final String endTime;
  final String? trainerId;
  final String status;

  const ScheduleCell({
    required this.scheduleId,
    required this.assignedId,
    required this.courseId,
    required this.courseName,
    required this.durationHours,
    required this.startTime,
    required this.endTime,
    this.trainerId,
    required this.status,
  });

  bool get hasConflict => status == 'conflict';
  bool get hasWarning => status == 'warning';
}

// ─────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────

String _dateKey(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

// ─────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────

class ScheduleViewScreen extends ConsumerWidget {
  const ScheduleViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final activeWorkspaceAsync = ref.watch(workspacesProvider);

    if (workspaceId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_outlined,
                size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(context.tr('select_workspace_first_schedule')),
          ],
        ),
      );
    }

    final workspaceName = activeWorkspaceAsync.whenOrNull(
          data: (workspaces) =>
              workspaces.where((w) => w.id == workspaceId).firstOrNull?.name,
        ) ??
        'Workspace #$workspaceId';

    final gridDataAsync = ref.watch(_scheduleGridDataProvider(workspaceId));
    final issuesAsync = ref.watch(_scheduleIssuesProvider(workspaceId));

    return gridDataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text(context.trArgs('error_loading_schedule', [err.toString()]))),
      data: (gridData) {
        if (gridData.cells.isEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, workspaceId, workspaceName),
                const SizedBox(height: 48),
                const _EmptyScheduleState(),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, ref, workspaceId, workspaceName),
              const SizedBox(height: 24),
              _buildToolbar(context, ref, workspaceId),
              const SizedBox(height: 16),
              _CourseLegendBar(workspaceId: workspaceId),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 75,
                    child: _ScheduleGrid(data: gridData),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 25,
                    child: _IssuesPanel(issues: issuesAsync.valueOrNull ?? []),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, int wId, String workspaceName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('final_schedule'),
                style: Theme.of(context).textTheme.displayLarge),
            Text(
              workspaceName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _exportPdf(context, ref, wId),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: Text(context.tr('export_pdf')),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _exportExcel(context, ref, wId),
              icon: const Icon(Icons.table_chart, size: 18),
              label: Text(context.tr('export_excel')),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _publishSchedule(context, ref, wId),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: Text(context.tr('publish_schedule')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, int workspaceId) {
    final venuesAsync = ref.watch(_scheduleVenuesProvider(workspaceId));
    final trainersAsync = ref.watch(_scheduleTrainersProvider(workspaceId));
    final venues = venuesAsync.valueOrNull ?? [];
    final trainers = trainersAsync.valueOrNull ?? [];

    final selectedVenue = ref.watch(selectedVenueFilterProvider);
    final selectedTrainer = ref.watch(selectedTrainerFilterProvider);
    final selectedTimeframe = ref.watch(selectedTimeframeProvider);
    final selectedStatus = ref.watch(selectedStatusFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _VenueFilterDropdown(
                venues: venues,
                selectedValue: selectedVenue,
                onChanged: (v) =>
                    ref.read(selectedVenueFilterProvider.notifier).state = v,
              ),
              const SizedBox(width: 8),
              _TrainerFilterDropdown(
                trainers: trainers,
                selectedValue: selectedTrainer,
                onChanged: (v) =>
                    ref.read(selectedTrainerFilterProvider.notifier).state = v,
              ),
              const SizedBox(width: 8),
              _TimeframeToggle(
                selectedTimeframe: selectedTimeframe,
                onChanged: (t) =>
                    ref.read(selectedTimeframeProvider.notifier).state = t,
              ),
            ],
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _StatusFilterChip(
                label: context.tr('filter_all'),
                isActive: selectedStatus == 'all',
                onTap: () => ref
                    .read(selectedStatusFilterProvider.notifier)
                    .state = 'all',
              ),
              const SizedBox(width: 8),
              _StatusFilterChip(
                label: context.tr('conflicts_only'),
                isActive: selectedStatus == 'conflicts',
                onTap: () => ref
                    .read(selectedStatusFilterProvider.notifier)
                    .state = 'conflicts',
              ),
              const SizedBox(width: 8),
              _StatusFilterChip(
                label: context.tr('published'),
                isActive: selectedStatus == 'published',
                onTap: () => ref
                    .read(selectedStatusFilterProvider.notifier)
                    .state = 'published',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref, int wId) async {
    // PDF export requires a PDF generation package (e.g. pdf, pdf_render).
    // For now, export the full workspace data as Excel as a data backup.
    await _exportWorkspaceExcel(context, ref, wId);
  }

  Future<void> _exportExcel(
      BuildContext context, WidgetRef ref, int wId) async {
    // Export only the generated schedule report as Excel
    await _exportScheduleExcel(context, ref, wId);
  }

  Future<void> _exportScheduleExcel(
      BuildContext context, WidgetRef ref, int wId) async {
    final workspacesAsync = ref.read(workspacesProvider);
    final wsName = workspacesAsync.whenOrNull(
          data: (ws) => ws.where((w) => w.id == wId).firstOrNull?.name,
        ) ??
        'Workspace_$wId';

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(context.tr('exporting_schedule')),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    try {
      final exportService = GetIt.I<ScheduleExportService>();
      final filePath = await exportService.exportScheduleOnly(wId, wsName);

      messenger.hideCurrentSnackBar();

      if (filePath != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(context.trArgs('exported_schedule', [filePath]))),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(context.trArgs('export_failed', [e.toString()]))),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _exportWorkspaceExcel(
      BuildContext context, WidgetRef ref, int wId) async {
    // Get workspace name for the file
    final workspacesAsync = ref.read(workspacesProvider);
    final wsName = workspacesAsync.whenOrNull(
          data: (ws) => ws.where((w) => w.id == wId).firstOrNull?.name,
        ) ??
        'Workspace_$wId';

    // Show loading indicator
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(context.tr('generating_excel')),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );

    try {
      final exportService = GetIt.I<ScheduleExportService>();
      final filePath = await exportService.exportWorkspace(wId, wsName);

      messenger.hideCurrentSnackBar();

      if (filePath != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(context.trArgs('exported_to', [filePath]))),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: context.tr('open_folder'),
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(context.trArgs('export_failed', [e.toString()]))),
            ],
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _publishSchedule(
      BuildContext context, WidgetRef ref, int wId) async {
    try {
      // Mark all schedules as 'published'
      final database = GetIt.I<db.AppDatabase>();
      await (database.update(database.schedules)
            ..where((t) => t.workspaceId.equals(wId)))
          .write(
        const db.SchedulesCompanion(status: Value('published')),
      );

      // Invalidate the schedule provider so UI refreshes
      ref.invalidate(activeScheduleProvider(wId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(context.tr('publish_success')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.trArgs('publish_failed', [e.toString()])), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────
// SCHEDULE GRID
// ─────────────────────────────────────────────────────

class _ScheduleGrid extends StatelessWidget {
  final ScheduleGridData data;

  const _ScheduleGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final days = data.workingDays.toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 0,
          horizontalMargin: 0,
          dataRowMinHeight: 80,
          dataRowMaxHeight: 80,
          headingRowColor:
              WidgetStateProperty.all(AppColors.surfaceContainerLow),
          columns: [
            DataColumn(
              label: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  context.tr('venue'),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...days.map((day) => DataColumn(
                  label: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.dayName.isNotEmpty
                              ? day.dayName
                              : _shortDayName(context, day.date),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: day.isHoliday ? Colors.red : null,
                                  ),
                        ),
                        Text(
                          '${day.date.month}/${day.date.day}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          rows: [
            // Online/virtual venue row
            DataRow(
              color: WidgetStateProperty.all(AppColors.surfaceContainerLowest),
              cells: [
                DataCell(Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(context.tr('online_virtual'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(context.tr('no_venue_required'),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                )),
                ...days.map(
                    (day) => DataCell(_buildCell(context, '_online_', day))),
              ],
            ),
            // Physical venue rows — venues is now domain.Venue[]
            ...data.venues.where((v) {
              final t = v.venueType.trim().toLowerCase();
              return t != 'online' && t != 'virtual';
            }).map((venue) => DataRow(
                  cells: [
                    DataCell(Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // BUG A FIX: venueName is domain Venue property
                          Text(venue.venueName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(context.trArgs('capacity_label', [venue.capacity.toString()]),
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    )),
                    ...days.map((day) =>
                        DataCell(_buildCell(context, venue.venueId, day))),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, String venueId, CalendarDay day) {
    final key = '$venueId|${_dateKey(day.date)}';
    final cells = data.cells[key] ?? [];

    if (cells.isEmpty) {
      return const SizedBox(width: 120, height: 64);
    }

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cells
            .map((cell) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _SessionChip(cell: cell),
                ))
            .toList(),
      ),
    );
  }

  String _shortDayName(BuildContext context, DateTime date) {
    final names = [
      context.tr('mon'),
      context.tr('tue'),
      context.tr('wed'),
      context.tr('thu'),
      context.tr('fri'),
      context.tr('sat'),
      context.tr('sun'),
    ];
    return names[date.weekday - 1];
  }
}

// ─────────────────────────────────────────────────────
// COURSE LEGEND BAR & FILTER
// ─────────────────────────────────────────────────────

class _CourseLegendBar extends ConsumerWidget {
  final int workspaceId;

  const _CourseLegendBar({required this.workspaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(_scheduleCoursesProvider(workspaceId));
    final coursesMap = coursesAsync.valueOrNull ?? {};
    if (coursesMap.isEmpty) return const SizedBox.shrink();

    final selectedCourseId = ref.watch(selectedCourseFilterProvider);
    final courses = coursesMap.values.toList()
      ..sort((a, b) => a.courseNameEn.compareTo(b.courseNameEn));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const Icon(Icons.palette_outlined,
                  size: 16, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                context.tr('spotlight_filter'),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (selectedCourseId != null)
                TextButton.icon(
                  onPressed: () => ref
                      .read(selectedCourseFilterProvider.notifier)
                      .state = null,
                  icon: const Icon(Icons.clear_all, size: 14),
                  label: Text(context.tr('show_all'),
                      style: const TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CourseLegendChip(
                  label: context.tr('all_courses'),
                  color: const Color(0xFF1E3A5F),
                  isSelected: selectedCourseId == null,
                  onTap: () => ref
                      .read(selectedCourseFilterProvider.notifier)
                      .state = null,
                ),
                const SizedBox(width: 8),
                ...courses.map((c) {
                  final color = CourseColorService.getColor(c.courseId);
                  final label = (context.isAr && c.courseNameAr.isNotEmpty)
                      ? c.courseNameAr
                      : (c.courseNameEn.isNotEmpty
                          ? c.courseNameEn
                          : c.courseId);
                  final isSelected = selectedCourseId == c.courseId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _CourseLegendChip(
                      label: label,
                      color: color,
                      isSelected: isSelected,
                      isDimmed: selectedCourseId != null && !isSelected,
                      onTap: () {
                        if (isSelected) {
                          ref
                              .read(selectedCourseFilterProvider.notifier)
                              .state = null;
                        } else {
                          ref
                              .read(selectedCourseFilterProvider.notifier)
                              .state = c.courseId;
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseLegendChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  const _CourseLegendChip({
    required this.label,
    required this.color,
    required this.isSelected,
    this.isDimmed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDimmed ? 0.35 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : color.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SESSION CHIP — Distinctive Color Coding & Leading Strip
// ─────────────────────────────────────────────────────

class _SessionChip extends ConsumerWidget {
  final ScheduleCell cell;

  const _SessionChip({required this.cell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCourseId = ref.watch(selectedCourseFilterProvider);
    final isSpotlightDimmed =
        selectedCourseId != null && selectedCourseId != cell.courseId;
    final courseColor = CourseColorService.getColor(cell.courseId);

    Color bgColor;
    Color textColor;
    Color leadingBorderColor;
    Border? border;

    if (cell.hasConflict) {
      bgColor = AppColors.errorContainer;
      textColor = Colors.white;
      leadingBorderColor = AppColors.error;
      border = Border.all(color: AppColors.error, width: 1.5);
    } else {
      bgColor = courseColor.withValues(alpha: 0.16);
      textColor = AppColors.onSurface;
      leadingBorderColor = courseColor;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isSpotlightDimmed ? 0.22 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2.5),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cell.startTime,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontFamily: 'monospace',
                          color: cell.hasConflict
                              ? Colors.white70
                              : courseColor.withValues(alpha: 0.95),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (cell.hasConflict)
                    const Icon(Icons.error, color: Colors.white, size: 14)
                  else
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: courseColor, shape: BoxShape.circle),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                cell.courseName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      fontSize: 11,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ISSUES PANEL
// ─────────────────────────────────────────────────────

class _IssuesPanel extends StatelessWidget {
  final List<ConflictDetail> issues;

  const _IssuesPanel({required this.issues});

  @override
  Widget build(BuildContext context) {
    final criticalCount = issues
        .where((i) =>
            i.type == ConflictType.trainerOverlap ||
            i.type == ConflictType.venueOverlap ||
            i.type == ConflictType.invalidDateRange)
        .length;

    final warningCount = issues
        .where((i) =>
            i.type == ConflictType.capacityExceeded ||
            i.type == ConflictType.nonWorkingDay ||
            i.type == ConflictType.holiday)
        .length;

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
              Icon(
                issues.isEmpty
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_rounded,
                color: issues.isEmpty ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(context.tr('issues'), style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              if (issues.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text('${issues.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          if (issues.isEmpty) ...[
            const SizedBox(height: 16),
            Text(context.tr('no_conflicts'),
                style: const TextStyle(color: Colors.green, fontSize: 13)),
          ] else ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (criticalCount > 0)
                  _IssueBadge(
                      count: criticalCount,
                      label: context.tr('critical'),
                      color: Colors.red),
                if (warningCount > 0)
                  _IssueBadge(
                      count: warningCount,
                      label: context.tr('warning'),
                      color: Colors.amber),
              ],
            ),
            const SizedBox(height: 16),
            ...issues.map((issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _IssueCard(detail: issue),
                )),
          ],
        ],
      ),
    );
  }
}

class _IssueBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _IssueBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
          ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final ConflictDetail detail;

  const _IssueCard({required this.detail});

  Color get _borderColor {
    switch (detail.type) {
      case ConflictType.trainerOverlap:
      case ConflictType.venueOverlap:
      case ConflictType.invalidDateRange:
        return Colors.red;
      case ConflictType.capacityExceeded:
      case ConflictType.nonWorkingDay:
      case ConflictType.holiday:
        return Colors.amber;
      default:
        return AppColors.outline;
    }
  }

  IconData get _icon {
    switch (detail.type) {
      case ConflictType.trainerOverlap:
        return Icons.person_outline;
      case ConflictType.venueOverlap:
        return Icons.location_on_outlined;
      case ConflictType.capacityExceeded:
        return Icons.groups_outlined;
      case ConflictType.nonWorkingDay:
        return Icons.calendar_today_outlined;
      case ConflictType.holiday:
        return Icons.event_busy_outlined;
      default:
        return Icons.warning_outlined;
    }
  }

  String _getTitle(BuildContext context) {
    switch (detail.type) {
      case ConflictType.trainerOverlap:
        return context.tr('trainer_overlap');
      case ConflictType.venueOverlap:
        return context.tr('venue_conflict');
      case ConflictType.invalidDateRange:
        return context.tr('invalid_date_range');
      case ConflictType.capacityExceeded:
        return context.tr('capacity_exceeded');
      case ConflictType.nonWorkingDay:
        return context.tr('non_working_day');
      case ConflictType.holiday:
        return context.tr('holiday_conflict');
      case ConflictType.unresolvedGene:
        return context.tr('missing_data');
    }
  }

  String get _dateLabel {
    if (detail.date != null) {
      return '${detail.date!.month}/${detail.date!.day}/${detail.date!.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 14, color: _borderColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _getTitle(context),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (_dateLabel.isNotEmpty)
                Text(
                  _dateLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            detail.message,
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// TOOLBAR WIDGETS
// ─────────────────────────────────────────────────────

class _VenueFilterDropdown extends StatelessWidget {
  final List<domain.Venue> venues;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _VenueFilterDropdown({
    required this.venues,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surfaceContainerLowest,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            context.trArgs('all_venues_count', [venues.length.toString()]),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          items: [
            DropdownMenuItem(
                value: null,
                child: Text(context.tr('all_venues'))),
            ...venues.map((v) => DropdownMenuItem(
                  value: v.venueId,
                  child: Text(v.venueName),
                )),
          ],
          onChanged: onChanged,
          icon: const Icon(Icons.expand_more,
              size: 16, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TrainerFilterDropdown extends StatelessWidget {
  final List<Trainer> trainers;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _TrainerFilterDropdown({
    required this.trainers,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.surfaceContainerLowest,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            context.trArgs('all_trainers_count', [trainers.length.toString()]),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          items: [
            DropdownMenuItem(
                value: null,
                child: Text(context.tr('all_trainers'))),
            ...trainers.map((t) => DropdownMenuItem(
                  value: t.trainerId,
                  child: Text(t.trainerName),
                )),
          ],
          onChanged: onChanged,
          icon: const Icon(Icons.expand_more,
              size: 16, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TimeframeToggle extends StatelessWidget {
  final String selectedTimeframe;
  final ValueChanged<String> onChanged;

  const _TimeframeToggle({
    required this.selectedTimeframe,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: context.tr('week'),
            isSelected: selectedTimeframe == 'Week',
            onTap: () => onChanged('Week'),
          ),
          _ToggleOption(
            label: context.tr('month'),
            isSelected: selectedTimeframe == 'Month',
            onTap: () => onChanged('Month'),
          ),
          _ToggleOption(
            label: context.tr('filter_all'),
            isSelected: selectedTimeframe == 'All',
            onTap: () => onChanged('All'),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(99),
          color: isActive ? AppColors.primaryContainer : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_month_outlined,
                size: 40, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Text(
            context.tr('no_schedule_yet'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('run_ga_hint'),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow, size: 18),
            label: Text(context.tr('run_ga_button')),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
