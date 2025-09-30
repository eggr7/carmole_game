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

    isDropping = true;

    // Find the highest empty cell in the current column
    int targetRow = -1;
    for (int row = CarmoleGame.gridHeight - 1; row >= 0; row--) {
      if (game.gameGrid.isCellEmpty(row, currentColumn)) {
        targetRow = row;
        break;
      }
    }

    if (targetRow != -1) {
      // Create new car
      final newCar = CarComponent(carColor: CarComponent.getRandomColor());
      // Place car in grid
      game.gameGrid.placeCar(newCar, targetRow, currentColumn);
      // Check for matches after a short delay
      Future.delayed(const Duration(milliseconds: 200), () {
        game.gameGrid.checkForMatches();
        isDropping = false; // Reset for next drop
      });
    } else {
      // Column is full, handle game over or prevent drop
      print("Column ${currentColumn} is full!");
      game.gameState.isGameOver = true;
      isDropping = false; // Reset for next drop
    }
  }

  void moveLeft() {
    if (currentColumn > 0) {
      currentColumn--;
      position.x = (currentColumn * CarmoleGame.cellSize) + (CarmoleGame.cellSize / 2) - 30;
    }
  }

  void moveRight() {
    if (currentColumn < CarmoleGame.gridWidth - 1) {
      currentColumn++;
      position.x = (currentColumn * CarmoleGame.cellSize) + (CarmoleGame.cellSize / 2) - 30;
    }
  }
}
