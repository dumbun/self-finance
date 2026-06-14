// =============================================================================
// Particle value type
// =============================================================================

import 'package:flutter/material.dart';

/// Immutable description of a single particle's orbital parameters.
@immutable
class Particle {
  const Particle({
    required this.orbitRadiusFactor,
    required this.angleOffset,
    required this.speedFactor,
    required this.size,
    required this.waveOffset,
  });

  /// Fraction in [0, 1] that scales the orbit radius relative to the canvas.
  final double orbitRadiusFactor;

  /// Starting angle in radians.
  final double angleOffset;

  /// Multiplier applied to the animation progress for speed variation.
  final double speedFactor;

  /// Dot radius in logical pixels.
  final double size;

  /// Phase offset for the secondary wave motion.
  final double waveOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Particle &&
          runtimeType == other.runtimeType &&
          orbitRadiusFactor == other.orbitRadiusFactor &&
          angleOffset == other.angleOffset &&
          speedFactor == other.speedFactor &&
          size == other.size &&
          waveOffset == other.waveOffset;

  @override
  int get hashCode => Object.hash(
    orbitRadiusFactor,
    angleOffset,
    speedFactor,
    size,
    waveOffset,
  );

  @override
  String toString() =>
      'Particle('
      'orbitRadiusFactor: $orbitRadiusFactor, '
      'angleOffset: $angleOffset, '
      'speedFactor: $speedFactor, '
      'size: $size, '
      'waveOffset: $waveOffset)';
}
