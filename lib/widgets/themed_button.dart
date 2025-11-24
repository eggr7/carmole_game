import 'package:flutter/material.dart';

class ThemedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool isPrimary;

  const ThemedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = 250,
    this.height = 60,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  State<ThemedButton> createState() => _ThemedButtonState();
}

class _ThemedButtonState extends State<ThemedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF8B4513); // Rust brown
    final secondaryColor = const Color(0xFF2F4F4F); // Dark slate gray
    final accentColor = const Color(0xFFFF6B35); // Safety orange

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isPrimary
                  ? [
                      _isPressed ? primaryColor.withOpacity(0.7) : primaryColor,
                      _isPressed
                          ? primaryColor.withOpacity(0.5)
                          : primaryColor.withOpacity(0.8),
                    ]
                  : [
                      _isPressed
                          ? secondaryColor.withOpacity(0.7)
                          : secondaryColor,
                      _isPressed
                          ? secondaryColor.withOpacity(0.5)
                          : secondaryColor.withOpacity(0.8),
                    ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isPressed
                  ? accentColor.withOpacity(0.5)
                  : accentColor.withOpacity(0.8),
              width: 3,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

