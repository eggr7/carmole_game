import 'package:flame/components.dart';
// import 'package:flutter/material.dart';
import '../game/carmole_game.dart';
import 'car_component.dart';

class CraneComponent extends SpriteComponent with HasGameReference<CarmoleGame> {
  bool isDropping = false;
  int currentColumn = 3; // Start in middle
  bool isFlipped = false; // Track flip state
  CarComponent? nextCar; // Preview car hanging from crane
  // Horizontal offsets to align preview car under the hook in each orientation
  static const double hookOffsetXNotFlipped = 64; // When crane faces right (columns 3-5)
  static const double hookOffsetXFlipped = 61; // When crane faces left (columns 0-2)

  CraneComponent()
      : super(
          size: Vector2(100, 100),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite('crane_sprite.png');
    
    // Keep crane at full 100x100 pixel size without scaling
    scale = Vector2.all(1.0);
    
    // Generate the first preview car
    generateNextCar();
  }

  void dropCar() {
    if (isDropping || nextCar == null) return;

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
      // Use the preview car's color for the dropped car
      final carColor = nextCar!.carColor;
      final newCar = CarComponent(carColor: carColor);
      // Ensure neutral orientation for dropped car
      newCar.angle = 0;
      newCar.scale = Vector2.all(1);
      // Place car in grid
      game.gameGrid.placeCar(newCar, targetRow, currentColumn);
      print('Car dropped in column $currentColumn, row $targetRow');
      
      // Generate next preview car
      generateNextCar();
      
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
      updateFlip();
      print('Crane moved left to column $currentColumn, position.x = ${position.x}');
    }
  }

  void moveRight() {
    if (currentColumn < CarmoleGame.gridWidth - 1) {
      currentColumn++;
      // Center crane over the column (grid is now centered at origin)
      position.x = (currentColumn - (CarmoleGame.gridWidth - 1) / 2) * CarmoleGame.cellSize;
      updateFlip();
      print('Crane moved right to column $currentColumn, position.x = ${position.x}');
    }
  }

  void updateFlip() {
    // Flip if on left half of grid (columns 0, 1, 2)
    final bool shouldFlip = currentColumn < CarmoleGame.gridWidth / 2;
    
    if (shouldFlip != isFlipped) {
      flipHorizontallyAroundCenter();
      isFlipped = shouldFlip;
      // Update preview car position to stay under hook side after flipping
      if (nextCar != null) {
        nextCar!.position = Vector2(
          isFlipped ? hookOffsetXFlipped : hookOffsetXNotFlipped,
          nextCar!.position.y,
        );
      }
    }
  }

  void generateNextCar() {
    // Remove old preview if exists
    if (nextCar != null) {
      nextCar!.removeFromParent();
    }
    
    // Create new preview car
    nextCar = CarComponent(carColor: CarComponent.getRandomColor());
    // Position under the hook; different offsets for each crane orientation
    nextCar!.position = Vector2(
      isFlipped ? hookOffsetXFlipped : hookOffsetXNotFlipped,
      60,
    );
    nextCar!.size = Vector2.all(40); // Make preview car slightly smaller
    add(nextCar!); // Add as child of crane
  }
}
