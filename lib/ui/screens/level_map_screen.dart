import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/game_controller.dart';
import '../../models/level_data.dart';
import '../../services/audio_manager.dart';
import '../../services/level_generator.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/star_rating_widget.dart';
import 'game_screen.dart';

class LevelMapScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioManager audioManager;

  const LevelMapScreen({
    super.key,
    required this.storageService,
    required this.audioManager,
  });

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  late int _unlockedLevel;

  @override
  void initState() {
    super.initState();
    _unlockedLevel = widget.storageService.unlockedLevel;
  }

  @override
  Widget build(BuildContext context) {
    // Show up to unlockedLevel + 20 levels in the infinite list
    final totalDisplayLevels = max(30, _unlockedLevel + 20);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            widget.audioManager.playButtonClick();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'ADVENTURE STAGES',
          style: AppTheme.titleStyle(fontSize: 24, color: const Color(0xFFFFD700)),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: AppTheme.glassDecoration(
              opacity: 0.25,
              borderRadius: 16,
              borderColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '${widget.storageService.totalStarsEarned}',
                  style: AppTheme.titleStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E0A1E), Color(0xFF0D020D)],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: totalDisplayLevels,
          itemBuilder: (context, index) {
            final levelNumber = index + 1;
            final level = LevelGenerator.generate(levelNumber);
            final isUnlocked = levelNumber <= _unlockedLevel;
            final stars = widget.storageService.getStarsForLevel(levelNumber);

            return _buildLevelCard(level, isUnlocked, stars);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(LevelData level, bool isUnlocked, int stars) {
    Color difficultyColor;
    switch (level.difficulty) {
      case LevelDifficulty.easy:
        difficultyColor = const Color(0xFF10B981);
        break;
      case LevelDifficulty.medium:
        difficultyColor = const Color(0xFF00E5FF);
        break;
      case LevelDifficulty.hard:
        difficultyColor = const Color(0xFFFF6D00);
        break;
      case LevelDifficulty.extraHard:
        difficultyColor = const Color(0xFFFF1744);
        break;
      case LevelDifficulty.nightmare:
        difficultyColor = const Color(0xFFA855F7);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isUnlocked ? () => _showLevelDetailsDialog(level, stars) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFF281838).withValues(alpha: 0.75)
                  : Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isUnlocked
                    ? difficultyColor.withValues(alpha: 0.6)
                    : Colors.white10,
                width: isUnlocked ? 1.5 : 1.0,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: difficultyColor.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Level Number Circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isUnlocked ? difficultyColor : const Color(0xFF374151),
                    shape: BoxShape.circle,
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: difficultyColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isUnlocked
                        ? Text(
                            '${level.levelNumber}',
                            style: AppTheme.titleStyle(fontSize: 22, color: Colors.white),
                          )
                        : const Icon(Icons.lock_rounded, color: Colors.white54, size: 22),
                  ),
                ),

                const SizedBox(width: 16),

                // Title & Difficulty
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              level.title,
                              style: AppTheme.titleStyle(
                                fontSize: 18,
                                color: isUnlocked ? Colors.white : Colors.white38,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: difficultyColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: difficultyColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              level.difficultyLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: difficultyColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${level.objective.targetScore} pts • ${level.objective.targetSlices} Slices',
                        style: AppTheme.bodyStyle(
                          fontSize: 13,
                          color: isUnlocked ? Colors.white70 : Colors.white24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Stars
                if (isUnlocked)
                  StarRatingWidget(
                    stars: stars,
                    starSize: 22,
                    animate: false,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLevelDetailsDialog(LevelData level, int currentStars) {
    widget.audioManager.playButtonClick();

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glassDecoration(
              opacity: 0.94,
              color: const Color(0xFF1F1230),
              borderRadius: 28,
              borderColor: const Color(0xFFFFD700).withValues(alpha: 0.4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEVEL ${level.levelNumber}',
                  style: AppTheme.titleStyle(
                    fontSize: 28,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                Text(
                  level.title,
                  style: AppTheme.bodyStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 14),

                StarRatingWidget(stars: currentStars, starSize: 34),

                const SizedBox(height: 18),

                // Objectives Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _buildObjectiveRow('🎯 Target Score', '${level.objective.targetScore} pts'),
                      const SizedBox(height: 8),
                      _buildObjectiveRow('🍉 Target Slices', '${level.objective.targetSlices} fruits'),
                      const SizedBox(height: 8),
                      _buildObjectiveRow('⏱️ Time Limit', '${level.objective.timeLimitSeconds} seconds'),
                      const SizedBox(height: 8),
                      _buildObjectiveRow('💣 Bomb Risk', '${(level.bombProbability * 100).toInt()}%'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Play Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameScreen(
                            mode: GameMode.level,
                            levelData: level,
                            storageService: widget.storageService,
                            audioManager: widget.audioManager,
                          ),
                        ),
                      ).then((_) {
                        widget.audioManager.playMenuBgm();
                        setState(() {
                          _unlockedLevel = widget.storageService.unlockedLevel;
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF6D00).withValues(alpha: 0.6),
                    ),
                    child: Text(
                      'START LEVEL',
                      style: AppTheme.titleStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildObjectiveRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyStyle(fontSize: 14, color: Colors.white70)),
        Text(value, style: AppTheme.titleStyle(fontSize: 15, color: Colors.white)),
      ],
    );
  }
}
