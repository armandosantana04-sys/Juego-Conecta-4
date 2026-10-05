import 'package:flutter/material.dart';
import '../../models/board.dart';

class CellWidget extends StatelessWidget {
  final int cellValue;

  const CellWidget({super.key, required this.cellValue});

  @override
  Widget build(BuildContext context) {
    if (cellValue == Board.empty) {
      return const SizedBox.expand();
    }

    Color pieceColor = (cellValue == Board.human) ? Colors.redAccent : Colors.amber;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.35),
              radius: 0.8,
              colors: [
                pieceColor.withOpacity(0.9),
                pieceColor,
                Colors.black.withOpacity(0.35),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
