import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:self_finance/models/particles_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// An animated background widget that renders floating, orbiting dots with
/// optional soft connection lines between nearby particles.
///
/// Automatically pauses when scrolled off-screen or when the app is
/// backgrounded, and resumes when visible and foregrounded again.
///
/// Example:
/// ```dart
/// AnimatedDotPattern(
///   height: 200,
///   dotCount: 20,
///   dotColor: Colors.indigo,
/// )
/// ```
class AnimatedDotPattern extends StatefulWidget {
  const AnimatedDotPattern({
    super.key,
    this.height = 180,
    this.width = double.infinity,
    this.dotCount = 15,
    this.dotColor,
    this.maxDotSize = 4,
    this.animationDuration = const Duration(seconds: 20),
    this.visibilityThreshold = 0.05,
    this.connectionsEnabled = true,
    this.connectionOpacity = 1,
    this.seed,
  }) : assert(dotCount > 0, 'dotCount must be positive'),
       assert(maxDotSize > 0, 'maxDotSize must be positive'),
       assert(
         visibilityThreshold >= 0 && visibilityThreshold <= 1,
         'visibilityThreshold must be between 0 and 1',
       ),
       assert(
         connectionOpacity >= 0 && connectionOpacity <= 1,
         'connectionOpacity must be between 0 and 1',
       );

  /// Height of the widget.
  final double height;

  /// Width of the widget. Defaults to [double.infinity].
  final double width;

  /// Number of particles to render.
  final int dotCount;

  /// Dot colour. Defaults to the theme's primary colour at 85 % opacity.
  final Color? dotColor;

  /// Maximum radius of a single dot, in logical pixels.
  final double maxDotSize;

  /// Duration of one full animation cycle.
  final Duration animationDuration;

  /// Fraction of the widget that must be visible before animation starts.
  /// Must be in [0, 1].
  final double visibilityThreshold;

  /// Whether to draw soft lines between nearby dots.
  final bool connectionsEnabled;

  /// Base opacity for connection lines. Must be in [0, 1].
  final double connectionOpacity;

  /// Optional RNG seed for deterministic particle placement (useful in tests
  /// and golden files). When null a random seed is used.
  final int? seed;

  @override
  State<AnimatedDotPattern> createState() => _AnimatedDotPatternState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty('height', height))
      ..add(DoubleProperty('width', width))
      ..add(IntProperty('dotCount', dotCount))
      ..add(ColorProperty('dotColor', dotColor))
      ..add(DoubleProperty('maxDotSize', maxDotSize))
      ..add(
        DiagnosticsProperty<Duration>('animationDuration', animationDuration),
      )
      ..add(DoubleProperty('visibilityThreshold', visibilityThreshold))
      ..add(
        FlagProperty(
          'connectionsEnabled',
          value: connectionsEnabled,
          ifTrue: 'connections on',
        ),
      )
      ..add(DoubleProperty('connectionOpacity', connectionOpacity))
      ..add(IntProperty('seed', seed, defaultValue: null));
  }
}

class _AnimatedDotPatternState extends State<AnimatedDotPattern>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late List<Particle> _particles;

  /// Tracks visibility state set by [VisibilityDetector].
  bool _isVisible = false;

  /// Tracks whether the host app is in the foreground.
  bool _isAppActive = true;

  /// Stable key for [VisibilityDetector] — derived from [widget.key] if
  /// provided, otherwise a single UUID-like value that persists for the
  /// lifetime of this [State] object. We avoid a global counter so that
  /// hot-reload and list recycling do not corrupt keys.
  late final String _visibilityKey;

  @override
  void initState() {
    super.initState();

    _visibilityKey =
        'animated_dot_pattern_${widget.key?.toString() ?? identityHashCode(this)}';

    // Capture the current lifecycle state so _isAppActive is accurate before
    // the first didChangeAppLifecycleState callback.
    final lifecycle = SchedulerBinding.instance.lifecycleState;
    _isAppActive = lifecycle == null || lifecycle == AppLifecycleState.resumed;

    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(covariant AnimatedDotPattern oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
      // Re-sync so the new duration takes effect immediately if running.
      if (_controller.isAnimating) {
        _controller
          ..stop()
          ..repeat();
      }
    }

    final needsNewParticles =
        oldWidget.dotCount != widget.dotCount ||
        oldWidget.maxDotSize != widget.maxDotSize ||
        oldWidget.seed != widget.seed;

    if (needsNewParticles) {
      _particles = _generateParticles();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;
    if (wasActive != _isAppActive) {
      _syncAnimationState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Particle generation
  // ---------------------------------------------------------------------------

  List<Particle> _generateParticles() {
    final random = widget.seed != null ? Random(widget.seed) : Random();
    return List.generate(
      widget.dotCount,
      (_) => Particle(
        orbitRadiusFactor: random.nextDouble(),
        angleOffset: random.nextDouble() * pi * 2,
        // Speed in [0.5, 2.0] — wider spread gives more visual variety.
        speedFactor: 0.5 + random.nextDouble() * 1.5,
        // Dot radius in [1, maxDotSize + 1].
        size: 1 + random.nextDouble() * widget.maxDotSize,
        waveOffset: random.nextDouble() * pi * 2,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Animation lifecycle
  // ---------------------------------------------------------------------------

  void _syncAnimationState() {
    if (!mounted) return;

    if (_isVisible && _isAppActive) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      if (_controller.isAnimating) _controller.stop();
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    final isNowVisible = info.visibleFraction >= widget.visibilityThreshold;
    if (isNowVisible == _isVisible) return; // No change — skip work.
    _isVisible = isNowVisible;
    _syncAnimationState();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final color =
        widget.dotColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.85);

    return VisibilityDetector(
      key: ValueKey(_visibilityKey),
      onVisibilityChanged: _handleVisibilityChanged,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => CustomPaint(
              painter: _DotPatternPainter(
                progress: _controller.value,
                particles: _particles,
                color: color,
                connectionsEnabled: widget.connectionsEnabled,
                connectionOpacity: widget.connectionOpacity,
              ),
              // Explicit child so CustomPaint measures correctly in all layouts.
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Painter
// =============================================================================

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({
    required this.progress,
    required this.particles,
    required this.color,
    required this.connectionsEnabled,
    required this.connectionOpacity,
  });

  final double progress;
  final List<Particle> particles;
  final Color color;
  final bool connectionsEnabled;
  final double connectionOpacity;

  // Reusable paint objects — allocated once per painter instance, not per
  // paint() call, to avoid per-frame garbage.
  late final Paint _dotPaint = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  late final Paint _linePaint = Paint()
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    _dotPaint.color = color;

    final center = Offset(size.width / 2, size.height / 2);
    final shortestSide = min(size.width, size.height);
    final maxDistance = shortestSide * 0.12;

    // Pre-allocate the positions list with a known capacity.
    final positions = List<Offset>.filled(particles.length, Offset.zero);

    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];

      final orbitRadius =
          shortestSide * 0.1 + particle.orbitRadiusFactor * shortestSide * 0.45;
      final angle =
          progress * pi * 2 * particle.speedFactor + particle.angleOffset;
      final wave = sin(progress * pi * 4 + particle.waveOffset) * 20;

      final x = center.dx + cos(angle) * orbitRadius + cos(angle * 2) * wave;
      final y = center.dy + sin(angle) * orbitRadius + sin(angle * 3) * wave;

      final position = Offset(x, y);
      positions[i] = position;

      canvas.drawCircle(position, particle.size, _dotPaint);
    }

    if (!connectionsEnabled || positions.length < 2) return;

    for (var i = 0; i < positions.length; i++) {
      for (var j = i + 1; j < positions.length; j++) {
        final dx = positions[i].dx - positions[j].dx;
        final dy = positions[i].dy - positions[j].dy;
        // Use squared distance to avoid sqrt when possible.
        final distSq = dx * dx + dy * dy;
        final maxDistSq = maxDistance * maxDistance;

        if (distSq < maxDistSq) {
          final distance = sqrt(distSq);
          // Opacity falls off linearly with distance.
          final opacity = (1 - distance / maxDistance) * connectionOpacity;
          _linePaint.color = color.withValues(alpha: opacity);
          canvas.drawLine(positions[i], positions[j], _linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        // Use identical() for list identity — cheaper than deep equality and
        // correct because _generateParticles always produces a new list.
        !identical(oldDelegate.particles, particles) ||
        oldDelegate.color != color ||
        oldDelegate.connectionsEnabled != connectionsEnabled ||
        oldDelegate.connectionOpacity != connectionOpacity;
  }

  @override
  bool shouldRebuildSemantics(covariant _DotPatternPainter oldDelegate) =>
      false; // Purely decorative — no semantics to rebuild.
}
