// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';

class Bat extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  final Radius cornerRadius;
  final _paint = Paint();
  final _glowPaint = Paint();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _glowPaint.color = Colors.blue.withOpacity(0.3); 
    _glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        cornerRadius,
      ),
      _glowPaint,
    );

    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xff8a2be2), 
        Color(0xff00e5ff), 
      ],
      stops: [0.0, 1.0],
    );

    _paint.shader = gradient.createShader(Offset.zero & size.toSize());
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        cornerRadius,
      ),
      _paint,
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x).clamp(0, game.width);
  }

  void moveBy(double dx) {
    add(
      MoveToEffect(
        Vector2((position.x + dx).clamp(0, game.width), position.y),
        EffectController(duration: 0.1),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateGlowEffect();
  }

  void _updateGlowEffect() {
    const speedMultiplier = 2 * pi; 
    final opacity =
        0.7 + 0.3 * (sin(game.elapsedTime * speedMultiplier) + 1) / 2;
    _paint.color = _paint.color.withOpacity(opacity);
  }
}
