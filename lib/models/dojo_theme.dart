import 'package:flutter/material.dart';

enum DojoThemeType {
  classicWood,
  cyberpunk,
  zenBamboo,
  sunsetPagoda,
  magmaForge,
}

class DojoTheme {
  final DojoThemeType type;
  final String id;
  final String name;
  final String description;
  final int price;
  final List<Color> backgroundGradient;
  final Color wallBoardColor;
  final Color accentColor;
  final Color ambientLightColor;
  final String? backgroundImage;
  final bool isDefaultUnlocked;

  const DojoTheme({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.backgroundGradient,
    required this.wallBoardColor,
    required this.accentColor,
    required this.ambientLightColor,
    this.backgroundImage,
    this.isDefaultUnlocked = false,
  });

  static const List<DojoTheme> allThemes = [
    DojoTheme(
      type: DojoThemeType.classicWood,
      id: 'dojo_classic',
      name: 'Classic Dojo',
      description: 'Traditional handcrafted cedar wooden boards.',
      price: 0,
      backgroundGradient: [Color(0xFF8B4513), Color(0xFF5C2C0E)],
      wallBoardColor: Color(0xFFA0522D),
      accentColor: Color(0xFFFFB300),
      ambientLightColor: Color(0x66FFB300),
      backgroundImage: 'assets/images/background.png',
      isDefaultUnlocked: true,
    ),
    DojoTheme(
      type: DojoThemeType.cyberpunk,
      id: 'dojo_cyberpunk',
      name: 'Cyberpunk Grid',
      description: 'Futuristic neon synthwave dojo in Neo Tokyo.',
      price: 300,
      backgroundGradient: [Color(0xFF2A085C), Color(0xFF160A36)],
      wallBoardColor: Color(0xFF3D1A7A),
      accentColor: Color(0xFF00E5FF),
      ambientLightColor: Color(0x66FF007F),
    ),
    DojoTheme(
      type: DojoThemeType.zenBamboo,
      id: 'dojo_zen',
      name: 'Zen Bamboo',
      description: 'Tranquil emerald bamboo forest under moonlight.',
      price: 600,
      backgroundGradient: [Color(0xFF0F522E), Color(0xFF082C18)],
      wallBoardColor: Color(0xFF1B7A48),
      accentColor: Color(0xFF10B981),
      ambientLightColor: Color(0x5534D399),
    ),
    DojoTheme(
      type: DojoThemeType.sunsetPagoda,
      id: 'dojo_sunset',
      name: 'Sunset Pagoda',
      description: 'Warm golden twilight over ancient mountain shrine.',
      price: 1000,
      backgroundGradient: [Color(0xFF9E2A2B), Color(0xFF4A0E17)],
      wallBoardColor: Color(0xFFB83234),
      accentColor: Color(0xFFFF7A00),
      ambientLightColor: Color(0x66FFA000),
    ),
    DojoTheme(
      type: DojoThemeType.magmaForge,
      id: 'dojo_magma',
      name: 'Magma Forge',
      description: 'Volcanic blade forge glowing with liquid obsidian.',
      price: 1500,
      backgroundGradient: [Color(0xFF8B1E0F), Color(0xFF4A0800)],
      wallBoardColor: Color(0xFFA82613),
      accentColor: Color(0xFFFF3D00),
      ambientLightColor: Color(0x66FF5722),
    ),
  ];

  static DojoTheme getById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => allThemes.first,
    );
  }
}
