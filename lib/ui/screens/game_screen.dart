import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../game/game_controller.dart';
import '../../game/game_painter.dart';
import '../../models/level_data.dart';
import '../../services/audio_manager.dart';
import '../../services/level_generator.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/pause_dialog.dart';
import '../widgets/victory_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final LevelData? levelData;
  final StorageService storageService;
  final AudioManager audioManager;

  const GameScreen({
    super.key,
    required this.mode,
    this.levelData,
    required this.storageService,
    required this.audioManager,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Ready countdown
  int _readyCountdown = 3;
  bool _isStarting = true;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      mode: widget.mode,
      levelData: widget.levelData,
      storageService: widget.storageService,
      audioManager: widget.audioManager,
    );

    _ticker = createTicker(_onTick);
    _ticker.start();

    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _runCountdownStep(3);
    });
  }

  void _runCountdownStep(int step) {
    if (!mounted) return;
    setState(() => _readyCountdown = step);
    widget.audioManager.playTick();

    if (step > 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        _runCountdownStep(step - 1);
      });
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _readyCountdown = 0;
          _isStarting = false;
        });
        _controller.startGame(); // Start launching fruits & timer right as "GO!" appears
      });
    }
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    final safeDt = min(0.05, dt);
    _controller.update(safeDt);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _restartGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          mode: widget.mode,
          levelData: widget.levelData,
          storageService: widget.storageService,
          audioManager: widget.audioManager,
        ),
      ),
    );
  }

  void _goToNextLevel() {
    if (widget.levelData != null) {
      final nextLevelNum = widget.levelData!.levelNumber + 1;
      final nextLevelData = LevelGenerator.generate(nextLevelNum);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(
            mode: GameMode.level,
            levelData: nextLevelData,
            storageService: widget.storageService,
            audioManager: widget.audioManager,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _controller.setScreenSize(size);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _controller.pauseGame();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0510),
        body: Stack(
          children: [
            // Dojo Background Fallback Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _controller.dojoTheme.backgroundGradient,
                  ),
                ),
              ),
            ),

            // Interactive 60 FPS Game Canvas with Dual Gesture & Pointer Listener
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  _controller.onPanStart(details.localPosition);
                  if (mounted) setState(() {});
                },
                onPanUpdate: (details) {
                  _controller.onPanUpdate(details.localPosition);
                  if (mounted) setState(() {});
                },
                onPanEnd: (_) {
                  _controller.onPanEnd();
                  if (mounted) setState(() {});
                },
                onTapDown: (details) {
                  _controller.onPanStart(details.localPosition);
                  if (mounted) setState(() {});
                },
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) {
                    _controller.onPanStart(e.localPosition);
                    if (mounted) setState(() {});
                  },
                  onPointerMove: (e) {
                    _controller.onPanUpdate(e.localPosition);
                    if (mounted) setState(() {});
                  },
                  onPointerUp: (_) {
                    _controller.onPanEnd();
                    if (mounted) setState(() {});
                  },
                  onPointerCancel: (_) {
                    _controller.onPanEnd();
                    if (mounted) setState(() {});
                  },
                  child: SizedBox.expand(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: GamePainter(
                          dojoTheme: _controller.dojoTheme,
                          bladeSkin: _controller.bladeSkin,
                          splatters: _controller.splatters,
                          fruits: _controller.fruits,
                          bladePoints: _controller.bladeTrail.points,
                          particles: _controller.particles,
                          floatingTexts: _controller.floatingTexts,
                          isFreezeActive: _controller.freezeTimer > 0,
                          isFrenzyActive: _controller.frenzyTimer > 0,
                          screenShakeOffset: _controller.screenShakeOffset,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top HUD Bar (Passes touch through everywhere except Pause Button)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Score Box
                      IgnorePointer(child: _buildScoreBox()),

                      // Target / Mode Objectives
                      if (widget.mode == GameMode.level && widget.levelData != null)
                        IgnorePointer(child: _buildLevelProgressBar()),

                      if (widget.mode == GameMode.arcade)
                        IgnorePointer(child: _buildArcadeTimerBox()),

                      if (widget.mode == GameMode.zen)
                        IgnorePointer(child: _buildZenLivesBox()),

                      // Pause Button (Interactive)
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(Icons.pause_rounded, color: Colors.white, size: 24),
                        ),
                        onPressed: () {
                          widget.audioManager.playButtonClick();
                          _controller.pauseGame();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Active Power-Up Badges
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_controller.freezeTimer > 0)
                      _buildPowerUpBadge(
                        '❄️ FREEZE (${_controller.freezeTimer.toStringAsFixed(1)}s)',
                        const Color(0xFF00E5FF),
                      ),
                    if (_controller.frenzyTimer > 0)
                      _buildPowerUpBadge(
                        '⚡ FRENZY (${_controller.frenzyTimer.toStringAsFixed(1)}s)',
                        const Color(0xFFFFD600),
                      ),
                    if (_controller.doubleScoreTimer > 0)
                      _buildPowerUpBadge(
                        '💎 2X SCORE (${_controller.doubleScoreTimer.toStringAsFixed(1)}s)',
                        const Color(0xFFFF007F),
                      ),
                  ],
                ),
              ),
            ),

            // Ready Countdown Overlay (Non-blocking touch)
            if (_isStarting && _readyCountdown > 0)
              IgnorePointer(
                child: Center(
                  child: Text(
                    '$_readyCountdown',
                    style: AppTheme.titleStyle(
                      fontSize: 110,
                      color: const Color(0xFFFFD700),
                    ),
                  )
                      .animate(key: ValueKey(_readyCountdown))
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.2, 1.2),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeOut(delay: 400.ms, duration: 250.ms),
                ),
              ),

            // Pause Modal
            if (_controller.state == GameState.paused)
              PauseDialog(
                onResume: () {
                  widget.audioManager.playButtonClick();
                  _controller.resumeGame();
                },
                onRestart: () {
                  widget.audioManager.playButtonClick();
                  _restartGame();
                },
                onMainMenu: () {
                  widget.audioManager.playButtonClick();
                  Navigator.pop(context);
                },
              ),

            // Victory Modal
            if (_controller.state == GameState.levelComplete)
              VictoryDialog(
                controller: _controller,
                onNextLevel: _goToNextLevel,
                onReplay: _restartGame,
                onLevelMap: () => Navigator.pop(context),
              ),

            // Game Over Modal
            if (_controller.state == GameState.gameOver)
              GameOverDialog(
                controller: _controller,
                onRetry: _restartGame,
                onMainMenu: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: AppTheme.glassDecoration(
        opacity: 0.4,
        borderRadius: 18,
        borderColor: const Color(0xFFFFD700).withValues(alpha: 0.6),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 22),
          const SizedBox(width: 6),
          Text(
            '${_controller.score}',
            style: AppTheme.titleStyle(fontSize: 22, color: Colors.white),
          ),
          if (_controller.doubleScoreTimer > 0)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF007F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('2X', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar() {
    final level = widget.levelData!;
    final progress = min(1.0, _controller.score / level.objective.targetScore);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppTheme.glassDecoration(
        opacity: 0.35,
        borderRadius: 16,
        borderColor: Colors.white24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'LVL ${level.levelNumber} • ⏱️ ${_controller.timeRemaining.toInt()}s',
            style: AppTheme.titleStyle(fontSize: 14, color: const Color(0xFFFFD700)),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? const Color(0xFF10B981) : const Color(0xFFFF6D00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcadeTimerBox() {
    final secs = _controller.timeRemaining.toInt();
    final isLowTime = secs <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: AppTheme.glassDecoration(
        opacity: 0.35,
        borderRadius: 16,
        borderColor: isLowTime ? const Color(0xFFFF1744) : const Color(0xFF00E5FF),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_rounded,
            color: isLowTime ? const Color(0xFFFF1744) : const Color(0xFF00E5FF),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '${secs}s',
            style: AppTheme.titleStyle(
              fontSize: 18,
              color: isLowTime ? const Color(0xFFFF1744) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZenLivesBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppTheme.glassDecoration(
        opacity: 0.35,
        borderRadius: 16,
        borderColor: Colors.white24,
      ),
      child: Row(
        children: List.generate(
          _controller.maxLives,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Icon(
              index < _controller.lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: const Color(0xFFFF1744),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
