import 'package:flutter/material.dart';
import 'package:conecta4_game/models/difficulty.dart';
import 'package:conecta4_game/models/game_status.dart';
import '../models/board.dart';
import '../ai/connect4_agent.dart';
import '../services/audio_service.dart';

class GameController extends ChangeNotifier {
  late Board board;
  final Difficulty difficulty;
  late Connect4Agent agent;

  // Estado del juego usando tus nombres de enum exactos
  GameStatus status = GameStatus.humanTurn;
  String? errorMessage;

  // Variables de conveniencia
  bool get isGameOver =>
      status == GameStatus.humanWon ||
      status == GameStatus.aiWon ||
      status == GameStatus.draw;
  bool get isThinking => status == GameStatus.aiTurn;
  bool get isHumanTurn => status == GameStatus.humanTurn;

  // Coordenadas [[r, c], ...] de las 4 fichas ganadoras
  List<List<int>>? winningCoords;

  GameController({required this.difficulty}) {
    resetGame();
  }

  void resetGame() {
    board = Board();
    agent = Connect4Agent(difficulty: difficulty);
    status = GameStatus.humanTurn;
    errorMessage = null;
    winningCoords = null;

    // Asegurar que la música de fondo vuelva a sonar en la revancha
    AudioService.playBgm();

    notifyListeners();
  }

  /// Método principal de tirada del jugador humano
  Future<void> playHumanMove(int col) async {
    // Si no es el turno del humano o la columna está llena, ignorar
    if (status != GameStatus.humanTurn || !board.isValidMove(col)) {
      return;
    }

    errorMessage = null;

    // 1. Jugada del humano y sonido de ficha
    board.dropPiece(col, Board.human);
    AudioService.playDropSound();
    notifyListeners();

    // 2. Verificar condición de victoria del humano
    if (board.checkWin(Board.human)) {
      winningCoords = board.getWinningLine(Board.human);
      AudioService.playWinSound();
      notifyListeners();

      // Pausa de 3 segundos para contemplar la línea ganadora
      await Future.delayed(const Duration(seconds: 3));

      status = GameStatus.humanWon;
      notifyListeners();
      return;
    }

    // 3. Verificar si el tablero está lleno (empate)
    if (board.isFull()) {
      status = GameStatus.draw;
      notifyListeners();
      return;
    }

    // 4. Cambiar turno a la IA
    status = GameStatus.aiTurn;
    notifyListeners();

    // Pausa para que la ficha humana termine de caer con la animación lenta
    await Future.delayed(const Duration(milliseconds: 900));

    // 5. La IA calcula y ejecuta su tiro
    int aiMove = agent.decideMove(board);
    if (aiMove != -1 && board.isValidMove(aiMove)) {
      board.dropPiece(aiMove, Board.ai);
      AudioService.playDropSound();
      notifyListeners();

      // 6. Verificar condición de victoria de la IA
      if (board.checkWin(Board.ai)) {
        winningCoords = board.getWinningLine(Board.ai);
        AudioService.playLoseSound();
        notifyListeners();

        // Pausa de 3 segundos para observar cómo ganó la IA
        await Future.delayed(const Duration(seconds: 3));

        status = GameStatus.aiWon;
        notifyListeners();
        return;
      }

      // 7. Verificar empate tras el tiro de la IA
      if (board.isFull()) {
        status = GameStatus.draw;
        notifyListeners();
        return;
      }
    }

    // Pausa para que la ficha de la IA termine de caer antes de devolver el control
    await Future.delayed(const Duration(milliseconds: 900));

    // 8. Regresar el control al humano
    status = GameStatus.humanTurn;
    notifyListeners();
  }

  /// Alias de compatibilidad
  Future<void> handleUserTurn(int col) => playHumanMove(col);
}