import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static bool isMuted = false;

  static Future<void> playBgm() async {
    if (isMuted) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource('audio/bgm_retro.mp3'), volume: 0.3);
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  static Future<void> playDropSound() async {
    if (isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/drop.mp3'), volume: 0.6);
    } catch (_) {}
  }

  static Future<void> playWinSound() async {
    if (isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/win.mp3'), volume: 0.8);
    } catch (_) {}
  }

  static Future<void> playLoseSound() async {
    if (isMuted) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/game_over.mp3'), volume: 0.8);
    } catch (_) {}
  }

  static void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }
}