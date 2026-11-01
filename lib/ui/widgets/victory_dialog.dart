import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../game/game_controller.dart';
import '../../models/level_data.dart';
import '../theme/app_theme.dart';
import 'star_rating_widget.dart';

class VictoryDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onLevelMap;

  const VictoryDialog({
    super.key,
    required this.controller,
    required this.onNextLevel,
    required this.onReplay,
    required this.onLevelMap,
  });

  @override
  Widget build(BuildContext context) {
    final LevelData? level = controller.levelData;
    final int stars = level?.calculateStars(
          finalScore: controller.score,
          accuracy: controller.accuracy,
          bombTriggered: controller.bombTriggeredInLevel,
        ) ??
        3;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(
          opacity: 0.90,
          color: const Color(0xFF1E1035),
          borderRadius: 28,
          borderColor: const Color(0xFFFFD700).withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Title
            Text(
              '🎉 VICTORY! 🎉',
              style: AppTheme.titleStyle(
                fontSize: 32,
                color: const Color(0xFFFFD700),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 8),

            Text(
              level != null ? 'Level ${level.levelNumber} Cleared!' : 'Stage Complete!',
              style: AppTheme.bodyStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 18),

            // Stars
            StarRatingWidget(stars: stars, starSize: 46),

            const SizedBox(height: 22),

            // Stats Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Final Score', '${controller.score}', Colors.amber),
                  const Divider(color: Colors.white10, height: 16),
                  _buildStatRow('Fruits Sliced', '${controller.slicesCount}', Colors.lightGreenAccent),
                  const Divider(color: Colors.white10, height: 16),
                  _buildStatRow(
                    'Accuracy',
                    '${(controller.accuracy * 100).toInt()}%',
                    controller.accuracy >= 0.8 ? Colors.cyanAccent : Colors.orangeAccent,
                  ),
                  const Divider(color: Colors.white10, height: 16),
                  _buildStatRow(
                    'Coins Earned',
                    '+${level?.coinReward ?? 50} 🪙',
                    const Color(0xFFFFD700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Replay
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReplay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.replay_rounded, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),

                // Next Level
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onNextLevel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6D00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF6D00).withValues(alpha: 0.6),
                    ),
                    child: Text(
                      'NEXT LEVEL',
                      style: AppTheme.titleStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Level Map
                Expanded(
                  child: ElevatedButton(
                    onPressed: onLevelMap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.map_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyStyle(fontSize: 15, color: Colors.white70),
        ),
        Text(
          value,
          style: AppTheme.titleStyle(fontSize: 18, color: valueColor),
        ),
      ],
    );
  }
}
