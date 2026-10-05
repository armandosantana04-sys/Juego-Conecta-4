import '../models/board.dart';

class Heuristics {
  // Evalúa una ventana de 4 celdas y le asigna una puntuación
  static int evaluateWindow(List<int> window, int piece) {
    int score = 0;
    int oppPiece = (piece == Board.ai) ? Board.human : Board.ai;

    int pieceCount = window.where((c) => c == piece).length;
    int emptyCount = window.where((c) => c == Board.empty).length;
    int oppCount = window.where((c) => c == oppPiece).length;

    // Fichas propias consecutivas con potencial
    if (pieceCount == 4) {
      score += 100000;
    } else if (pieceCount == 3 && emptyCount == 1) {
      score += 100;
    } else if (pieceCount == 2 && emptyCount == 2) {
      score += 10;
    }

    // Penalizar si el oponente tiene 3 en línea con espacio para ganar
    if (oppCount == 3 && emptyCount == 1) {
      score -= 150;
    }

    return score;
  }

  // Evalúa el tablero completo desde la perspectiva de un jugador
  static int scorePosition(Board board, int piece) {
    int score = 0;

    // 1. Ponderación por control del centro (la columna 3 ofrece más líneas)
    List<int> centerArray = [];
    for (int r = 0; r < Board.rows; r++) {
      centerArray.add(board.grid[r][3]);
    }
    int centerCount = centerArray.where((c) => c == piece).length;
    score += centerCount * 6;

    // 2. Evaluación Horizontal
    for (int r = 0; r < Board.rows; r++) {
      for (int c = 0; c < Board.cols - 3; c++) {
        List<int> window = [
          board.grid[r][c],
          board.grid[r][c + 1],
          board.grid[r][c + 2],
          board.grid[r][c + 3],
        ];
        score += evaluateWindow(window, piece);
      }
    }

    // 3. Evaluación Vertical
    for (int c = 0; c < Board.cols; c++) {
      for (int r = 0; r < Board.rows - 3; r++) {
        List<int> window = [
          board.grid[r][c],
          board.grid[r + 1][c],
          board.grid[r + 2][c],
          board.grid[r + 3][c],
        ];
        score += evaluateWindow(window, piece);
      }
    }

    // 4. Diagonal descendente (\)
    for (int r = 0; r < Board.rows - 3; r++) {
      for (int c = 0; c < Board.cols - 3; c++) {
        List<int> window = [
          board.grid[r][c],
          board.grid[r + 1][c + 1],
          board.grid[r + 2][c + 2],
          board.grid[r + 3][c + 3],
        ];
        score += evaluateWindow(window, piece);
      }
    }

    // 5. Diagonal ascendente (/)
    for (int r = 3; r < Board.rows; r++) {
      for (int c = 0; c < Board.cols - 3; c++) {
        List<int> window = [
          board.grid[r][c],
          board.grid[r - 1][c + 1],
          board.grid[r - 2][c + 2],
          board.grid[r - 3][c + 3],
        ];
        score += evaluateWindow(window, piece);
      }
    }

    return score;
  }
}