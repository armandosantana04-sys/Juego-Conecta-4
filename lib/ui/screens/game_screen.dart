import 'package:conecta4_game/services/audio_service.dart';
import 'package:flutter/material.dart';
import '../../models/difficulty.dart';
import '../../models/game_status.dart';
import '../../state/game_controller.dart';
import '../widgets/board_widget.dart';
import '../widgets/game_over_dialog.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController _controller;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(difficulty: widget.difficulty);
    _controller.addListener(_handleGameStatusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleGameStatusChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleGameStatusChange() {
    if (!mounted) return;

    // Detectar fin de partida para mostrar modal solo una vez
    if ((_controller.status == GameStatus.humanWon ||
            _controller.status == GameStatus.aiWon ||
            _controller.status == GameStatus.draw) &&
        !_dialogShown) {
      _dialogShown = true;
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GameOverDialog(
            status: _controller.status,
            onRestart: () {
              Navigator.pop(context);
              _dialogShown = false;
              _controller.resetGame();
            },
            onMenu: () {
              Navigator.pop(context);
              Navigator.pop(context); // Vuelve a MenuScreen
            },
          ),
        );
      });
    }
  }

  String _getDifficultyText(Difficulty diff) {
    switch (diff) {
      case Difficulty.easy:
        return "Fácil";
      case Difficulty.medium:
        return "Medio";
      case Difficulty.hard:
        return "Difícil";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.blueGrey.shade900,
          appBar: AppBar(
            backgroundColor: Colors.blueGrey.shade800,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Nivel: ${_getDifficultyText(_controller.difficulty)}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: "Reiniciar partida",
                onPressed: () {
                  _dialogShown = false;
                  _controller.resetGame();
                },
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white),
                onPressed: () {
                  AudioService.toggleMute();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Indicador de Turno y Estado
                  _buildTurnIndicator(),

                  // 2. Tablero de Juego (6x7)
                  BoardWidget(
                    board: _controller.board,
                    onColumnSelected: (colIndex) {
                      _controller.playHumanMove(colIndex);
                    },
                  ),

                  // 3. Leyenda y Mensajes de Advertencia/Error
                  _buildFooterInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurnIndicator() {
    bool isHuman = _controller.status == GameStatus.humanTurn;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: isHuman ? Colors.redAccent : Colors.amber,
          ),
          const SizedBox(width: 12),
          Text(
            isHuman ? "Tu Turno (Rojo)" : "Turno de la IA (Amarillo)...",
            style: TextStyle(
              color: isHuman ? Colors.white : Colors.amberAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isHuman) ...[
            const SizedBox(width: 12),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.amber,
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Column(
      children: [
        if (_controller.errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: Text(
              _controller.errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          )
        else
          const Text(
            "Toca cualquier columna para soltar tu ficha",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}