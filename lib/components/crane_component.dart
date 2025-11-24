import 'package:flame/components.dart';
import 'dart:math' as math;
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
  
  // Swing animation properties
  double _swingTime = 0.0;
  double _swingAmplitude = 0.08; // Swing angle in radians (~4.5 degrees)
  double _swingSpeed = 2.0; // Oscillations per second
  double _swingBoost = 0.0; // Extra swing when moving
  double _swingBoostDecay = 3.0; // How fast boost decays

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
      
      // Get crane's world position for starting the drop animation
      final craneWorldPos = position;
      final startPos = Vector2(craneWorldPos.x, craneWorldPos.y + 60); // Start below crane
      
      // Get target grid position
      final targetPos = game.gameGrid.getCellPosition(targetRow, currentColumn);
      
      // Add car to world at crane position
      newCar.position = startPos;
      game.world.add(newCar);
      
      // Update grid reference immediately (but car will animate to position)
      newCar.gridRow = targetRow;
      newCar.gridCol = currentColumn;
      game.gameGrid.grid[targetRow][currentColumn] = newCar;
      
      print('🚗 Player dropped car in column $currentColumn, row $targetRow');
      
      // Animate the drop
      newCar.animateDropFromCrane(targetPos, onComplete: () {
        // Check for matches after drop completes
        game.gameGrid.checkForMatches();
        isDropping = false; // Reset for next drop
      });
      
      // Generate next preview car immediately
      generateNextCar();
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
      // Boost swing when moving
      _swingBoost = 0.15;
      print('Crane moved left to column $currentColumn, position.x = ${position.x}');
    }
  }

  void moveRight() {
    if (currentColumn < CarmoleGame.gridWidth - 1) {
      currentColumn++;
      // Center crane over the column (grid is now centered at origin)
      position.x = (currentColumn - (CarmoleGame.gridWidth - 1) / 2) * CarmoleGame.cellSize;
      updateFlip();
      // Boost swing when moving
      _swingBoost = 0.15;
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

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update swing animation
    _swingTime += dt;
    
    // Decay the boost over time
    if (_swingBoost > 0) {
      _swingBoost = math.max(0, _swingBoost - _swingBoostDecay * dt);
    }
    
    // Apply pendulum swing to preview car
    if (nextCar != null && !isDropping) {
      final totalAmplitude = _swingAmplitude + _swingBoost;
      final swingAngle = math.sin(_swingTime * _swingSpeed * 2 * math.pi) * totalAmplitude;
      nextCar!.angle = swingAngle;
    }
  }
}
