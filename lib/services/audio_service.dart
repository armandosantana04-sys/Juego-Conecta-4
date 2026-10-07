import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();

  static bool isMuted = false;

  static Future<void> initAudioContext() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
    } catch (_) {}
  }

  /// Inicia o fuerza el reinicio de la música de fondo
  static Future<void> playBgm({bool forceRestart = false}) async {
    if (isMuted) return;
    try {
      if (!forceRestart && _bgmPlayer.state == PlayerState.playing) {
        return;
      }

      // Detenemos cualquier estado corrupto y relanzamos limpio
      await _bgmPlayer.stop();
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(
        AssetSource('audio/bgm_retro.mp3'),
        volume: 0.25,
      );
    } catch (_) {}
  }

  static Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (_) {}
  }

  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (_) {}
  }

  static Future<void> _playSfx(String path, {double volume = 0.7}) async {
    if (isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setSource(AssetSource(path));
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.resume();
    } catch (_) {}
  }

  static Future<void> playDropSound() async {
    await _playSfx('audio/drop.mp3', volume: 0.5);
  }

  static Future<void> playWinSound() async {
    await _playSfx('audio/win.mp3', volume: 0.8);
  }

  static Future<void> playLoseSound() async {
    await _playSfx('audio/game_over.mp3', volume: 0.8);
  }

  static void toggleMute() {
    isMuted = !isMuted;
    if (isMuted) {
      _bgmPlayer.pause();
      _sfxPlayer.stop();
    } else {
      playBgm(forceRestart: true);
    }
  }
}