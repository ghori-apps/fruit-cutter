import '../../ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../game/game_controller.dart';
import '../theme/app_theme.dart';

class GameOverDialog extends StatelessWidget {
  final GameController controller;
  final VoidCallback onRetry;
  final VoidCallback onMainMenu;

  const GameOverDialog({
    super.key,
    required this.controller,
    required this.onRetry,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isArcade = controller.mode == GameMode.arcade;
    final isZen = controller.mode == GameMode.zen;
    final highScore = isArcade
        ? controller.storageService.arcadeHighScore
        : isZen
            ? controller.storageService.zenHighScore
            : 0;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(
          opacity: 0.92,
          color: const Color(0xFF280B12),
          borderRadius: 28,
          borderColor: const Color(0xFFFF1744).withValues(alpha: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              '💀 GAME OVER 💀',
              style: AppTheme.titleStyle(
                fontSize: 30,
                color: const Color(0xFFFF1744),
              ),
            )
                .animate()
                .shake(duration: 400.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                ),

            const SizedBox(height: 8),

            Text(
              controller.mode == GameMode.level
                  ? 'Failed to complete level objectives!'
                  : 'Great effort, Ninja!',
              style: AppTheme.bodyStyle(fontSize: 15, color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // Stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Score', '${controller.score}', Colors.amber),
                  if (isArcade || isZen) ...[
                    const Divider(color: Colors.white10, height: 16),
                    _buildStatRow('High Score', '$highScore', const Color(0xFFFFD700)),
                  ],
                  const Divider(color: Colors.white10, height: 16),
                  _buildStatRow('Fruits Sliced', '${controller.slicesCount}', Colors.lightGreenAccent),
                  const Divider(color: Colors.white10, height: 16),
                  _buildStatRow('Accuracy', '${(controller.accuracy * 100).toInt()}%', Colors.cyanAccent),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onMainMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF374151),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('MENU', style: AppTheme.titleStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1744),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF1744).withValues(alpha: 0.6),
                    ),
                    child: Text('TRY AGAIN', style: AppTheme.titleStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyStyle(fontSize: 15, color: Colors.white70)),
        Text(value, style: AppTheme.titleStyle(fontSize: 18, color: valueColor)),
      ],
    );
  }
}


