import 'package:flutter/foundation.dart';
import '../models/board.dart';
import '../models/difficulty.dart';
import '../models/game_status.dart';
import '../ai/connect4_agent.dart';
import '../services/audio_service.dart';

class GameController extends ChangeNotifier {
  late Board board;
  late Connect4Agent agent;
  late Difficulty difficulty;
  late GameStatus status;
  String? errorMessage;

  GameController({required this.difficulty}) {
    resetGame();
  }

  void resetGame() {
    board = Board();
    agent = Connect4Agent(difficulty: difficulty);
    status = GameStatus.humanTurn;
    errorMessage = null;
    notifyListeners();
  }

  void changeDifficulty(Difficulty newDifficulty) {
    difficulty = newDifficulty;
    resetGame();
  }

  // Ejecuta la jugada seleccionada por el humano
  Future<void> playHumanMove(int col) async {
    // Si no es turno del humano o la partida concluyó, ignorar
    if (status != GameStatus.humanTurn) return;

    if (!board.isValidMove(col)) {
      errorMessage = "¡Columna llena! Selecciona otra.";
      notifyListeners();
      return;
    }

    errorMessage = null;
    board.dropPiece(col, Board.human);
    AudioService.playDropSound();

    // Comprobar si el humano gana
    if (board.checkWin(Board.human)) {
      status = GameStatus.humanWon;
      AudioService.playWinSound();
      notifyListeners();
      return;
    }

    if (board.isFull()) {
      status = GameStatus.draw;
      notifyListeners();
      return;
    }

    // Pasar turno a la IA
    status = GameStatus.aiTurn;
    notifyListeners();

    // Pequeño retraso visual simulando el cálculo del agente
    await Future.delayed(const Duration(milliseconds: 400));
    _playAiMove();
  }

  // Ejecuta la jugada decidida por el agente inteligente
  void _playAiMove() {
    if (status != GameStatus.aiTurn) return;

    int aiCol = agent.decideMove(board);
    board.dropPiece(aiCol, Board.ai);
    AudioService.playDropSound();

    // Comprobar si la IA gana
    if (board.checkWin(Board.ai)) {
      status = GameStatus.aiWon;
      AudioService.playLoseSound();
      notifyListeners();
      return;
    }

    if (board.isFull()) {
      status = GameStatus.draw;
      notifyListeners();
      return;
    }

    status = GameStatus.humanTurn;
    notifyListeners();
  }
}