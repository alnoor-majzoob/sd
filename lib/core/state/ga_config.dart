class GaConfig {
  final int populationSize;
  final int generationLimit;
  final double mutationProbability;
  final double crossoverProbability;
  final int eliteCount;
  final int offspringMultiplier;
  final String crossoverStrategy;
  final int maxRunTimeMinutes;
  final int extraTimeMinutes;

  const GaConfig({
    this.populationSize = 50,
    this.generationLimit = 999999999,
    this.mutationProbability = 0.05,
    this.crossoverProbability = 0.8,
    this.eliteCount = 2,
    this.offspringMultiplier = 7,
    this.crossoverStrategy = 'uniform',
    this.maxRunTimeMinutes = 5,
    this.extraTimeMinutes = 1,
  });

  GaConfig copyWith({
    int? populationSize,
    int? generationLimit,
    double? mutationProbability,
    double? crossoverProbability,
    int? eliteCount,
    int? offspringMultiplier,
    String? crossoverStrategy,
    int? maxRunTimeMinutes,
    int? extraTimeMinutes,
  }) {
    return GaConfig(
      populationSize: populationSize ?? this.populationSize,
      generationLimit: generationLimit ?? this.generationLimit,
      mutationProbability: mutationProbability ?? this.mutationProbability,
      crossoverProbability: crossoverProbability ?? this.crossoverProbability,
      eliteCount: eliteCount ?? this.eliteCount,
      offspringMultiplier: offspringMultiplier ?? this.offspringMultiplier,
      crossoverStrategy: crossoverStrategy ?? this.crossoverStrategy,
      maxRunTimeMinutes: maxRunTimeMinutes ?? this.maxRunTimeMinutes,
      extraTimeMinutes: extraTimeMinutes ?? this.extraTimeMinutes,
    );
  }
}