import 'package:flutter/material.dart';
import '../../models/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final Function(int) onColumnSelected;

  const BoardWidget({
    super.key,
    required this.board,
    required this.onColumnSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Capa de Fondo (espacio oscuro detrás de los orificios)
              Container(color: const Color(0xFF151C28)),

              // 2. Capa de Fichas (Cae deslizándose detrás de la máscara)
              Row(
                children: List.generate(Board.cols, (colIndex) {
                  return Expanded(
                    child: _ColumnPieceLayer(
                      board: board,
                      colIndex: colIndex,
                    ),
                  );
                }),
              ),

              // 3. Capa Frontal: Máscara Azul perforada
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BoardHolesPainter(
                      rows: Board.rows,
                      cols: Board.cols,
                      boardColor: Colors.blue.shade800,
                    ),
                  ),
                ),
              ),

              // 4. Capa Táctil: Detecta toques en las columnas
              Row(
                children: List.generate(Board.cols, (colIndex) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onColumnSelected(colIndex),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Controla la animación de la ficha deslizándose por la columna
class _ColumnPieceLayer extends StatefulWidget {
  final Board board;
  final int colIndex;

  const _ColumnPieceLayer({
    required this.board,
    required this.colIndex,
  });

  @override
  State<_ColumnPieceLayer> createState() => _ColumnPieceLayerState();
}

class _ColumnPieceLayerState extends State<_ColumnPieceLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  int _lastPieceRow = -1;
  int _lastPlayer = Board.empty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _dropAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );
  }

  @override
  void didUpdateWidget(covariant _ColumnPieceLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar si cayó una ficha nueva en esta columna
    int newPiecesCount = _countPieces(widget.board, widget.colIndex);
    int oldPiecesCount = _countPieces(oldWidget.board, oldWidget.colIndex);

    if (newPiecesCount > oldPiecesCount) {
      int targetRow = _getLowestFilledRow(widget.board, widget.colIndex);
      if (targetRow != -1) {
        _lastPieceRow = targetRow;
        _lastPlayer = widget.board.grid[targetRow][widget.colIndex];

        // Animar desde la parte superior (-1) hasta la fila de destino
        _dropAnimation = Tween<double>(
          begin: -1.0 - targetRow,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
        );
        _controller.forward(from: 0.0);
      }
    } else if (newPiecesCount == 0) {
      _lastPieceRow = -1;
      _controller.reset();
    }
  }

  int _countPieces(Board b, int col) {
    int c = 0;
    for (int r = 0; r < Board.rows; r++) {
      if (b.grid[r][col] != Board.empty) c++;
    }
    return c;
  }

  int _getLowestFilledRow(Board b, int col) {
    for (int r = 0; r < Board.rows; r++) {
      if (b.grid[r][col] != Board.empty) return r;
    }
    return -1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(Board.rows, (rowIndex) {
        int cellValue = widget.board.grid[rowIndex][widget.colIndex];

        // Si es la ficha recién colocada y está animando
        if (rowIndex == _lastPieceRow && _controller.isAnimating) {
          return Expanded(
            child: AnimatedBuilder(
              animation: _dropAnimation,
              builder: (context, child) {
                return FractionalTranslation(
                  translation: Offset(0.0, _dropAnimation.value),
                  child: child,
                );
              },
              child: CellWidget(cellValue: _lastPlayer),
            ),
          );
        }

        return Expanded(
          child: CellWidget(cellValue: cellValue),
        );
      }),
    );
  }
}

// Dibuja el marco azul con los orificios perforados
class _BoardHolesPainter extends CustomPainter {
  final int rows;
  final int cols;
  final Color boardColor;

  _BoardHolesPainter({
    required this.rows,
    required this.cols,
    required this.boardColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boardPaint = Paint()..color = boardColor;
    final double colWidth = size.width / cols;
    final double rowHeight = size.height / rows;
    final double radius = (colWidth < rowHeight ? colWidth : rowHeight) * 0.42;

    Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final Offset center = Offset(
          (c * colWidth) + (colWidth / 2),
          (r * rowHeight) + (rowHeight / 2),
        );
        path.addOval(Rect.fromCircle(center: center, radius: radius));
      }
    }

    // EvenOdd recorta los círculos del rectángulo azul
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, boardPaint);

    // Borde circular oscuro en el orificio para dar volumen
    final Paint rimPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final Offset center = Offset(
          (c * colWidth) + (colWidth / 2),
          (r * rowHeight) + (rowHeight / 2),
        );
        canvas.drawCircle(center, radius, rimPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}