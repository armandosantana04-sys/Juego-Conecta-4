import 'package:flutter/material.dart';
import '../../models/game_status.dart';

class GameOverDialog extends StatelessWidget {
  final GameStatus status;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverDialog({
    super.key,
    required this.status,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    Color titleColor;
    IconData icon;

    if (status == GameStatus.humanWon) {
      title = "¡GANASTE!";
      titleColor = Colors.green;
      icon = Icons.emoji_events;
    } else if (status == GameStatus.aiWon) {
      title = "PERDISTE";
      titleColor = Colors.red;
      icon = Icons.sentiment_very_dissatisfied;
    } else {
      title = "EMPATE";
      titleColor = Colors.orange;
      icon = Icons.handshake;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: titleColor, size: 32),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
      content: const Text(
        "¿Qué deseas hacer ahora?",
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        OutlinedButton(
          onPressed: onMenu,
          child: const Text("Menú"),
        ),
        ElevatedButton(
          onPressed: onRestart,
          child: const Text("Reiniciar"),
        ),
      ],
    );
  }
}