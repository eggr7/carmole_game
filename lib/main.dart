import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/carmole_game.dart';

void main() {
  runApp(
    GameWidget(
      game: CarmoleGame(),
    ),
  );
}