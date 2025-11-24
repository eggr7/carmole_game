import 'package:flutter/material.dart';
import '../game/carmole_game.dart';

class ModeSelectionDialog extends StatelessWidget {
  const ModeSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2F4F4F), // Dark slate gray
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFF8B4513), // Rust brown
          width: 4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'SELECT GAME MODE',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35), // Safety orange
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Classic Mode Button
            _ModeButton(
              title: 'CLASSIC',
              description: 'Endless gameplay - clear matches and beat your high score!',
              icon: Icons.stars,
              color: Colors.blue,
              onPressed: () => Navigator.of(context).pop(GameMode.classic),
            ),
            
            const SizedBox(height: 20),
            
            // Survival Mode Button
            _ModeButton(
              title: 'SURVIVAL',
              description: 'New rows push up every 3 drops - survive as long as you can!',
              icon: Icons.trending_up,
              color: Colors.red,
              onPressed: () => Navigator.of(context).pop(GameMode.survival),
            ),
            
            const SizedBox(height: 20),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withOpacity(0.3), // Rust brown
            border: Border.all(
              color: color,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

