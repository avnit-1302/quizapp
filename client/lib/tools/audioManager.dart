import 'dart:math';

import 'package:audioplayers/audioplayers.dart';

/// Manages audio playback
class AudioManager {
  final AudioPlayer _backgroundAudio = AudioPlayer();
  final AudioPlayer _soundEffect = AudioPlayer();

  /// Plays background audio
  Future<void> playBackgroundAudio(List<String> audioFiles) async {
    _backgroundAudio.setReleaseMode(ReleaseMode.loop);
    String selectedAudio = audioFiles[Random().nextInt(audioFiles.length)];
    await _backgroundAudio.play(AssetSource(selectedAudio));
  }

  /// Plays sound effects
  Future<void> playSoundEffect(String file) async {
    await _soundEffect.play(AssetSource(file));
  }

  /// Stops all audio playback
  Future<void> stopAudio() async {
    await _backgroundAudio.stop();
    await _soundEffect.stop();
  }

  /// Disposes audio resources
  Future<void> dispose() async {
    await _backgroundAudio.dispose();
    await _soundEffect.dispose();
  }
}
