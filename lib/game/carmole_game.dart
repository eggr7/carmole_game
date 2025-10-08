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
  late CustomButtonComponent leftButton;
  late CustomButtonComponent rightButton;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize camera with fixed resolution and center the view
    camera.viewfinder.anchor = Anchor.center;
    
    // Initialize game components
    gameState = GameStateManager();
    gameGrid = GridComponent();
    crane = CraneComponent();
    
    // Add light background for crane area
    final double gridWidthPixels = CarmoleGame.gridWidth * cellSize;
    final topBackground = RectangleComponent(
      size: Vector2(gridWidthPixels, 100), // Full width, 100px tall
      position: Vector2(-gridWidthPixels / 2, -330),
      paint: Paint()..color = Colors.grey.shade100,
      anchor: Anchor.topLeft,
    );
    world.add(topBackground);
    
    // Add components to the world
    world.add(gameGrid);
    world.add(crane);
    
    // Add score display
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(0, 300),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    world.add(scoreText);
    
    // Add game over display
    gameOverText = TextComponent(
      text: 'Game Over',
      position: Vector2(0, -50),
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
      position: Vector2(0, 50),
      size: Vector2(200, 50),
    )..anchor = Anchor.center;
    
    // Add control buttons below the grid
    final double gridBottomY = (CarmoleGame.gridHeight * cellSize) / 2;
    leftButton = CustomButtonComponent(
      text: '←',
      onPressed: () => crane.moveLeft(),
      position: Vector2(-50, gridBottomY + 60),
      size: Vector2(80, 80),
    )..anchor = Anchor.center;
    world.add(leftButton);
    
    rightButton = CustomButtonComponent(
      text: '→',
      onPressed: () => crane.moveRight(),
      position: Vector2(50, gridBottomY + 60),
      size: Vector2(80, 80),
    )..anchor = Anchor.center;
    world.add(rightButton);
    
    // Start the game
    await _initializeGame();
  }
  
  Future<void> _initializeGame() async {
    // Initialize grid with empty cells
    gameGrid.initializeGrid();
    
    // Position crane at top center of the grid
    crane.position = Vector2(0, -255);
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
