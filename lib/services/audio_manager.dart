import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'storage_service.dart';

class AudioManager {
  final StorageService storageService;

  late final AudioPlayer _bgmPlayer;
  final List<AudioPlayer> _sfxPlayersPool = [];
  int _currentPoolIndex = 0;
  static const int _poolSize = 8;

  String? _currentBgmTrack;

  AudioManager(this.storageService) {
    _initPlayers();
  }

  void _initPlayers() {
    try {
      _bgmPlayer = AudioPlayer();
      _bgmPlayer.setReleaseMode(ReleaseMode.loop).catchError((_) {});

      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        player.setReleaseMode(ReleaseMode.stop).catchError((_) {});
        _sfxPlayersPool.add(player);
      }
    } catch (_) {}
  }

  AudioPlayer _getNextSfxPlayer() {
    if (_sfxPlayersPool.isEmpty) return AudioPlayer();
    final player = _sfxPlayersPool[_currentPoolIndex];
    _currentPoolIndex = (_currentPoolIndex + 1) % _sfxPlayersPool.length;
    return player;
  }

  // --- Background Music ---
  Future<void> playMenuBgm() async {
    if (!storageService.isMusicEnabled) return;
    if (_currentBgmTrack == 'menu.ogg') return;

    _currentBgmTrack = 'menu.ogg';
    try {
      await _bgmPlayer.stop().catchError((_) {});
      await _bgmPlayer.setVolume(storageService.bgmVolume).catchError((_) {});
      await _bgmPlayer.play(AssetSource('audio/menu.ogg')).catchError((_) {});
    } catch (_) {}
  }

  Future<void> playGameBgm({int mode = 0}) async {
    if (!storageService.isMusicEnabled) return;

    final track = mode == 1
        ? 'gm_arc.ogg'
        : mode == 2
            ? 'gm_trl.ogg'
            : 'gm_que.ogg';

    if (_currentBgmTrack == track) return;
    _currentBgmTrack = track;

    try {
      await _bgmPlayer.stop().catchError((_) {});
      await _bgmPlayer.setVolume(storageService.bgmVolume).catchError((_) {});
      await _bgmPlayer.play(AssetSource('audio/$track')).catchError((_) {});
    } catch (_) {}
  }

  Future<void> stopBgm() async {
    _currentBgmTrack = null;
    try {
      await _bgmPlayer.stop().catchError((_) {});
    } catch (_) {}
  }

  Future<void> updateBgmVolume(double volume) async {
    try {
      await storageService.setBgmVolume(volume);
      if (storageService.isMusicEnabled) {
        await _bgmPlayer.setVolume(volume).catchError((_) {});
      }
    } catch (_) {}
  }

  Future<void> toggleMusic(bool enabled) async {
    try {
      await storageService.setMusicEnabled(enabled);
      if (!enabled) {
        await stopBgm();
      } else {
        await playMenuBgm();
      }
    } catch (_) {}
  }

  // --- Sound Effects ---
  void _playSfx(String assetPath, {double volumeMultiplier = 1.0}) {
    if (!storageService.isSfxEnabled) return;

    try {
      final player = _getNextSfxPlayer();
      final volume = (storageService.sfxVolume * volumeMultiplier).clamp(0.0, 1.0);
      player.setVolume(volume).then((_) {
        player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency).catchError((_) {});
      }).catchError((_) {});
    } catch (_) {}
  }

  void playSlice() {
    final rand = Random();
    // Tested, clean slice sound effects
    final sliceSfx = [
      'audio/sek1.ogg',
      'audio/sek-fruit41.ogg',
      'audio/sek-fruit42.ogg',
      'audio/sek-fruit43.ogg',
    ];
    final chosen = sliceSfx[rand.nextInt(sliceSfx.length)];
    _playSfx(chosen, volumeMultiplier: 1.0);

    if (storageService.isHapticsEnabled) {
      try {
        HapticFeedback.lightImpact().catchError((_) {});
      } catch (_) {}
    }
  }

  void playSplat() {
    final rand = Random();
    final splats = [
      'audio/sek-plechovka1-odraz.ogg',
      'audio/sek-balonek1.ogg',
    ];
    final chosen = splats[rand.nextInt(splats.length)];
    _playSfx(chosen, volumeMultiplier: 0.7);
  }

  void playBombExplosion() {
    _playSfx('audio/vybuch-hlasnejsie2.ogg', volumeMultiplier: 1.0);
    if (storageService.isHapticsEnabled) {
      try {
        HapticFeedback.heavyImpact().catchError((_) {});
      } catch (_) {}
    }
  }

  void playCombo() {
    _playSfx('audio/jingle111-combo.ogg', volumeMultiplier: 1.0);
    if (storageService.isHapticsEnabled) {
      try {
        HapticFeedback.mediumImpact().catchError((_) {});
      } catch (_) {}
    }
  }

  void playLevelWin() {
    _playSfx('audio/level-win1.ogg', volumeMultiplier: 1.0);
    if (storageService.isHapticsEnabled) {
      try {
        HapticFeedback.heavyImpact().catchError((_) {});
      } catch (_) {}
    }
  }

  void playFreeze() {
    _playSfx('audio/impact-ice-1.ogg', volumeMultiplier: 0.8);
  }

  void playFrenzy() {
    _playSfx('audio/jingle211-bonus_freedom.ogg', volumeMultiplier: 0.95);
  }

  void playDoublePoints() {
    _playSfx('audio/jingle211-bonus_freedom.ogg', volumeMultiplier: 0.9);
  }

  void playExtraLife() {
    _playSfx('audio/jingle111-combo.ogg', volumeMultiplier: 0.9);
  }

  void playButtonClick() {
    _playSfx('audio/button_click.ogg', volumeMultiplier: 0.8);
  }

  void playTick() {
    _playSfx('audio/sek1.ogg', volumeMultiplier: 0.5);
  }

  void playSwoosh() {
    _playSfx('audio/swish-1.ogg', volumeMultiplier: 0.6);
  }

  void dispose() {
    try {
      _bgmPlayer.dispose().catchError((_) {});
      for (final player in _sfxPlayersPool) {
        player.dispose().catchError((_) {});
      }
    } catch (_) {}
  }
}
