import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genetic_algorithm/genetic_algorithm.dart';
import 'package:get_it/get_it.dart';

import '../../src/database/app_database.dart' as db;
import '../../src/database/repositories/repository_provider.dart';
import '../../src/database/model_mapper.dart';
import '../../src/genetic/ga_runner.dart';
import '../../src/genetic/schedule_chromosome.dart';
import '../../src/genetic/schedule_fitness_evaluator.dart';
import '../../src/genetic/schedule_mutation.dart';
import '../../src/genetic/schedule_factory.dart';
import '../../src/genetic/conflict_detector.dart';
import '../../src/models/trainer.dart';
import '../../src/models/venue.dart';
import '../../src/scheduling/calendar_manager.dart';
import 'ga_config.dart';
import 'ga_progress_termination.dart';

class GaRunState {
  final int currentGeneration;
  final double currentFitness;
  final double bestFitness; // ← highest fitness seen across all generations
  final bool isRunning;
  final bool isEvaluationDone;
  final ScheduleChromosome? pendingBestChromosome;
  final String? error;
  final List<FlSpot> fitnessPoints;
  final GaConfig config;
  final DateTime? startTime;

  const GaRunState({
    this.currentGeneration = 0,
    this.currentFitness = 0.0,
    this.bestFitness = 0.0,
    this.isRunning = false,
    this.isEvaluationDone = false,
    this.pendingBestChromosome,
    this.error,
    this.fitnessPoints = const [],
    this.config = const GaConfig(),
    this.startTime,
  });

  GaRunState copyWith({
    int? currentGeneration,
    double? currentFitness,
    double? bestFitness,
    bool? isRunning,
    bool? isEvaluationDone,
    ScheduleChromosome? pendingBestChromosome,
    bool clearPendingChromosome = false,
    String? error,
    List<FlSpot>? fitnessPoints,
    GaConfig? config,
    DateTime? startTime,
  }) {
    return GaRunState(
      currentGeneration: currentGeneration ?? this.currentGeneration,
      currentFitness: currentFitness ?? this.currentFitness,
      bestFitness: bestFitness ?? this.bestFitness,
      isRunning: isRunning ?? this.isRunning,
      isEvaluationDone: isEvaluationDone ?? this.isEvaluationDone,
      pendingBestChromosome: clearPendingChromosome
          ? null
          : (pendingBestChromosome ?? this.pendingBestChromosome),
      error: error ?? this.error,
      fitnessPoints: fitnessPoints ?? this.fitnessPoints,
      config: config ?? this.config,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Adds a fitness data point with automatic sliding window eviction.
  /// Keeps at most [maxPoints] entries and tracks best fitness.
  GaRunState addFitnessPoint(int generation, double fitness) {
    const maxPoints = 500;
    final newPoints = [
      ...fitnessPoints,
      FlSpot(generation.toDouble(), fitness)
    ];
    final trimmed = newPoints.length > maxPoints
        ? newPoints.sublist(newPoints.length - maxPoints)
        : newPoints;
    final best = fitness > bestFitness ? fitness : bestFitness;
    return copyWith(fitnessPoints: trimmed, bestFitness: best);
  }

  double get timeProgress {
    if (startTime == null || !isRunning) {
      return isEvaluationDone ? 1.0 : 0.0;
    }
    final elapsed = DateTime.now().difference(startTime!).inSeconds;
    final total = config.maxRunTimeMinutes * 60;
    return total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
  }

  String get estimatedRemaining {
    if (startTime == null || !isRunning) return '—';
    final elapsed = DateTime.now().difference(startTime!).inSeconds;
    final total = config.maxRunTimeMinutes * 60;
    final remaining = total - elapsed;
    if (remaining <= 0) return 'Extra time / stopping...';
    if (remaining < 60) return '${remaining}s';
    final m = (remaining / 60).floor();
    final s = remaining % 60;
    return '${m}m ${s}s';
  }

  String get elapsedTimeFormatted {
    if (startTime == null) return '00:00:00';
    final elapsed = DateTime.now().difference(startTime!);
    final h = elapsed.inHours.toString().padLeft(2, '0');
    final m = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get statusLabel {
    if (isRunning) return 'OPTIMIZING';
    if (isEvaluationDone) return 'CONFIRMING';
    if (error != null) return 'FAILED';
    if (currentGeneration > 0) return 'COMPLETED';
    return 'IDLE';
  }

  /// Improvement delta: how much better is current vs best seen so far
  String get improvementDelta {
    if (bestFitness == 0) return '+0.0000';
    final delta = currentFitness - bestFitness;
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(4)}';
  }
}

class GaController extends StateNotifier<GaRunState> {
  GaController() : super(const GaRunState());

  void updateConfig(GaConfig config) {
    state = state.copyWith(config: config);
  }

  void stop() {
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    state = const GaRunState();
  }

  Future<void> runOptimization(int workspaceId) async {
    state = state.copyWith(
      isRunning: true,
      error: null,
      startTime: DateTime.now(),
      currentGeneration: 0,
      currentFitness: 0.0,
      bestFitness: 0.0,
      fitnessPoints: [],
    );

    try {
      final database = GetIt.I<db.AppDatabase>();
      final repos = GetIt.I<RepositoryProvider>();

      // 1. Load and Map Data from DB to Domain Models
      final dbAssigned = await (database.select(database.assignedCourses)
            ..where((t) => t.workspaceId.equals(workspaceId)))
          .get();
      final dbCourses = await (database.select(database.courses)
            ..where((t) => t.workspaceId.equals(workspaceId)))
          .get();
      final dbTrainers = await (database.select(database.trainers)
            ..where((t) => t.workspaceId.equals(workspaceId)))
          .get();
      final dbVenues = await (database.select(database.venues)
            ..where((t) => t.workspaceId.equals(workspaceId)))
          .get();
      final dbCalendar = await (database.select(database.calendarDays)
            ..where((t) => t.workspaceId.equals(workspaceId)))
          .get();

      final domainCourses = dbCourses.map(ModelMapper.mapCourse).toList();
      final domainCalendar =
          dbCalendar.map(ModelMapper.mapCalendarDay).toList();
      final domainAssigned =
          dbAssigned.map(ModelMapper.mapAssignedCourse).toList();

      final domainTrainers = <Trainer>[];
      for (final t in dbTrainers) {
        final unavailable =
            await (database.select(database.trainerUnavailableDates)
                  ..where((ud) => ud.trainerId.equals(t.id)))
                .get();
        domainTrainers.add(
            ModelMapper.mapTrainer(t, unavailable.map((u) => u.date).toList()));
      }

      final domainVenues = <Venue>[];
      for (final v in dbVenues) {
        final unavailable =
            await (database.select(database.venueUnavailableDates)
                  ..where((ud) => ud.venueId.equals(v.id)))
                .get();
        domainVenues.add(
            ModelMapper.mapVenue(v, unavailable.map((u) => u.date).toList()));
      }

      // 2. Initialize GA Components
      final calendarManager = CalendarManager(domainCalendar);
      final conflictDetector = ConflictDetector(
        assignedCourses: domainAssigned,
        courses: domainCourses,
        venues: domainVenues,
        calendar: domainCalendar,
      );

      final factory = ScheduleFactory(
        assignedCourses: domainAssigned,
        courses: domainCourses,
        trainers: domainTrainers,
        venues: domainVenues,
        calendarManager: calendarManager,
        greedyInitializationRatio: 0.0,
      );

      final mutation = ScheduleMutation(
        assignedCourses: domainAssigned,
        courses: domainCourses,
        trainers: domainTrainers,
        venues: domainVenues,
        calendarManager: calendarManager,
        probability: state.config.mutationProbability,
      );

      final fitnessEvaluator = ScheduleFitnessEvaluator(
        conflictDetector: conflictDetector,
      );

      final runner = ScheduleGaRunner(
        populationFactory: factory,
        fitnessEvaluator: fitnessEvaluator,
        mutation: mutation,
        conflictDetector: conflictDetector,
      );

      // 3. Throttle: report progress at most once per second
      DateTime lastUpdate = DateTime.now();
      int lastReportedGeneration = 0;

      // 4. Run GA with config-driven settings
      final best = await runner.run(
        populationSize: 5,
        eliteCount: 0,
        terminations: <TerminationCondition<ScheduleChromosome>>[
          TimeAndFitnessTermination<ScheduleChromosome>(
            maxRunTime: Duration(minutes: state.config.maxRunTimeMinutes),
            extraTime: Duration(minutes: state.config.extraTimeMinutes),
            evaluateFitness: fitnessEvaluator.evaluate,
            onGeneration: (gen, bestIndividual) {
              if (gen <= lastReportedGeneration) return;
              lastReportedGeneration = gen;

              final now = DateTime.now();
              if (now.difference(lastUpdate).inMilliseconds >= 500) {
                final fitness = bestIndividual.fitness;
                state = state.addFitnessPoint(gen, fitness).copyWith(
                      currentGeneration: gen,
                      currentFitness: fitness,
                    );
                lastUpdate = now;
              }
            },
          ),
        ],
      );

      if (best.courseGenes.isNotEmpty) {
        final finalFitness = fitnessEvaluator.evaluate(best);
        state = state
            .addFitnessPoint(state.currentGeneration, finalFitness)
            .copyWith(
              currentFitness: finalFitness,
              bestFitness: finalFitness > state.bestFitness
                  ? finalFitness
                  : state.bestFitness,
              isRunning: false,
              isEvaluationDone: true,
              pendingBestChromosome: best,
            );
      } else {
        state = state.copyWith(isRunning: false);
      }
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> savePendingSchedule(int workspaceId) async {
    final best = state.pendingBestChromosome;
    if (best == null) return;

    final repos = GetIt.I<RepositoryProvider>();
    await repos.scheduleRepo.clearSchedulesForWorkspace(workspaceId);
    for (final gene in best.courseGenes) {
      await repos.scheduleRepo.saveSchedule(
        workspaceId: workspaceId,
        assignedCourseId: gene.assignedCourseId,
        venueId: gene.venueId,
        startDate: gene.startCalendarDay?.date ?? DateTime.now(),
        endDate: gene.endCalendarDay?.date ?? DateTime.now(),
      );
    }
    state =
        state.copyWith(isEvaluationDone: false, clearPendingChromosome: true);
  }

  void discardPendingSchedule() {
    state =
        state.copyWith(isEvaluationDone: false, clearPendingChromosome: true);
  }
}

final gaControllerProvider =
    StateNotifierProvider<GaController, GaRunState>((ref) {
  return GaController();
});
