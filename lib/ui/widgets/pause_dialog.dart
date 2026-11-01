import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseDialog({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 36),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(
          opacity: 0.92,
          color: const Color(0xFF1B1B26),
          borderRadius: 24,
          borderColor: const Color(0x66FFFFFF),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME PAUSED',
              style: AppTheme.titleStyle(fontSize: 26, color: const Color(0xFFFFD700)),
            ),
            const SizedBox(height: 24),
            _buildButton(
              label: 'RESUME',
              icon: Icons.play_arrow_rounded,
              color: const Color(0xFF10B981),
              onPressed: onResume,
            ),
            const SizedBox(height: 12),
            _buildButton(
              label: 'RESTART',
              icon: Icons.refresh_rounded,
              color: const Color(0xFFFF6D00),
              onPressed: onRestart,
            ),
            const SizedBox(height: 12),
            _buildButton(
              label: 'MAIN MENU',
              icon: Icons.home_rounded,
              color: const Color(0xFF4B5563),
              onPressed: onMainMenu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: AppTheme.titleStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
