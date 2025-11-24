import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../game/carmole_game.dart';

enum CarColor {
  red,
  blue,
  green,
  purple,
  orange,
}

enum CarState {
  idle,
  droppingFromCrane,
  fallingFromGravity,
  matched,
}

class CarComponent extends SpriteComponent with CollisionCallbacks, HasGameReference<CarmoleGame> {
  final CarColor carColor;
  int gridRow = -1;
  int gridCol = -1;
  bool isMatched = false;
  bool isFalling = false;
  CarState state = CarState.idle;

  static final Map<CarColor, String> colorMap = {
    CarColor.red: 'car_red.png',
    CarColor.blue: 'car_blue.png',
    CarColor.green: 'car_green.png',
    CarColor.purple: 'car_purple.png',
    CarColor.orange: 'car_orange.png',
  };

  CarComponent({required this.carColor})
      : super(
          size: Vector2.all(50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Load car sprite
    sprite = await game.loadSprite('${colorMap[carColor]!}');
    
    // Add collision detection
    add(RectangleHitbox());
  }

  static CarColor getRandomColor() {
    final random = Random();
    return CarColor.values[random.nextInt(CarColor.values.length)];
  }

  void markAsMatched() {
    isMatched = true;
    state = CarState.matched;
    
    // Arcade-style match effects: pulse, brighten, and fade
    add(
      SequenceEffect([
        // Quick pulse grow
        ScaleEffect.to(
          Vector2.all(1.2),
          EffectController(duration: 0.1),
        ),
        // Pulse shrink
        ScaleEffect.to(
          Vector2.all(0.9),
          EffectController(duration: 0.1),
        ),
        // Grow again (bounce)
        ScaleEffect.to(
          Vector2.all(1.15),
          EffectController(duration: 0.08),
        ),
      ]),
    );
    
    // Simultaneous opacity fade with color tint
    Future.delayed(const Duration(milliseconds: 200), () {
      add(
        OpacityEffect.to(
          0.0,
          EffectController(duration: 0.25),
        ),
      );
      // Add white flash overlay effect
      add(
        ColorEffect(
          Colors.white,
          EffectController(duration: 0.15),
          opacityFrom: 0.6,
          opacityTo: 0.0,
        ),
      );
    });
  }

  void applyGravity(double dt) {
    if (!isFalling) return;
    
    // Simple gravity implementation
    position.y += 200 * dt; // 200 pixels per second
  }

  // Animate car dropping from crane to target position
  void animateDropFromCrane(Vector2 targetPosition, {VoidCallback? onComplete}) {
    state = CarState.droppingFromCrane;
    
    // Fast drop animation with slight bounce on landing (arcade style)
    final moveEffect = MoveEffect.to(
      targetPosition,
      EffectController(
        duration: 0.35, // 350ms - fast arcade drop
        curve: Curves.easeInCubic, // Accelerate down
      ),
      onComplete: () {
        // Quick bounce effect on landing
        add(
          SequenceEffect([
            ScaleEffect.to(
              Vector2.all(1.15), // Squash on impact
              EffectController(duration: 0.05),
            ),
            ScaleEffect.to(
              Vector2.all(0.95), // Slight compress
              EffectController(duration: 0.05),
            ),
            ScaleEffect.to(
              Vector2.all(1.0), // Back to normal
              EffectController(duration: 0.05),
            ),
          ], onComplete: () {
            state = CarState.idle;
            onComplete?.call();
          }),
        );
      },
    );
    
    add(moveEffect);
  }

  // Animate car falling due to gravity after matches cleared
  void animateFallToPosition(Vector2 targetPosition, {VoidCallback? onComplete}) {
    state = CarState.fallingFromGravity;
    
    // Quick gravity fall with snappy landing
    final moveEffect = MoveEffect.to(
      targetPosition,
      EffectController(
        duration: 0.25, // 250ms - snappy arcade gravity
        curve: Curves.easeInQuad,
      ),
      onComplete: () {
        // Subtle settle effect
        add(
          SequenceEffect([
            ScaleEffect.to(
              Vector2.all(1.1),
              EffectController(duration: 0.04),
            ),
            ScaleEffect.to(
              Vector2.all(1.0),
              EffectController(duration: 0.04),
            ),
          ], onComplete: () {
            state = CarState.idle;
            onComplete?.call();
          }),
        );
      },
    );
    
    add(moveEffect);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isFalling) {
      applyGravity(dt);
    }
  }
}
