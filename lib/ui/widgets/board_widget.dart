import 'package:flutter/material.dart';
import '../../models/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatefulWidget {
  final Board board;
  final Function(int) onColumnSelected;
  final List<List<int>>? winningCoords;

  const BoardWidget({
    super.key,
    required this.board,
    required this.onColumnSelected,
    this.winningCoords,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _dropAnimation;

  // Datos de la ficha que está cayendo actualmente
  int _fallingCol = -1;
  int _fallingRow = -1;
  int _fallingPiece = Board.empty;

  // Matriz interna de fichas que ya terminaron de caer
  late List<List<int>> _settledGrid;

  @override
  void initState() {
    super.initState();
    _settledGrid = List.generate(
      Board.rows,
      (r) => List.generate(Board.cols, (c) => widget.board.grid[r][c]),
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _dropAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.bounceOut,
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_fallingRow != -1 && _fallingCol != -1) {
          setState(() {
            _settledGrid[_fallingRow][_fallingCol] = _fallingPiece;
            _fallingRow = -1;
            _fallingCol = -1;
            _fallingPiece = Board.empty;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant BoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar si el juego se reinició
    if (widget.board.isFull() == false && _isGridEmpty(widget.board)) {
      _settledGrid = List.generate(
        Board.rows,
        (r) => List.filled(Board.cols, Board.empty),
      );
      _fallingRow = -1;
      _fallingCol = -1;
      return;
    }

    // Buscar cuál fue la nueva ficha añadida
    for (int r = 0; r < Board.rows; r++) {
      for (int c = 0; c < Board.cols; c++) {
        if (widget.board.grid[r][c] != Board.empty &&
            _settledGrid[r][c] == Board.empty &&
            !(r == _fallingRow && c == _fallingCol)) {
          // Nueva ficha detectada: iniciar animación de caída vertical
          _fallingRow = r;
          _fallingCol = c;
          _fallingPiece = widget.board.grid[r][c];

          _animController.forward(from: 0.0);
          return;
        }
      }
    }
  }

  bool _isGridEmpty(Board b) {
    for (int r = 0; r < Board.rows; r++) {
      for (int c = 0; c < Board.cols; c++) {
        if (b.grid[r][c] != Board.empty) return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cellWidth = constraints.maxWidth / Board.cols;
          final double cellHeight = constraints.maxHeight / Board.rows;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 1. Fondo oscuro detrás del tablero
                  Container(color: const Color(0xFF101622)),

                  // 2. Fichas fijas ya asentadas
                  Column(
                    children: List.generate(Board.rows, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(Board.cols, (c) {
                            return Expanded(
                              child: CellWidget(cellValue: _settledGrid[r][c]),
                            );
                          }),
                        ),
                      );
                    }),
                  ),

                  // 3. Ficha activa animándose desde arriba
                  if (_fallingRow != -1 && _fallingCol != -1)
                    AnimatedBuilder(
                      animation: _dropAnimation,
                      builder: (context, child) {
                        // Comienza arriba del tablero (-cellHeight) y cae hasta su fila destino
                        final double startY = -cellHeight;
                        final double targetY = _fallingRow * cellHeight;
                        final double currentY =
                            startY + (targetY - startY) * _dropAnimation.value;

                        return Positioned(
                          left: _fallingCol * cellWidth,
                          top: currentY,
                          width: cellWidth,
                          height: cellHeight,
                          child: child!,
                        );
                      },
                      child: CellWidget(cellValue: _fallingPiece),
                    ),

                  // 4. Máscara frontal azul perforada (los huecos dejan ver la caída por detrás)
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

                  // 5. Línea de victoria cuando se conectan 4
                  if (widget.winningCoords != null &&
                      widget.winningCoords!.length == 4)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _WinningLinePainter(
                            winningCoords: widget.winningCoords!,
                            rows: Board.rows,
                            cols: Board.cols,
                          ),
                        ),
                      ),
                    ),

                  // 6. Detección de toques por columnas
                  Row(
                    children: List.generate(Board.cols, (colIndex) {
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // Si hay una ficha cayendo, evitar toques simultáneos
                            if (_animController.isAnimating) return;
                            widget.onColumnSelected(colIndex);
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

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

    Path path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final Offset center = Offset(
          (c * colWidth) + (colWidth / 2),
          (r * rowHeight) + (rowHeight / 2),
        );
        path.addOval(Rect.fromCircle(center: center, radius: radius));
      }
    }

    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, boardPaint);

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

class _WinningLinePainter extends CustomPainter {
  final List<List<int>> winningCoords;
  final int rows;
  final int cols;

  _WinningLinePainter({
    required this.winningCoords,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double colWidth = size.width / cols;
    final double rowHeight = size.height / rows;

    final startCoord = winningCoords.first;
    final endCoord = winningCoords.last;

    final Offset p1 = Offset(
      (startCoord[1] * colWidth) + (colWidth / 2),
      (startCoord[0] * rowHeight) + (rowHeight / 2),
    );

    final Offset p2 = Offset(
      (endCoord[1] * colWidth) + (colWidth / 2),
      (endCoord[0] * rowHeight) + (rowHeight / 2),
    );

    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.7)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, p2, glowPaint);
    canvas.drawLine(p1, p2, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WinningLinePainter oldDelegate) {
    return oldDelegate.winningCoords != winningCoords;
  }
}