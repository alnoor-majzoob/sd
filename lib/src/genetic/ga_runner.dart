import 'package:genetic_algorithm/genetic_algorithm.dart';

import 'schedule_uniform_crossover.dart';

import 'conflict_detector.dart';
import 'schedule_chromosome.dart';
import 'schedule_factory.dart';
import 'schedule_fitness_evaluator.dart';
import 'schedule_mutation.dart';

class ScheduleGaRunner {
  final ScheduleFactory populationFactory;
  final ScheduleFitnessEvaluator fitnessEvaluator;
  final ScheduleMutation mutation;
  final ConflictDetector conflictDetector;

  const ScheduleGaRunner({
    required this.populationFactory,
    required this.fitnessEvaluator,
    required this.mutation,
    required this.conflictDetector,
  });

  EvolutionEngine<ScheduleChromosome> buildEngine({
    required int populationSize,
    required int eliteCount,
    required String crossoverStrategy,
  }) {
    final selection = TournamentSelection<ScheduleChromosome>(
      selectionSize: 5,
      probability: 0.95,
    );

    final crossover = ScheduleUniformCrossover(
      probability: 0.9,
      selectionStrategy: selection,
    );

    final pipeline =
        OperatorsPipeline<ScheduleChromosome>(pipeline: [crossover, mutation]);

    return PlusSelectionStrategyEngine<ScheduleChromosome>(
      populationFactory: populationFactory,
      fitnessEvaluator: fitnessEvaluator,
      evolutionScheme: pipeline,
      offspringMultiplier: 7,
    );
  }

  Future<ScheduleChromosome> run({
    required int populationSize,
    required int eliteCount,
    required List<TerminationCondition<ScheduleChromosome>> terminations,
  }) async {
    final engine = buildEngine(
      populationSize: populationSize,
      eliteCount: eliteCount,
      crossoverStrategy:
          'uniform', // Placeholder — extend engine for real crossover
    );
    final settings = EngineSetting<ScheduleChromosome>(
      populationSize: populationSize,
      eliteCount: eliteCount,
      terminations: terminations,
    );

    final best = await engine.evolve(settings);
    _printResult(best);
    return best;
  }

  void _printResult(ScheduleChromosome best) {
    final summary = conflictDetector.detect(best);
    final penalty = conflictDetector.calculatePenalty(summary);
    final fitness = fitnessEvaluator.evaluate(best);

    print('============================================================');
    print('           Genetic Algorithm Evaluation Result');
    print('============================================================');
    print('Fitness Score        : ${fitness.toStringAsFixed(6)}');
    print('Penalty Score        : $penalty');
    print('Total Conflicts      : ${summary.totalConflicts}');
    print('Trainer Conflicts    : ${summary.trainerConflicts}');
    print('Venue Conflicts      : ${summary.venueConflicts}');
    print('Unresolved Genes     : ${summary.unresolvedGenes}');
    print('Date Range Conflicts : ${summary.dateRangeConflicts}');
    print('Capacity Conflicts   : ${summary.capacityConflicts}');
    print('Non-working Conflicts: ${summary.nonWorkingDayConflicts}');
    print('Holiday Conflicts    : ${summary.holidayConflicts}');
    print('------------------------------------------------------------');
    print('Best Chromosome Genes: ${best.courseGenes.length}');
    print('------------------------------------------------------------');

    for (final gene in best.courseGenes) {
      final start =
          gene.startCalendarDay?.date.toIso8601String().split('T').first ??
              'N/A';
      final end =
          gene.endCalendarDay?.date.toIso8601String().split('T').first ?? 'N/A';
      final venue = gene.venueId ?? 'Online / None';
      print(
          'AssignedCourse=${gene.assignedCourseId} | Venue=$venue | Start=$start | End=$end');
    }

    if (summary.details.isNotEmpty) {
      print('------------------------------------------------------------');
      print('Conflict Details');
      print('------------------------------------------------------------');
      for (final detail in summary.details) {
        final date = detail.date?.toIso8601String().split('T').first ?? '-';
        final related = detail.relatedEntityId ?? '-';
        print(
            '[${detail.type.name}] assigned=${detail.assignedCourseId} date=$date related=$related :: ${detail.message}');
      }
    }

    print('============================================================');
  }
}
