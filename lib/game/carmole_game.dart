import 'dart:async';
// import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
// import 'package:flutter/material.dart';

// Import our custom components (we'll create these files next)
import '../components/grid_component.dart';
import '../components/crane_component.dart';
import 'game_state_manager.dart';

class CarmoleGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  static const int gridWidth = 6;
  static const int gridHeight = 8;
  static const double cellSize = 60.0;
  
  late GridComponent gameGrid;
  late CraneComponent crane;
  late GameStateManager gameState;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize camera with fixed resolution
    camera.viewfinder.anchor = Anchor.topLeft;
    
    // Initialize game components
    gameState = GameStateManager();
    gameGrid = GridComponent();
    crane = CraneComponent();
    
    // Add components to the world
    world.add(gameGrid);
    world.add(crane);
    
    // Start the game
    await _initializeGame();
  }
  
  Future<void> _initializeGame() async {
    // Initialize grid with empty cells
    gameGrid.initializeGrid();
    
    // Position crane at top center
    crane.position = Vector2(
      (gridWidth * cellSize) / 2 - 30,
      -100
    );
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    // Trigger crane to drop a car
    crane.dropCar();
  }
}
