import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
import '../game/carmole_game.dart';
import 'car_component.dart';

class CraneComponent extends SpriteComponent with HasGameReference<CarmoleGame> {
  bool isDropping = false;
  int currentColumn = 3; // Start in middle

  CraneComponent()
      : super(
          size: Vector2(120, 120),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('crane_sprite.png');
    
    // Scale the crane sprite to 120x120 pixels (assuming original is ~500x500)
    final double scaleFactor = 120.0 / 500.0;
    scale = Vector2.all(scaleFactor);
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
      // Center crane over the column (grid is now centered at origin)
      position.x = (currentColumn - (CarmoleGame.gridWidth - 1) / 2) * CarmoleGame.cellSize;
    }
  }

  void moveRight() {
    if (currentColumn < CarmoleGame.gridWidth - 1) {
      currentColumn++;
      // Center crane over the column (grid is now centered at origin)
      position.x = (currentColumn - (CarmoleGame.gridWidth - 1) / 2) * CarmoleGame.cellSize;
    }
  }
}
