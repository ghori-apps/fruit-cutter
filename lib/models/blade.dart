import 'package:flutter/material.dart';

enum BladeType {
  classic,
  inferno,
  cyber,
  frostbite,
  golden,
  shadow,
}

class BladeSkin {
  final BladeType type;
  final String id;
  final String name;
  final String description;
  final int price;
  final Color coreColor;
  final Color trailColor;
  final Color glowColor;
  final Color sparkColor;
  final double baseWidth;
  final bool isDefaultUnlocked;

  const BladeSkin({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.coreColor,
    required this.trailColor,
    required this.glowColor,
    required this.sparkColor,
    this.baseWidth = 14.0,
    this.isDefaultUnlocked = false,
  });

  static const List<BladeSkin> allBlades = [
    BladeSkin(
      type: BladeType.classic,
      id: 'blade_classic',
      name: 'Original Katana',
      description: 'Forged steel with swift silver gleam.',
      price: 0,
      coreColor: Colors.white,
      trailColor: Color(0xFFE2E8F0),
      glowColor: Color(0xCC00E5FF),
      sparkColor: Colors.white,
      baseWidth: 18.0,
      isDefaultUnlocked: true,
    ),
    BladeSkin(
      type: BladeType.inferno,
      id: 'blade_inferno',
      name: 'Inferno Flame',
      description: 'Scorches fruits with blazing dragon fire.',
      price: 250,
      coreColor: Color(0xFFFFF7ED),
      trailColor: Color(0xFFFF6B00),
      glowColor: Color(0xFFFF3D00),
      sparkColor: Color(0xFFFFD600),
      baseWidth: 20.0,
    ),
    BladeSkin(
      type: BladeType.cyber,
      id: 'blade_cyber',
      name: 'Cyber Laser',
      description: 'High-tech plasma beam slicing with neon sparks.',
      price: 500,
      coreColor: Color(0xFFE0F7FA),
      trailColor: Color(0xFF00E5FF),
      glowColor: Color(0xFFFF0055),
      sparkColor: Color(0xFF00E5FF),
      baseWidth: 20.0,
    ),
    BladeSkin(
      type: BladeType.frostbite,
      id: 'blade_frostbite',
      name: 'Frostbite Edge',
      description: 'Sub-zero crystal blade leaving icy mist.',
      price: 750,
      coreColor: Color(0xFFFFFFFF),
      trailColor: Color(0xFF38BDF8),
      glowColor: Color(0xFF00E5FF),
      sparkColor: Color(0xFFBAE6FD),
      baseWidth: 20.0,
    ),
    BladeSkin(
      type: BladeType.golden,
      id: 'blade_golden',
      name: 'Golden Dragon',
      description: 'Radiant royal gold blessed with star dust.',
      price: 1200,
      coreColor: Color(0xFFFFFFE0),
      trailColor: Color(0xFFFFD700),
      glowColor: Color(0xFFFF9100),
      sparkColor: Color(0xFFFFF9C4),
      baseWidth: 22.0,
    ),
    BladeSkin(
      type: BladeType.shadow,
      id: 'blade_shadow',
      name: 'Shadow Void',
      description: 'Dark matter katana shrouded in purple mist.',
      price: 1800,
      coreColor: Color(0xFFF3E8FF),
      trailColor: Color(0xFFA855F7),
      glowColor: Color(0xFF7E22CE),
      sparkColor: Color(0xFFE9D5FF),
      baseWidth: 20.0,
    ),
  ];

  static BladeSkin getById(String id) {
    return allBlades.firstWhere(
      (b) => b.id == id,
      orElse: () => allBlades.first,
    );
  }
}

class BladePoint {
  final Offset position;
  final DateTime time;
  final double width;

  BladePoint(this.position, this.time, {this.width = 10.0});
}
