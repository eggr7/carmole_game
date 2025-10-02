import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
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

class CarComponent extends SpriteComponent with CollisionCallbacks, HasGameReference<CarmoleGame> {
  final CarColor carColor;
  int gridRow = -1;
  int gridCol = -1;
  bool isMatched = false;
  bool isFalling = false;

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
    // Add visual feedback for matched cars
    paint.color = Colors.black.withOpacity(0.5);
  }

  void applyGravity(double dt) {
    if (!isFalling) return;
    
    // Simple gravity implementation
    position.y += 200 * dt; // 200 pixels per second
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isFalling) {
      applyGravity(dt);
    }
  }
}
