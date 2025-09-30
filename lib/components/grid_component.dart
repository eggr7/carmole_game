import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/carmole_game.dart';
import 'car_component.dart';


class GridComponent extends Component with HasGameReference<CarmoleGame> {
  late List<List<CarComponent?>> grid;
  late RectangleComponent background;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Create grid background
    background = RectangleComponent(
      size: Vector2(
        CarmoleGame.gridWidth * CarmoleGame.cellSize,
        CarmoleGame.gridHeight * CarmoleGame.cellSize,
      ),
      paint: Paint()..color = Colors.grey.shade800,
      position: Vector2.zero(),
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
    // Vertical lines
    for (int i = 0; i <= CarmoleGame.gridWidth; i++) {
      final line = RectangleComponent(
        size: Vector2(2, CarmoleGame.gridHeight * CarmoleGame.cellSize),
        paint: Paint()..color = Colors.white24,
        position: Vector2(i * CarmoleGame.cellSize, 0),
      );
      add(line);
    }
    
    // Horizontal lines
    for (int i = 0; i <= CarmoleGame.gridHeight; i++) {
      final line = RectangleComponent(
        size: Vector2(CarmoleGame.gridWidth * CarmoleGame.cellSize, 2),
        paint: Paint()..color = Colors.white24,
        position: Vector2(0, i * CarmoleGame.cellSize),
      );
      add(line);
    }
  }
  
  Vector2 getCellPosition(int row, int col) {
    return Vector2(
      col * CarmoleGame.cellSize + CarmoleGame.cellSize / 2,
      row * CarmoleGame.cellSize + CarmoleGame.cellSize / 2,
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
  
  void placeCar(CarComponent car, int row, int col) {
    if (isValidPosition(row, col) && isCellEmpty(row, col)) {
      grid[row][col] = car;
      car.gridRow = row;
      car.gridCol = col;
      car.position = getCellPosition(row, col);
      add(car);
    }
  }
  
  void removeCar(int row, int col) {
    if (isValidPosition(row, col) && grid[row][col] != null) {
      final car = grid[row][col]!;
      grid[row][col] = null;
      car.removeFromParent();
    }
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
    }
    applyGravity();
  }

  void clearGrid() {
    for (int row = 0; row < CarmoleGame.gridHeight; row++) {
      for (int col = 0; col < CarmoleGame.gridWidth; col++) {
        removeCar(row, col);
      }
    }
  }

  void applyGravity() {
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
            grid[row][col] = null;
            placeCar(car, newRow, col);
          }
        }
      }
    }
  }
}
