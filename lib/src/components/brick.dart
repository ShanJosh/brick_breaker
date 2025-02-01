import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'power_up.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
      : super(
          size: Vector2(brickWidth, brickHeight),
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
          children: [RectangleHitbox()],
        );

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    removeFromParent();
    game.score.value++;

    _showBreakEffect();

    _dropPowerUp();

    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
    }
  }

  void _showBreakEffect() {
    final particleSystem = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        generator: (i) {
          final angle = (i / 10) * 360;
          const speed = 100.0;
          return AcceleratedParticle(
            position: position.clone(),
            speed: Vector2(speed * cos(angle), speed * sin(angle)),
            lifespan: 0.2,
            child: CircleParticle(
              radius: 5.0,
              paint: BasicPalette.yellow.withAlpha(150).paint(),
            ),
          );
        },
      ),
    );

    game.world.add(particleSystem);

    Future.delayed(const Duration(milliseconds: 200), () {
      particleSystem.removeFromParent();
    });
  }

  void _dropPowerUp() {
    if (Random().nextDouble() < 0.2) {
      final powerUpType =
          PowerUpType.values[Random().nextInt(PowerUpType.values.length)];

      final powerUp = PowerUp(
        powerUpType: powerUpType,
        position: position + Vector2(0, -25),
      );

      game.world.add(powerUp);
    }
  }
}
