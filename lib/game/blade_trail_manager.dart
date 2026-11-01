import 'dart:math';
import 'package:flutter/material.dart';
import '../models/blade.dart';

class BladeTrailManager {
  final List<BladePoint> _points = [];
  final Duration maxPointAge;
  bool isPointerDown = false;
  Offset? activePosition;

  BladeTrailManager({this.maxPointAge = const Duration(milliseconds: 500)});

  List<BladePoint> get points => List.unmodifiable(_points);

  void startTouch(Offset position) {
    _points.clear(); // Clear any stale points from previous touch gestures
    isPointerDown = true;
    activePosition = position;
    _points.add(BladePoint(position, DateTime.now()));
  }

  void updateTouch(Offset position) {
    isPointerDown = true;
    activePosition = position;
    addPoint(position);
  }

  void endTouch() {
    isPointerDown = false;
    activePosition = null;
    // Don't clear points immediately - let them fade via maxPointAge pruning
  }

  void addPoint(Offset position) {
    final now = DateTime.now();
    _pruneOldPoints(now);

    if (_points.isNotEmpty) {
      final lastPos = _points.last.position;
      final dist = (position - lastPos).distance;
      if (dist < 2.0) {
        _points.last = BladePoint(position, now);
        return;
      }
    }

    _points.add(BladePoint(position, now));
  }

  void update() {
    final now = DateTime.now();
    _pruneOldPoints(now);

    if (isPointerDown && activePosition != null) {
      if (_points.isEmpty) {
        _points.add(BladePoint(activePosition!, now));
      } else {
        _points.last = BladePoint(activePosition!, now);
      }
    }
  }

  void clear() {
    _points.clear();
    isPointerDown = false;
    activePosition = null;
  }

  void _pruneOldPoints(DateTime now) {
    _points.removeWhere((p) => now.difference(p.time) > maxPointAge);
  }

  /// 100% mathematically foolproof point-to-segment intersection
  bool checkIntersection(Offset fruitCenter, double fruitRadius) {
    if (_points.isEmpty) return false;

    // Generous hitbox for fluid touchscreen cutting (fruit radius + 24px)
    final effectiveRadius = fruitRadius + 24.0;

    // Single touch point proximity
    if (_points.length == 1) {
      return (_points.first.position - fruitCenter).distance <= effectiveRadius;
    }

    // Check all recent segments
    final checkCount = min(12, _points.length - 1);
    final startIndex = max(0, _points.length - 1 - checkCount);

    for (int i = startIndex; i < _points.length - 1; i++) {
      final p1 = _points[i].position;
      final p2 = _points[i + 1].position;

      if (_pointToSegmentDistance(fruitCenter, p1, p2) <= effectiveRadius) {
        return true;
      }
    }

    // Also check tip point distance
    if ((_points.last.position - fruitCenter).distance <= effectiveRadius) {
      return true;
    }

    return false;
  }

  double getLatestSwipeAngle() {
    if (_points.length < 2) return 0.0;
    final p1 = _points[_points.length - 2].position;
    final p2 = _points.last.position;
    return atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  }

  double _pointToSegmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final abLenSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLenSq == 0) return (p - a).distance;
    final t = (ap.dx * ab.dx + ap.dy * ab.dy) / abLenSq;
    final clampedT = t.clamp(0.0, 1.0);
    final nearest = a + ab * clampedT;
    return (p - nearest).distance;
  }
}
