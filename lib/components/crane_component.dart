import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
// import 'dart:math';
import '../game/carmole_game.dart';
import 'car_component.dart';

class CraneComponent extends PositionComponent with HasGameReference<CarmoleGame> {
  late RectangleComponent craneArm;
  late RectangleComponent craneCable;
  late CircleComponent craneHook;
  bool isDropping = false;
  int currentColumn = 3; // Start in middle
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Create crane arm
    craneArm = RectangleComponent(
      size: Vector2(200, 20),
      paint: Paint()..color = Colors.brown,
      position: Vector2(-100, 0),
      anchor: Anchor.center,
    );
    
    // Create cable
    craneCable = RectangleComponent(
      size: Vector2(4, 80),
      paint: Paint()..color = Colors.grey.shade600,
      position: Vector2(-2, 20),
      anchor: Anchor.topCenter,
    );
    
    // Create hook
    craneHook = CircleComponent(
      radius: 8,
      paint: Paint()..color = Colors.yellow.shade700,
      position: Vector2(0, 100),
      anchor: Anchor.center,
    );
    
    add(craneArm);
    add(craneCable);
    add(craneHook);
  }
  
  void dropCar() {
    if (isDropping) return;
    
    isDropping = false; // Simple implementation for now
    
    // Create new car
    final newCar = CarComponent(carColor: CarComponent.getRandomColor());
    newCar.position = Vector2(position.x + 30, position.y + 120);
    
    // Add car to game
    game.world.add(newCar);
  }
}
