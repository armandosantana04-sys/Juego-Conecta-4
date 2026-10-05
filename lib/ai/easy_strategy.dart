import 'dart:math';
import '../models/board.dart';

class EasyStrategy {
  static int getBestMove(Board board) {
    List<int> validMoves = board.getValidMoves();
    if (validMoves.isEmpty) return 0;

    // Si tiene una jugada ganadora inmediata, la toma
    for (int col in validMoves) {
      Board clone = Board.clone(board);
      clone.dropPiece(col, Board.ai);
      if (clone.checkWin(Board.ai)) {
        return col;
      }
    }

    // Si no, realiza una tirada al azar entre las columnas legales
    Random random = Random();
    return validMoves[random.nextInt(validMoves.length)];
  }
}