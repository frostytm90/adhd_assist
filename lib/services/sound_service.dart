import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;

  Future<void> initialize() async {
    // Load and cache sounds
    await _audioPlayer.setSource(AssetSource('sounds/task_complete.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/achievement_unlocked.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/streak_milestone.mp3'));
    await _audioPlayer.setSource(AssetSource('sounds/level_up.mp3'));
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
  }

  Future<void> playTaskComplete() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/task_complete.mp3'));
    HapticFeedback.mediumImpact();
  }

  Future<void> playAchievementUnlocked() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/achievement_unlocked.mp3'));
    HapticFeedback.heavyImpact();
  }

  Future<void> playStreakMilestone() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/streak_milestone.mp3'));
    HapticFeedback.heavyImpact();
  }

  Future<void> playLevelUp() async {
    if (!_isSoundEnabled) return;
    await _audioPlayer.play(AssetSource('sounds/level_up.mp3'));
    HapticFeedback.heavyImpact();
  }
}
