import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game/carmole_game.dart';
import 'car_component.dart';


class GridComponent extends Component with HasGameReference<CarmoleGame> {
  late List<List<CarComponent?>> grid;
  late RectangleComponent background;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Create grid background centered at origin
    background = RectangleComponent(
      size: Vector2(
        CarmoleGame.gridWidth * CarmoleGame.cellSize,
        CarmoleGame.gridHeight * CarmoleGame.cellSize,
      ),
      paint: Paint()..color = Colors.transparent,
      position: Vector2(
        -(CarmoleGame.gridWidth * CarmoleGame.cellSize) / 2,
        -(CarmoleGame.gridHeight * CarmoleGame.cellSize) / 2,
      ),
      anchor: Anchor.topLeft,
    );
    add(background);
    
    // Add grid lines for visual clarity
    _addGridLines();
  }
  
  void initializeGrid() {
    grid = List.generate(
      CarmoleGame.gridHeight,
      (row) => List.generate(
        CarmoleGame.gridWidth,
        (col) => null,
      ),
    );
  }
  
  void _addGridLines() {
    final double gridStartX = -(CarmoleGame.gridWidth * CarmoleGame.cellSize) / 2;
    final double gridStartY = -(CarmoleGame.gridHeight * CarmoleGame.cellSize) / 2;
    
    // Vertical lines
    for (int i = 0; i <= CarmoleGame.gridWidth; i++) {
      final line = RectangleComponent(
        size: Vector2(2, CarmoleGame.gridHeight * CarmoleGame.cellSize),
        paint: Paint()..color = Colors.white38,
        position: Vector2(gridStartX + i * CarmoleGame.cellSize, gridStartY),
        anchor: Anchor.topLeft,
      );
      add(line);
    }
    
    // Horizontal lines
    for (int i = 0; i <= CarmoleGame.gridHeight; i++) {
      final line = RectangleComponent(
        size: Vector2(CarmoleGame.gridWidth * CarmoleGame.cellSize, 2),
        paint: Paint()..color = Colors.white38,
        position: Vector2(gridStartX, gridStartY + i * CarmoleGame.cellSize),
        anchor: Anchor.topLeft,
      );
      add(line);
    }
  }
  
  Vector2 getCellPosition(int row, int col) {
    final double gridStartX = -(CarmoleGame.gridWidth * CarmoleGame.cellSize) / 2;
    final double gridStartY = -(CarmoleGame.gridHeight * CarmoleGame.cellSize) / 2;
    
    return Vector2(
      gridStartX + col * CarmoleGame.cellSize + CarmoleGame.cellSize / 2,
      gridStartY + row * CarmoleGame.cellSize + CarmoleGame.cellSize / 2,
    );
  }
  
  bool isValidPosition(int row, int col) {
    return row >= 0 && 
           row < CarmoleGame.gridHeight && 
           col >= 0 && 
           col < CarmoleGame.gridWidth;
  }
  
  bool isCellEmpty(int row, int col) {
    if (!isValidPosition(row, col)) return false;
    return grid[row][col] == null;
  }
  
  void placeCar(CarComponent car, int row, int col, {bool addToParent = true}) {
    if (isValidPosition(row, col) && isCellEmpty(row, col)) {
      grid[row][col] = car;
      car.gridRow = row;
      car.gridCol = col;
      car.position = getCellPosition(row, col);
      if (addToParent) {
        add(car);
      }
    }
  }
  
  void removeCar(int row, int col) {
    if (isValidPosition(row, col) && grid[row][col] != null) {
      final car = grid[row][col]!;
      grid[row][col] = null;
      car.removeFromParent();
    }
  }
  
  void pushRowsUpAndAddNew(List<CarComponent> newRowCars) {
    print('Pushing all rows up and adding new row at bottom...');
    
    // Step 1: Move all existing cars up by one row
    // Start from top and go down to avoid overwriting
    for (int row = 0; row < CarmoleGame.gridHeight - 1; row++) {
      for (int col = 0; col < CarmoleGame.gridWidth; col++) {
        final car = grid[row + 1][col];
        if (car != null) {
          // Move car from row+1 to row
          grid[row][col] = car;
          grid[row + 1][col] = null;
          car.gridRow = row;
          car.gridCol = col;
          
          // Animate the push up
          final targetPos = getCellPosition(row, col);
          car.add(
            MoveEffect.to(
              targetPos,
              EffectController(duration: 0.3),
            ),
          );
        } else {
          grid[row][col] = null;
        }
      }
    }
    
    // Step 2: Add new row at bottom (row 7)
    for (int col = 0; col < CarmoleGame.gridWidth && col < newRowCars.length; col++) {
      final car = newRowCars[col];
      grid[CarmoleGame.gridHeight - 1][col] = car;
      car.gridRow = CarmoleGame.gridHeight - 1;
      car.gridCol = col;
      
      // Position car below grid initially for animation
      final startPos = getCellPosition(CarmoleGame.gridHeight, col);
      car.position = startPos;
      add(car);
      
      // Animate car sliding up into position
      final targetPos = getCellPosition(CarmoleGame.gridHeight - 1, col);
      car.add(
        MoveEffect.to(
          targetPos,
          EffectController(duration: 0.3),
        ),
      );
    }
    
    print('Row push complete. New row added at bottom.');
  }

  void checkForMatches() {
    final List<CarComponent> matchedCars = [];

    // Check for horizontal matches
    for (int row = 0; row < CarmoleGame.gridHeight; row++) {
      for (int col = 0; col <= CarmoleGame.gridWidth - 4; col++) {
        final car = grid[row][col];
        if (car != null) {
          final match = [car];
          for (int i = 1; i < 4; i++) {
            final nextCar = grid[row][col + i];
            if (nextCar != null && nextCar.carColor == car.carColor) {
              match.add(nextCar);
            } else {
              break;
            }
          }
          if (match.length >= 4) {
            matchedCars.addAll(match);
          }
        }
      }
    }

    // Check for vertical matches
    for (int col = 0; col < CarmoleGame.gridWidth; col++) {
      for (int row = 0; row <= CarmoleGame.gridHeight - 4; row++) {
        final car = grid[row][col];
        if (car != null) {
          final match = [car];
          for (int i = 1; i < 4; i++) {
            final nextCar = grid[row + i][col];
            if (nextCar != null && nextCar.carColor == car.carColor) {
              match.add(nextCar);
            } else {
              break;
            }
          }
          if (match.length >= 4) {
            matchedCars.addAll(match);
          }
        }
      }
    }

    // Mark matched cars
    for (final car in matchedCars) {
      car.markAsMatched();
    }

    // Clear matched cars after a delay
    if (matchedCars.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        clearMatches();
      });
    }
  }

  void clearMatches() {
    int clearedCars = 0;
    for (int row = 0; row < CarmoleGame.gridHeight; row++) {
      for (int col = 0; col < CarmoleGame.gridWidth; col++) {
        final car = grid[row][col];
        if (car != null && car.isMatched) {
          removeCar(row, col);
          clearedCars++;
        }
      }
    }
    if (clearedCars > 0) {
      game.gameState.carCleared();
      game.gameState.matchCleared(clearedCars);
      
      // Apply gravity with animation after a brief delay
      Future.delayed(const Duration(milliseconds: 100), () {
        applyGravity();
      });
    }
  }

  void clearGrid() {
    for (int row = 0; row < CarmoleGame.gridHeight; row++) {
      for (int col = 0; col < CarmoleGame.gridWidth; col++) {
        removeCar(row, col);
      }
    }
  }

  void applyGravity() {
    final List<Future<void>> animations = [];
    
    for (int col = 0; col < CarmoleGame.gridWidth; col++) {
      for (int row = CarmoleGame.gridHeight - 2; row >= 0; row--) {
        final car = grid[row][col];
        if (car != null) {
          int newRow = row;
          while (newRow < CarmoleGame.gridHeight - 1 &&
                 isCellEmpty(newRow + 1, col)) {
            newRow++;
          }
          if (newRow != row) {
            final targetPos = getCellPosition(newRow, col);
            
            // Update grid references
            grid[row][col] = null;
            grid[newRow][col] = car;
            car.gridRow = newRow;
            car.gridCol = col;
            
            // Create a completer for this animation
            final completer = Completer<void>();
            animations.add(completer.future);
            
            // Animate the fall with staggered timing for cascade effect
            final delay = (CarmoleGame.gridHeight - row) * 0.02; // Stagger by row
            Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
              car.animateFallToPosition(targetPos, onComplete: () {
                completer.complete();
              });
            });
          }
        }
      }
    }
    
    // When all animations complete, check for new matches
    if (animations.isNotEmpty) {
      Future.wait(animations).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          checkForMatches();
        });
      });
    }
  }
}
