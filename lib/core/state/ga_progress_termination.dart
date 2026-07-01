import 'package:genetic_algorithm/genetic_algorithm.dart';

class GaProgressTermination<T> implements TerminationCondition<T> {
  final Function(int generation, T bestIndividual) onGeneration;

  GaProgressTermination({required this.onGeneration});

  @override
  bool shouldTerminate(PopulationData<T> data) {
    onGeneration(data.currentGeneration, data.fittestChromosome.data);
    return false;
  }
}

/// Custom termination condition that stops GA when:
/// 1. Elapsed run time reaches [maxRunTime].
/// 2. OR fitness reaches 1.0 (or >= 0.999999) AND the algorithm continues running
///    for [extraTime] after reaching that fitness.
class TimeAndFitnessTermination<T> implements TerminationCondition<T> {
  final Duration maxRunTime;
  final Duration extraTime;
  final double Function(T chromosome) evaluateFitness;
  final Function(int generation, Chromosome<T> bestIndividual)? onGeneration;

  final DateTime _startTime = DateTime.now();
  DateTime? _perfectFitnessReachedTime;

  TimeAndFitnessTermination({
    required this.maxRunTime,
    required this.extraTime,
    required this.evaluateFitness,
    this.onGeneration,
  });

  @override
  bool shouldTerminate(PopulationData<T> data) {
    if (onGeneration != null) {
      onGeneration!(data.currentGeneration, data.fittestChromosome);
    }

    final now = DateTime.now();
    final elapsed = now.difference(_startTime);

    // Stop if max run time reached
    if (elapsed >= maxRunTime) {
      return true;
    }

    // Check if fitness reached 1.0 (conflict-free)
    final fitness = data.fittestChromosome.fitness;
    if (fitness >= 0.999999) {
      _perfectFitnessReachedTime ??= now;
      final extraElapsed = now.difference(_perfectFitnessReachedTime!);
      if (extraElapsed >= extraTime) {
        return true;
      }
    }

    return false;
  }
}
