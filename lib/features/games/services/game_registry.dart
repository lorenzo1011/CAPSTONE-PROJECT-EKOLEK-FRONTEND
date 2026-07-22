import '../models/eco_game.dart';

class GameRegistry {
  const GameRegistry();
  bool supports(EcoGame game) => false;
  String unsupportedReason(EcoGame game) =>
      'This game is not available in this version of the app.';
}
