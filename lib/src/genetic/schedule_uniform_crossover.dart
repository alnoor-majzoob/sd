import 'dart:math';

import 'package:genetic_algorithm/genetic_algorithm.dart';

import 'schedule_chromosome.dart';

class ScheduleUniformCrossover extends Crossover<ScheduleChromosome> {
  ScheduleUniformCrossover(
      {required super.probability, required super.selectionStrategy});

  @override
  ScheduleChromosome crossover(
      ScheduleChromosome parent1, ScheduleChromosome parent2, Random rnd) {
    final minLen = parent1.courseGenes.length < parent2.courseGenes.length
        ? parent1.courseGenes.length
        : parent2.courseGenes.length;

    final genes = List<CourseGene>.generate(minLen, (i) {
      final source = rnd.nextDouble() < 0.5
          ? parent1.courseGenes[i]
          : parent2.courseGenes[i];
      return source.clone();
    });

    return ScheduleChromosome(courseGenes: List.unmodifiable(genes));
  }
}
