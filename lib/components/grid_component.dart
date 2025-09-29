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
}
