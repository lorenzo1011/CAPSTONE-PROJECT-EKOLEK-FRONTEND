enum EcoGameType {
  wasteSorting,
  recyclingQuiz,
  ecoMemory,
  ecoDefender,
  other,
  unknown;

  static EcoGameType fromBackend(Object? value) => switch (value) {
    'WASTE_SORTING' => wasteSorting,
    'RECYCLING_QUIZ_GAME' => recyclingQuiz,
    'ECO_MEMORY_GAME' => ecoMemory,
    'ECO_DEFENDER' => ecoDefender,
    'OTHER' => other,
    _ => unknown,
  };
  String get label => switch (this) {
    wasteSorting => 'Waste sorting',
    recyclingQuiz => 'Recycling quiz',
    ecoMemory => 'Eco memory',
    ecoDefender => 'Eco Defender',
    other => 'Other',
    unknown => 'Unknown game type',
  };
}
