import '../models/board.dart';
import 'heuristics.dart';

class MediumStrategy {
  static int getBestMove(Board board) {
    List<int> validMoves = board.getValidMoves();
    if (validMoves.isEmpty) return 0;

    // 1. Prioridad: Ganar si hay oportunidad
    for (int col in validMoves) {
      Board clone = Board.clone(board);
      clone.dropPiece(col, Board.ai);
      if (clone.checkWin(Board.ai)) {
        return col;
      }
    }

    // 2. Prioridad: Bloquear victoria inminente del humano
    for (int col in validMoves) {
      Board clone = Board.clone(board);
      clone.dropPiece(col, Board.human);
      if (clone.checkWin(Board.human)) {
        return col;
      }
    }

    // 3. Evaluar la mejor columna según la heurística local (profundidad 1)
    int bestScore = -999999;
    int bestMove = validMoves.first;

    for (int col in validMoves) {
      Board clone = Board.clone(board);
      clone.dropPiece(col, Board.ai);
      int score = Heuristics.scorePosition(clone, Board.ai);
      if (score > bestScore) {
        bestScore = score;
        bestMove = col;
      }
    }

    return bestMove;
  }
}