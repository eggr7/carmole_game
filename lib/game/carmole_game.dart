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
import '../components/pause_menu_component.dart';
import 'game_state_manager.dart';
import '../services/leaderboard_service.dart';

class CarmoleGame extends FlameGame with HasCollisionDetection, TapCallbacks, KeyboardHandler {
  static const int gridWidth = 6;
  static const int gridHeight = 8;
  static const double cellSize = 60.0;
  
  final VoidCallback? onReturnToMenu;
  
  late GridComponent gameGrid;
  late CraneComponent crane;
  late GameStateManager gameState;
  late TextComponent scoreText;
  late TextComponent gameOverText;
  TextComponent? finalScoreText;
  TextComponent? topMessageText;
  late CustomButtonComponent restartButton;
  late CustomButtonComponent leftButton;
  late CustomButtonComponent rightButton;
  late CustomButtonComponent nextButton;
  late CustomButtonComponent backButton;
  late CustomButtonComponent menuButton;
  late CustomButtonComponent pauseButton;
  RectangleComponent? leaderboardPanel;
  final List<TextComponent> _leaderboardItems = [];
  bool _gameOverHandled = false;
  bool _showingLeaderboard = false;
  final LeaderboardService _leaderboardService = LeaderboardService();
  List<int>? _cachedScores;
  RectangleComponent? _dimOverlay;
  RectangleComponent? _gameOverPanel;
  int _lastRank = -1;
  PauseMenuComponent? _pauseMenu;
  
  CarmoleGame({this.onReturnToMenu});
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize camera with fixed resolution and center the view
    camera.viewfinder.anchor = Anchor.center;
    
    // Initialize game components
    gameState = GameStateManager();
    gameGrid = GridComponent();
    crane = CraneComponent();
    
    // Background: junkyard image behind the grid and crane
    final double scale = 0.92;
    final double bgW = (CarmoleGame.gridWidth * cellSize + 220) * scale;
    final double bgH = (CarmoleGame.gridHeight * cellSize + 360) * scale;
    final SpriteComponent bg = SpriteComponent(
      sprite: await loadSprite('junkyard_bg.png'),
      size: Vector2(bgW, bgH),
      position: Vector2(-bgW / 2, -bgH / 2),
      anchor: Anchor.topLeft,
    )..priority = -10
     ..opacity = 0.8;
    world.add(bg);
    
    // Add light background for crane area
    final double gridWidthPixels = CarmoleGame.gridWidth * cellSize;
    final topBackground = RectangleComponent(
      size: Vector2(gridWidthPixels, 100), // Full width, 100px tall
      position: Vector2(-gridWidthPixels / 2, -330),
      paint: Paint()..color = Colors.black.withOpacity(0.55),
      anchor: Anchor.topLeft,
    );
    world.add(topBackground);
    
    // Add components to the world
    world.add(gameGrid);
    world.add(crane);
    
    // Add score display next to control buttons
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(-150, (CarmoleGame.gridHeight * cellSize) / 2 + 60), // Left side of control buttons
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    world.add(scoreText);
    
    // Add game over display
    gameOverText = TextComponent(
      text: 'Game Over',
      position: Vector2(0, -140),
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
      position: Vector2(0, 180),
      size: Vector2(200, 50),
    )..anchor = Anchor.center;

    // Add next button (initially unused; shown on Game Over step 1)
    nextButton = CustomButtonComponent(
      text: 'Next',
      onPressed: _showLeaderboard,
      position: Vector2(0, 120),
      size: Vector2(200, 50),
    )..anchor = Anchor.center;

    // Back button used on leaderboard to return to summary
    backButton = CustomButtonComponent(
      text: 'Back',
      onPressed: _showSummary,
      position: Vector2(0, 200),
      size: Vector2(200, 50),
    )..anchor = Anchor.center;

    // Menu button to return to main menu (shown during game over)
    menuButton = CustomButtonComponent(
      text: 'Menu',
      onPressed: () {
        if (onReturnToMenu != null) {
          onReturnToMenu!();
        }
      },
      position: Vector2(0, 220),
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
    
    // Add pause button (top-right corner)
    pauseButton = CustomButtonComponent(
      text: '||',
      onPressed: _togglePause,
      position: Vector2((CarmoleGame.gridWidth * cellSize) / 2 - 45, -(CarmoleGame.gridHeight * cellSize) / 2 + 45),
      size: Vector2(70, 50),
    )..anchor = Anchor.center;
    world.add(pauseButton);
    
    // Start the game
    await _initializeGame();
  }
  
  Future<void> _initializeGame() async {
    // Initialize grid with empty cells
    gameGrid.initializeGrid();
    
    // Position crane at top center of the grid
    crane.position = Vector2(0, -255);
  }
  
  void _togglePause() {
    if (gameState.isGameOver) return;
    
    if (gameState.isPaused) {
      // Resume
      gameState.resumeGame();
      if (_pauseMenu != null) {
        _pauseMenu!.removeFromParent();
        _pauseMenu = null;
      }
    } else {
      // Pause
      gameState.pauseGame();
      _pauseMenu = PauseMenuComponent();
      world.add(_pauseMenu!);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState.isGameOver) {
      if (restartButton.containsPoint(event.localPosition)) {
        restartButton.onPressed.call();
      }
      return;
    }
    if (gameState.isPaused) {
      return; // Ignore input when paused
    }
    super.onTapDown(event);
    // Trigger crane to drop a car
    crane.dropCar();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Don't update game logic when paused
    if (gameState.isPaused) {
      return;
    }
    
    scoreText.text = 'Score: ${gameState.score}';

    if (gameState.isGameOver && !_gameOverHandled) {
      _gameOverHandled = true;
      _handleGameOver();
    }
  }

  void restartGame() {
    gameState.reset();
    gameGrid.clearGrid();
    gameGrid.initializeGrid();
    world.remove(gameOverText);
    world.remove(restartButton);
    if (finalScoreText != null) {
      world.remove(finalScoreText!);
      finalScoreText = null;
    }
    if (topMessageText != null) {
      world.remove(topMessageText!);
      topMessageText = null;
    }
    if (leaderboardPanel != null) {
      world.remove(leaderboardPanel!);
      leaderboardPanel = null;
    }
    if (_gameOverPanel != null) {
      world.remove(_gameOverPanel!);
      _gameOverPanel = null;
    }
    if (_dimOverlay != null) {
      world.remove(_dimOverlay!);
      _dimOverlay = null;
    }
    for (final item in _leaderboardItems) {
      world.remove(item);
    }
    _leaderboardItems.clear();
    if (world.contains(nextButton)) {
      world.remove(nextButton);
    }
    if (world.contains(backButton)) {
      world.remove(backButton);
    }
    if (world.contains(menuButton)) {
      world.remove(menuButton);
    }
    _cachedScores = null;
    _showingLeaderboard = false;
    _gameOverHandled = false;
    
    // Re-enable pause button
    if (world.contains(pauseButton)) {
      pauseButton.setEnabled(true);
    }
    
    // Reset positions for next session
    gameOverText.position = Vector2(0, -140);
    restartButton.position = Vector2(0, 180);
    nextButton.position = Vector2(0, 120);
    backButton.position = Vector2(0, 200);
    _lastRank = -1;
  }

  Future<void> _handleGameOver() async {
    // Hide pause button during game over
    if (world.contains(pauseButton)) {
      pauseButton.setEnabled(false);
    }
    
    // Persist final score and prepare data
    await _leaderboardService.addScore(gameState.score);
    final scores = await _leaderboardService.loadScores();
    _cachedScores = scores;

    // Create dim overlay and panel for contrast
    final double gridWidthPixels = CarmoleGame.gridWidth * cellSize;
    final double gridHeightPixels = CarmoleGame.gridHeight * cellSize;
    _dimOverlay = RectangleComponent(
      size: Vector2(gridWidthPixels + 220, gridHeightPixels + 360),
      position: Vector2(-(gridWidthPixels + 220) / 2, -(gridHeightPixels + 360) / 2),
      paint: Paint()..color = Colors.black.withOpacity(0.4),
      anchor: Anchor.topLeft,
    );
    world.add(_dimOverlay!);

    _gameOverPanel = RectangleComponent(
      size: Vector2(320, 230),
      position: Vector2(-160, -170),
      paint: Paint()..color = Colors.white.withOpacity(0.92),
      anchor: Anchor.topLeft,
    );
    world.add(_gameOverPanel!);

    // Ensure Game Over title and Restart/Next/Menu are visible and positioned
    gameOverText.position = Vector2(0, -120);
    if (!world.contains(gameOverText)) {
      world.add(gameOverText);
    }
    restartButton.position = Vector2(0, 160);
    if (!world.contains(restartButton)) {
      world.add(restartButton);
    }
    nextButton.position = Vector2(0, 100);
    if (!world.contains(nextButton)) {
      world.add(nextButton);
    }
    menuButton.position = Vector2(0, 220);
    if (!world.contains(menuButton) && onReturnToMenu != null) {
      world.add(menuButton);
    }

    // Step 1: show final score and optional top message
    finalScoreText = TextComponent(
      text: 'Score: ${gameState.score}',
      position: Vector2(0, -60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    world.add(finalScoreText!);

    // Compute rank in Top 10 and show message if applicable
    final rank = scores.indexWhere((s) => s == gameState.score);
    _lastRank = rank;
    final inTop = rank >= 0 && rank < 10;
    if (inTop) {
      topMessageText = TextComponent(
        text: 'You made Top #${rank + 1}',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      world.add(topMessageText!);
    }
  }

  Future<void> _showLeaderboard() async {
    if (_showingLeaderboard) return;
    _showingLeaderboard = true;

    // Hide step 1 messages and panel
    if (finalScoreText != null) {
      world.remove(finalScoreText!);
      finalScoreText = null;
    }
    if (topMessageText != null) {
      world.remove(topMessageText!);
      topMessageText = null;
    }
    if (_gameOverPanel != null) {
      world.remove(_gameOverPanel!);
      _gameOverPanel = null;
    }
    if (world.contains(nextButton)) {
      world.remove(nextButton);
    }

    // Keep dim overlay for contrast
    if (_dimOverlay == null) {
      final double gridWidthPixels = CarmoleGame.gridWidth * cellSize;
      final double gridHeightPixels = CarmoleGame.gridHeight * cellSize;
      _dimOverlay = RectangleComponent(
        size: Vector2(gridWidthPixels + 220, gridHeightPixels + 360),
        position: Vector2(-(gridWidthPixels + 220) / 2, -(gridHeightPixels + 360) / 2),
        paint: Paint()..color = Colors.black.withOpacity(0.4),
        anchor: Anchor.topLeft,
      );
      world.add(_dimOverlay!);
    }

    // Draw panel and list the Top 10 scores
    leaderboardPanel = RectangleComponent(
      size: Vector2(320, 300),
      position: Vector2(-160, -120),
      paint: Paint()..color = Colors.white.withOpacity(0.92),
      anchor: Anchor.topLeft,
    );
    world.add(leaderboardPanel!);

    final title = TextComponent(
      text: 'Top 10',
      position: Vector2(0, -100),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 26,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    world.add(title);
    _leaderboardItems.add(title);

    final scores = _cachedScores ?? await _leaderboardService.loadScores();
    const double rowHeight = 24;
    for (int i = 0; i < scores.length && i < 10; i++) {
      final isCurrent = i == _lastRank && _lastRank >= 0;
      final line = TextComponent(
        text: '${i + 1}. ${scores[i]}',
        position: Vector2(0, -70 + i * rowHeight),
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      );
      if (isCurrent) {
        line.textRenderer = TextPaint(
          style: const TextStyle(
            fontSize: 18,
            color: Colors.blue,
            fontWeight: FontWeight.w700,
          ),
        );
      }
      world.add(line);
      _leaderboardItems.add(line);
    }

    // Show Back to allow returning to summary
    backButton.position = Vector2(0, 200);
    if (!world.contains(backButton)) {
      world.add(backButton);
    }

    // Keep restart button visible under panel
    restartButton.position = Vector2(0, 200 + 60);
    if (!world.contains(restartButton)) {
      world.add(restartButton);
    }
  }

  Future<void> _showSummary() async {
    if (!_showingLeaderboard) return;
    _showingLeaderboard = false;

    // Remove leaderboard elements
    if (leaderboardPanel != null) {
      world.remove(leaderboardPanel!);
      leaderboardPanel = null;
    }
    for (final item in _leaderboardItems) {
      world.remove(item);
    }
    _leaderboardItems.clear();
    if (world.contains(backButton)) {
      world.remove(backButton);
    }

    // Recreate summary texts
    final scores = _cachedScores ?? await _leaderboardService.loadScores();
    gameOverText.position = Vector2(0, -120);
    if (!world.contains(gameOverText)) {
      world.add(gameOverText);
    }
    finalScoreText = TextComponent(
      text: 'Score: ${gameState.score}',
      position: Vector2(0, -60),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    world.add(finalScoreText!);

    final rank = scores.indexWhere((s) => s == gameState.score);
    final inTop = rank >= 0 && rank < 10;
    if (inTop) {
      topMessageText = TextComponent(
        text: 'You made Top #${rank + 1}',
        position: Vector2(0, -20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      world.add(topMessageText!);
    }

    // Show Next, Restart, and Menu buttons
    nextButton.position = Vector2(0, 100);
    if (!world.contains(nextButton)) {
      world.add(nextButton);
    }
    restartButton.position = Vector2(0, 160);
    if (!world.contains(restartButton)) {
      world.add(restartButton);
    }
    menuButton.position = Vector2(0, 220);
    if (!world.contains(menuButton) && onReturnToMenu != null) {
      world.add(menuButton);
    }
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
      // ESC key toggles pause
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        _togglePause();
        return true;
      }
      
      // Don't allow game controls when paused
      if (gameState.isPaused) {
        return false;
      }
      
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
