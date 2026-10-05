import 'dart:math';
import '../models/board.dart';
import 'heuristics.dart';

class HardStrategy {
  static const int searchDepth = 5;

  static int getBestMove(Board board) {
    List<int> validMoves = board.getValidMoves();
    if (validMoves.isEmpty) return 0;

    // Ordenar movimientos prefiriendo columnas centrales mejora la poda alfa-beta
    validMoves.sort((a, b) => (3 - a).abs().compareTo((3 - b).abs()));

    int bestScore = -10000000;
    int bestCol = validMoves.first;

    for (int col in validMoves) {
      Board tempBoard = Board.clone(board);
      tempBoard.dropPiece(col, Board.ai);

      int score = _minimax(
        tempBoard,
        searchDepth - 1,
        -10000000,
        10000000,
        false,
      );

      if (score > bestScore) {
        bestScore = score;
        bestCol = col;
      }
    }

    return bestCol;
  }

  static int _minimax(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
  ) {
    bool aiWon = board.checkWin(Board.ai);
    bool humanWon = board.checkWin(Board.human);
    bool isTerminal = aiWon || humanWon || board.isFull();

    if (depth == 0 || isTerminal) {
      if (isTerminal) {
        if (aiWon) return 1000000 + depth;
        if (humanWon) return -1000000 - depth;
        return 0; // Empate
      } else {
        return Heuristics.scorePosition(board, Board.ai);
      }
    }

    List<int> validMoves = board.getValidMoves();
    validMoves.sort((a, b) => (3 - a).abs().compareTo((3 - b).abs()));

    if (isMaximizing) {
      int maxEval = -10000000;
      for (int col in validMoves) {
        Board clone = Board.clone(board);
        clone.dropPiece(col, Board.ai);
        int eval = _minimax(clone, depth - 1, alpha, beta, false);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break; // Poda Alfa-Beta
      }
      return maxEval;
    } else {
      int minEval = 10000000;
      for (int col in validMoves) {
        Board clone = Board.clone(board);
        clone.dropPiece(col, Board.human);
        int eval = _minimax(clone, depth - 1, alpha, beta, true);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break; // Poda Alfa-Beta
      }
      return minEval;
    }
  }
}