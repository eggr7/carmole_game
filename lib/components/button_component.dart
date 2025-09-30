import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class CustomButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  final String text;

  CustomButtonComponent({
    required this.onPressed,
    required this.text,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final buttonBackground = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    );
    final buttonText = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    );
    add(buttonBackground);
    add(buttonText);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
