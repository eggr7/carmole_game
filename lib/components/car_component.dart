import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../game/carmole_game.dart';


enum CarColor {
  red,
  blue,
  green,
  yellow,
  purple,
  orange,
}

class CarComponent extends RectangleComponent with CollisionCallbacks, HasGameReference<CarmoleGame>{
  final CarColor carColor;
  int gridRow = -1;
  int gridCol = -1;
  bool isMatched = false;
  bool isFalling = false;
  
  static final Map<CarColor, Color> colorMap = {
    CarColor.red: Colors.red.shade700,
    CarColor.blue: Colors.blue.shade700,
    CarColor.green: Colors.green.shade700,
    CarColor.yellow: Colors.yellow.shade700,
    CarColor.purple: Colors.purple.shade700,
    CarColor.orange: Colors.orange.shade700,
  };
  
  CarComponent({required this.carColor})
      : super(
          size: Vector2.all(50),
          anchor: Anchor.center,
        );
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Set car appearance
    paint = Paint()..color = colorMap[carColor]!;
    
    // Add collision detection
    add(RectangleHitbox());
    
    // Add car details (simple representation)
    _addCarDetails();
  }
  
  void _addCarDetails() {
    // Add wheels
    final leftWheel = CircleComponent(
      radius: 8,
      paint: Paint()..color = Colors.black,
      position: Vector2(12, 35),
    );
    final rightWheel = CircleComponent(
      radius: 8,
      paint: Paint()..color = Colors.black,
      position: Vector2(38, 35),
    );
    
    // Add windows
    final window = RectangleComponent(
      size: Vector2(30, 15),
      paint: Paint()..color = Colors.lightBlue.shade200,
      position: Vector2(10, 8),
    );
    
    add(leftWheel);
    add(rightWheel);
    add(window);
  }
  
  static CarColor getRandomColor() {
    final random = Random();
    return CarColor.values[random.nextInt(CarColor.values.length)];
  }
  
  void markAsMatched() {
    isMatched = true;
    // Add visual feedback for matched cars
    paint = Paint()..color = colorMap[carColor]!.withAlpha(128);
  }
  
  void applyGravity(double dt) {
    if (!isFalling) return;
    
    // Simple gravity implementation> use the dt parameter 
    position.y += 200 * dt;  // 200 pixels per second
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (isFalling) {
      applyGravity(dt);  // Passed down dt parameter
    }
  }
}

