enum GameAvailability {
  available,
  unavailable,
  unknown;

  static GameAvailability fromBackend(Object? value) => switch (value) {
    'AVAILABLE' => available,
    'UNAVAILABLE' => unavailable,
    _ => unknown,
  };

  String get label => switch (this) {
    available => 'Available',
    unavailable => 'Unavailable',
    unknown => 'Availability unknown',
  };
}
