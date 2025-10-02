import 'dart:async';
// import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// import our components and game state manager
import '../components/grid_component.dart';
import '../components/crane_component.dart';
import '../components/button_component.dart';
import 'game_state_manager.dart';

class CarmoleGame extends FlameGame with HasCollisionDetection, TapCallbacks, KeyboardHandler {
  static const int gridWidth = 6;
  static const int gridHeight = 8;
  static const double cellSize = 60.0;
  
  late GridComponent gameGrid;
  late CraneComponent crane;
  late GameStateManager gameState;
  late TextComponent scoreText;
  late TextComponent gameOverText;
  late CustomButtonComponent restartButton;
  
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
    
    // Add score display
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
    );
    world.add(scoreText);
    
    // Add game over display
    gameOverText = TextComponent(
      text: 'Game Over',
      position: Vector2(size.x / 2, size.y / 2 - 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    
    // Add restart button
    restartButton = CustomButtonComponent(
      text: 'Restart',
      onPressed: restartGame,
      position: Vector2(size.x / 2, size.y / 2 + 50),
      size: Vector2(200, 50),
    )..anchor = Anchor.center;
    
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
    if (gameState.isGameOver) {
      if (restartButton.containsPoint(event.localPosition)) {
        restartButton.onPressed.call();
      }
      return;
    }
    super.onTapDown(event);
    // Trigger crane to drop a car
    crane.dropCar();
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'Score: ${gameState.score}';

    if (gameState.isGameOver) {
      if (!world.contains(gameOverText)) {
        world.add(gameOverText);
        world.add(restartButton);
      }
    }
  }

  void restartGame() {
    gameState.reset();
    gameGrid.clearGrid();
    gameGrid.initializeGrid();
    world.remove(gameOverText);
    world.remove(restartButton);
  }

  @override
  bool onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (gameState.isGameOver) {
      return false;
    }
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        crane.moveLeft();
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        crane.moveRight();
        return true;
      }
    }
    return false;
  }
}
