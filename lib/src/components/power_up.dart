import 'package:brick_breaker/src/components/ball.dart';
import 'package:brick_breaker/src/components/bat.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart';

enum PowerUpType { green, blue, yellow, black, red }

class PowerUp extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  final PowerUpType powerUpType;
  late Vector2 velocity;
  List<Ball> spawnedBalls = [];

  PowerUp({required this.powerUpType, required Vector2 position})
      : super(
          size: Vector2(20, 20),
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = _getPowerUpColor(powerUpType),
          children: [RectangleHitbox()],
        ) {
    velocity = Vector2(0, 200);

    (children.first as RectangleHitbox).collisionType = CollisionType.passive;
  }

  static Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.green:
        return Colors.green;
      case PowerUpType.blue:
        return Colors.blue;
      case PowerUpType.yellow:
        return Colors.yellow;
      case PowerUpType.black:
        return Colors.black;
      case PowerUpType.red:
        return Colors.red;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bat) {
      _applyPowerUp();
      removeFromParent();
    }
  }

  void _applyPowerUp() {
    switch (powerUpType) {
      case PowerUpType.green:
        _enhanceBat();
        break;
      case PowerUpType.blue:
        _slowDownBall();
        break;
      case PowerUpType.yellow:
        _multiplyBall();
        break;
      case PowerUpType.black:
        _shrinkBat();
        break;
      case PowerUpType.red:
        _gameOver();
        break;
    }
  }

  void _enhanceBat() {
    final bat = game.world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      bat.size.x *= 1.2;
    }
  }

  void _slowDownBall() {
    final balls = game.world.children.query<Ball>();
    for (var ball in balls) {
      if (ball.velocity.length > 0) {
        ball.velocity.scale(0.5);

        Future.delayed(const Duration(seconds: 5), () {
          ball.velocity.scale(
              2); 
        });
      }
    }
  }

  void _multiplyBall() {
    final ball = game.world.children.query<Ball>().firstOrNull;
    if (ball != null) {
      for (int i = 0; i < 1; i++) {
        final newBall = Ball(
          position: ball.position.clone(),
          velocity: ball.velocity.clone()..rotate(0.2 * (i == 0 ? 1 : -1)),
          radius: ball.radius,
          difficultyModifier: ball.difficultyModifier,
          speed: ball.velocity.length,
        );
        game.world.add(newBall);
        spawnedBalls.add(newBall);
      }
    }
  }

  void _shrinkBat() {
    final bat = game.world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      bat.size.x *= 0.8;
    }
  }

  void _gameOver() {
    game.playState = PlayState.gameOver;
    game.overlays.add(PlayState.gameOver.name);

    game.world.removeAll(game.world.children.query<Ball>());

    final bats = game.world.children.query<Bat>();
    if (bats.isNotEmpty) {
      game.world.removeAll(bats);
    }

    FlameAudio.bgm.stop();

    FlameAudio.play('game_over.mp3');
  }

  void removeExtraBall() {
    if (spawnedBalls.isNotEmpty) {
      final ballToRemove = spawnedBalls.last;
      game.world.remove(ballToRemove);
      spawnedBalls.remove(ballToRemove);
    }
  }
}
