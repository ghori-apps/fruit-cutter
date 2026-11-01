import 'package:flutter/material.dart';
import '../../services/audio_manager.dart';
import '../../services/storage_service.dart';
import '../theme/app_theme.dart';

class SettingsDialog extends StatefulWidget {
  final StorageService storageService;
  final AudioManager audioManager;

  const SettingsDialog({
    super.key,
    required this.storageService,
    required this.audioManager,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool _musicEnabled;
  late bool _sfxEnabled;
  late bool _hapticsEnabled;
  late double _bgmVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();
    _musicEnabled = widget.storageService.isMusicEnabled;
    _sfxEnabled = widget.storageService.isSfxEnabled;
    _hapticsEnabled = widget.storageService.isHapticsEnabled;
    _bgmVolume = widget.storageService.bgmVolume;
    _sfxVolume = widget.storageService.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration(
          opacity: 0.94,
          color: const Color(0xFF181528),
          borderRadius: 28,
          borderColor: const Color(0xFFFFB300).withValues(alpha: 0.4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '⚙️ SETTINGS',
                  style: AppTheme.titleStyle(
                    fontSize: 26,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () {
                    widget.audioManager.playButtonClick();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Music Toggle & Slider
            _buildToggleRow(
              label: 'Music (BGM)',
              icon: Icons.music_note_rounded,
              value: _musicEnabled,
              onChanged: (val) async {
                setState(() => _musicEnabled = val);
                await widget.audioManager.toggleMusic(val);
              },
            ),
            if (_musicEnabled)
              Slider(
                value: _bgmVolume,
                min: 0.0,
                max: 1.0,
                activeColor: const Color(0xFFFFB300),
                inactiveColor: Colors.white24,
                onChanged: (val) {
                  setState(() => _bgmVolume = val);
                  widget.audioManager.updateBgmVolume(val);
                },
              ),

            const Divider(color: Colors.white10, height: 20),

            // SFX Toggle & Slider
            _buildToggleRow(
              label: 'Sound Effects (SFX)',
              icon: Icons.volume_up_rounded,
              value: _sfxEnabled,
              onChanged: (val) async {
                setState(() => _sfxEnabled = val);
                await widget.storageService.setSfxEnabled(val);
                if (val) widget.audioManager.playSlice();
              },
            ),
            if (_sfxEnabled)
              Slider(
                value: _sfxVolume,
                min: 0.0,
                max: 1.0,
                activeColor: const Color(0xFFFF6D00),
                inactiveColor: Colors.white24,
                onChanged: (val) {
                  setState(() => _sfxVolume = val);
                  widget.storageService.setSfxVolume(val);
                },
              ),

            const Divider(color: Colors.white10, height: 20),

            // Haptics Toggle
            _buildToggleRow(
              label: 'Haptic Feedback',
              icon: Icons.vibration_rounded,
              value: _hapticsEnabled,
              onChanged: (val) async {
                setState(() => _hapticsEnabled = val);
                await widget.storageService.setHapticsEnabled(val);
                if (val) widget.audioManager.playButtonClick();
              },
            ),

            const SizedBox(height: 24),

            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.audioManager.playButtonClick();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6D00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('DONE', style: AppTheme.titleStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: const Color(0xFFFFD700),
          activeTrackColor: const Color(0xFFFF6D00),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
