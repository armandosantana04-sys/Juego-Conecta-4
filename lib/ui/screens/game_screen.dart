import 'package:flutter/material.dart';
import '../../models/difficulty.dart';
import '../../models/game_status.dart';
import '../../state/game_controller.dart';
import '../widgets/board_widget.dart';
import '../../services/audio_service.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(difficulty: widget.difficulty);
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    setState(() {});

    // Mostrar diálogo cuando la partida termine oficialmente tras la pausa
    if (_controller.isGameOver && mounted) {
      _showGameOverDialog();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _showGameOverDialog() {
    String title;
    String message;
    Color titleColor;

    if (_controller.status == GameStatus.humanWon) {
      title = '¡Victoria!';
      message = '¡Has conectado 4 en línea y vencido a la IA!';
      titleColor = Colors.greenAccent;
    } else if (_controller.status == GameStatus.aiWon) {
      title = 'Derrota';
      message = 'La Inteligencia Artificial ha conectado 4 en línea.';
      titleColor = Colors.redAccent;
    } else {
      title = 'Empate';
      message = 'El tablero se ha llenado sin ganador.';
      titleColor = Colors.amberAccent;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2640),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Volver al menú
              AudioService.playBgm(forceRestart: true);
            },
            child: const Text('Menú', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Navigator.pop(ctx);
              _controller.resetGame();
              AudioService.playBgm(forceRestart: true);
            },
            child: const Text('Revancha', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_controller.status) {
      case GameStatus.humanWon:
        return '¡Has ganado!';
      case GameStatus.aiWon:
        return 'La IA ha ganado';
      case GameStatus.draw:
        return '¡Empate!';
      case GameStatus.aiTurn:
        return 'IA pensando...';
      case GameStatus.humanTurn:
        return 'Tu turno';
    }
  }

  Color _getStatusColor() {
    switch (_controller.status) {
      case GameStatus.humanWon:
        return Colors.greenAccent;
      case GameStatus.aiWon:
        return Colors.redAccent;
      case GameStatus.draw:
        return Colors.amberAccent;
      case GameStatus.humanTurn:
        return Colors.redAccent;
      case GameStatus.aiTurn:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1423),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dificultad: ${widget.difficulty.name.toUpperCase()}',
          style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              AudioService.isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                AudioService.toggleMute();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => _controller.resetGame(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Indicador de turno / estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2640),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor().withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Tablero con la animación de caída y la línea de 4 conectadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BoardWidget(
                board: _controller.board,
                winningCoords: _controller.winningCoords,
                onColumnSelected: (col) => _controller.handleUserTurn(col),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}