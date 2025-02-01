// ignore_for_file: unnecessary_null_comparison

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
    required speed,
  }) : super(
          radius: radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color.fromARGB(255, 255, 255, 255)
            ..style = PaintingStyle.fill,
          children: [
            CircleHitbox(),
          ],
        );

  late final Vector2 velocity;
  final double difficultyModifier;
  bool isGameOverSoundPlaying = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _addPulsatingGlowEffect();
    _addSparkleEffect();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt * 2.0;
  }

  void _addPulsatingGlowEffect() {
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.5,
          alternate: true,
          infinite: true,
        ),
      ),
    );

    add(
      OpacityEffect.to(
        1.0,
        EffectController(
          duration: 0.5,
          alternate: true,
          infinite: true,
        ),
      ),
    );
  }

  void _addSparkleEffect() {
    final sparkleEffect = ParticleSystemComponent(
      particle: Particle.generate(
        count: 3,
        lifespan: 0.5,
        generator: (i) {
          return MovingParticle(
            to: Vector2(
              (i - 1.5) * 10,
              radius * 2,
            ),
            child: CircleParticle(
              radius: 1.0,
              paint: Paint()..color = Colors.white.withOpacity(0.8),
            ),
          );
        },
      ),
    );
    add(sparkleEffect);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0 ||
          intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        final remainingBalls = game.world.children.query<Ball>().length;
        if (remainingBalls <= 1) {
          if (!isGameOverSoundPlaying) {
            FlameAudio.play('game_over.mp3');
            isGameOverSoundPlaying = true;
          }

          add(RemoveEffect(
            delay: 0.35,
            onComplete: () {
              Future.delayed(const Duration(milliseconds: 350), () {
                // Trigger game over
                game.playState = PlayState.gameOver;

                // Remove all bat components
                game.world.removeAll(game.world.children.query<Bat>());
              });
            },
          ));
        } else {
          removeFromParent(); // Remove the ball if there are remaining balls
        }
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x = velocity.x +
          (position.x - other.position.x) / other.size.x * game.width * 0.3;
      FlameAudio.play('paddle_hit.mp3');
    } else if (other is Brick) {
      if (other.paint != null) {
        paint.color = other.paint.color;
      } else {
        paint.color = Colors.white; // Default to white if no color
      }

      if (position.y < other.position.y - other.size.y / 2 ||
          position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else {
        velocity.x = -velocity.x;
      }

      velocity.setFrom(Vector2(
            velocity.x.clamp(-500, 500),
            velocity.y.clamp(-500, 500),
          ) *
          difficultyModifier);

      FlameAudio.play('brick_hit.mp3');
    }
  }
}
