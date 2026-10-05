import '../models/board.dart';
import '../models/difficulty.dart';
import 'easy_strategy.dart';
import 'medium_strategy.dart';
import 'hard_strategy.dart';

class Connect4Agent {
  final Difficulty difficulty;

  Connect4Agent({required this.difficulty});

  // Decide la columna en la que soltará la ficha según la dificultad seleccionada
  int decideMove(Board board) {
    switch (difficulty) {
      case Difficulty.easy:
        return EasyStrategy.getBestMove(board);
      case Difficulty.medium:
        return MediumStrategy.getBestMove(board);
      case Difficulty.hard:
        return HardStrategy.getBestMove(board);
    }
  }
}