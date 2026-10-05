class Board {
  static const int rows = 6;
  static const int cols = 7;

  static const int empty = 0;
  static const int human = 1;
  static const int ai = 2;

  late List<List<int>> grid;

  Board() {
    grid = List.generate(rows, (_) => List.filled(cols, empty));
  }

  // Constructor para clonar el estado durante simulaciones de IA
  Board.clone(Board original) {
    grid = List.generate(
      rows,
      (r) => List<int>.from(original.grid[r]),
    );
  }

  // Verifica si la columna tiene espacio disponible
  bool isValidMove(int col) {
    if (col < 0 || col >= cols) return false;
    return grid[0][col] == empty;
  }

  // Obtiene la lista de todas las columnas donde se puede tirar
  List<int> getValidMoves() {
    List<int> validMoves = [];
    for (int c = 0; c < cols; c++) {
      if (isValidMove(c)) {
        validMoves.add(c);
      }
    }
    return validMoves;
  }

  // Suelta la ficha en la fila más baja disponible (simulando gravedad)
  // Retorna la fila donde cayó, o -1 si no fue posible
  int dropPiece(int col, int player) {
    if (!isValidMove(col)) return -1;

    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r][col] == empty) {
        grid[r][col] = player;
        return r;
      }
    }
    return -1;
  }

  // Revisa si el jugador indicado formó 4 en línea
  bool checkWin(int player) {
    // 1. Horizontal
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols - 3; c++) {
        if (grid[r][c] == player &&
            grid[r][c + 1] == player &&
            grid[r][c + 2] == player &&
            grid[r][c + 3] == player) {
          return true;
        }
      }
    }

    // 2. Vertical
    for (int r = 0; r < rows - 3; r++) {
      for (int c = 0; c < cols; c++) {
        if (grid[r][c] == player &&
            grid[r + 1][c] == player &&
            grid[r + 2][c] == player &&
            grid[r + 3][c] == player) {
          return true;
        }
      }
    }

    // 3. Diagonal descendente (\)
    for (int r = 0; r < rows - 3; r++) {
      for (int c = 0; c < cols - 3; c++) {
        if (grid[r][c] == player &&
            grid[r + 1][c + 1] == player &&
            grid[r + 2][c + 2] == player &&
            grid[r + 3][c + 3] == player) {
          return true;
        }
      }
    }

    // 4. Diagonal ascendente (/)
    for (int r = 3; r < rows; r++) {
      for (int c = 0; c < cols - 3; c++) {
        if (grid[r][c] == player &&
            grid[r - 1][c + 1] == player &&
            grid[r - 2][c + 2] == player &&
            grid[r - 3][c + 3] == player) {
          return true;
        }
      }
    }

    return false;
  }

  // Verifica si el tablero está lleno (empate)
  bool isFull() {
    return getValidMoves().isEmpty;
  }
}