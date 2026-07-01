import 'package:genetic_algorithm/genetic_algorithm.dart';

import 'conflict_detector.dart';
import 'schedule_chromosome.dart';

class ScheduleFitnessEvaluator implements FitnessEvaluator<ScheduleChromosome> {
  final ConflictDetector conflictDetector;

  const ScheduleFitnessEvaluator({
    required this.conflictDetector,
  });

  @override
  double evaluate(ScheduleChromosome gene) =>
      conflictDetector.calculateFitness(gene);
}
