import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/carmole_game.dart';
import 'button_component.dart';

class PauseMenuComponent extends PositionComponent with HasGameReference<CarmoleGame> {
  late RectangleComponent _overlay;
  late RectangleComponent _panel;
  late TextComponent _titleText;
  late CustomButtonComponent _resumeButton;
  late CustomButtonComponent _restartButton;
  late CustomButtonComponent _menuButton;

  PauseMenuComponent() : super(priority: 1000); // High priority to render on top

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final double gridWidthPixels = CarmoleGame.gridWidth * CarmoleGame.cellSize;
    final double gridHeightPixels = CarmoleGame.gridHeight * CarmoleGame.cellSize;

    // Semi-transparent overlay
    _overlay = RectangleComponent(
      size: Vector2(gridWidthPixels + 220, gridHeightPixels + 360),
      position: Vector2(-(gridWidthPixels + 220) / 2, -(gridHeightPixels + 360) / 2),
      paint: Paint()..color = Colors.black.withOpacity(0.7),
      anchor: Anchor.topLeft,
    );
    add(_overlay);

    // Menu panel background
    _panel = RectangleComponent(
      size: Vector2(340, 340),
      position: Vector2(-170, -170),
      paint: Paint()..color = const Color(0xFF2F4F4F).withOpacity(0.95),
      anchor: Anchor.topLeft,
    );
    add(_panel);
    
    // Add border as separate component
    final border = RectangleComponent(
      size: Vector2(340, 340),
      position: Vector2(-170, -170),
      paint: Paint()
        ..color = const Color(0xFFFF6B35).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
      anchor: Anchor.topLeft,
    );
    add(border);

    // Title
    _titleText = TextComponent(
      text: 'GAME PAUSED',
      position: Vector2(0, -130),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 38,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
    add(_titleText);

    // Resume button
    _resumeButton = CustomButtonComponent(
      text: 'Resume',
      onPressed: _handleResume,
      position: Vector2(0, -50),
      size: Vector2(240, 60),
    )..anchor = Anchor.center;
    add(_resumeButton);

    // Restart button
    _restartButton = CustomButtonComponent(
      text: 'Restart',
      onPressed: _handleRestart,
      position: Vector2(0, 30),
      size: Vector2(240, 60),
    )..anchor = Anchor.center;
    add(_restartButton);

    // Main Menu button
    _menuButton = CustomButtonComponent(
      text: 'Main Menu',
      onPressed: _handleMainMenu,
      position: Vector2(0, 110),
      size: Vector2(240, 60),
    )..anchor = Anchor.center;
    add(_menuButton);
  }

  void _handleResume() {
    game.gameState.resumeGame();
    removeFromParent();
  }

  void _handleRestart() {
    game.gameState.resumeGame(); // Unpause first
    removeFromParent();
    game.restartGame();
  }

  void _handleMainMenu() {
    if (game.onReturnToMenu != null) {
      game.gameState.resumeGame(); // Unpause first
      removeFromParent();
      game.onReturnToMenu!();
    }
  }
}

