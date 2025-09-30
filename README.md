## Carmole Game
A match-3 puzzle game built using Flutter and the Flame game engine. "Carmole" combines the fun of classic block-matching with a unique twist: instead of candies or gems, you drop and combine junkyard cars using a crane!

## 🕹️ What is Carmole?
Carmole is a Flame-based 2D puzzle game inspired by titles like Candy Crush, but with a junkyard theme. A crane drops old cars of different colors onto a grid. If you align 4 or more cars of the same color in a row or column, they are cleared from the board.

## 🚀 Getting Started
1. Project Setup

1.1 Clone the repository or create a new folder:

    cd C:\Users\Colibecas\Documents\Flutter-projects
    flutter create carmole_game
    cd carmole_game

1.2 Install Flame:

    flutter pub add flame

1.3 Update assets in pubspec.yaml:

    flutter:
    uses-material-design: true
    assets:
        - assets/images/

1.4 Create the folders:

    mkdir assets
    mkdir assets\images
    mkdir lib\components
    mkdir lib\game

2. Folder Structure

carmole_game/
├── assets/
│   └── images/
├── lib/
│   ├── components/
│   │   ├── car_component.dart
│   │   ├── crane_component.dart
│   │   └── grid_component.dart
│   ├── game/
│   │   ├── carmole_game.dart
│   │   └── game_state_manager.dart
│   └── main.dart
├── pubspec.yaml
└── README.md

3. Running the Game (Windows Desktop)
Make sure Windows desktop support is enabled:

    flutter config --enable-windows-desktop
    flutter doctor

Run the game:

    flutter run -d windows

## 📝 Code Highlights

Main Game Class:
Launches the Flame game and manages game objects.

Grid Component:
Handles the grid logic and placement of cars.

Car Component:
Defines the appearance and logic for individual cars.

Crane Component:
Simulates the crane that drops cars onto the board.

Game State Manager:
Tracks score, level, matches, and reset functionality.

## main.dart Example

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
    
## 💡 Game Logic Overview

Drop cars with the crane:
Tap anywhere on the game area to drop a new car in the current column.

Create matches:
Align 4 or more cars of the same color vertically or horizontally to clear them.

Gravity:
Cleared cars leave empty spaces; remaining cars fall to fill the gaps.

Score:
Earn points for every cleared car and match.

## 🛠️ Tech Stack
Flutter (UI Framework)

Flame (Lightweight game engine for Flutter)

## 📸 Current Progress
The grid is rendered on the left.

The first car drops (or should drop) by the crane by default.

Tap detection allows dropping additional cars.

## 📚 References & Inspiration
Flame Engine Documentation

Flutter Official Docs

## 📝 TODO
Implement animation for moving the crane left and right

Add collision and match logic for clearing cars

Display score and match counters

Add sound and particle effects

Refine car sprites and visual effects

### * Feel free to contribute, report bugs, or suggest features! *