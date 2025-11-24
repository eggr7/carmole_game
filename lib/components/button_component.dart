import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class CustomButtonComponent extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  final String text;
  late RectangleComponent buttonBackground;
  late TextComponent buttonText;
  bool isPressed = false;
  bool isEnabled = true;

  CustomButtonComponent({
    required this.onPressed,
    required this.text,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    buttonBackground = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.blue,
    );
    buttonText = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
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
    if (!isEnabled || isPressed) return;
    
    isPressed = true;
    _animatePress();
    onPressed();
    
    // Reset after animation
    Future.delayed(const Duration(milliseconds: 150), () {
      isPressed = false;
    });
  }

  void _animatePress() {
    // Quick squash effect (arcade style)
    add(
      SequenceEffect([
        ScaleEffect.to(
          Vector2.all(0.9), // Squash down
          EffectController(duration: 0.05),
        ),
        ScaleEffect.to(
          Vector2.all(1.05), // Slight bounce back
          EffectController(duration: 0.05),
        ),
        ScaleEffect.to(
          Vector2.all(1.0), // Return to normal
          EffectController(duration: 0.05),
        ),
      ]),
    );
    
    // Color flash on press
    buttonBackground.add(
      ColorEffect(
        Colors.lightBlue,
        EffectController(duration: 0.1),
        opacityFrom: 0.8,
        opacityTo: 0.0,
      ),
    );
  }

  void setEnabled(bool enabled) {
    isEnabled = enabled;
    buttonBackground.paint.color = enabled ? Colors.blue : Colors.grey;
  }
}
