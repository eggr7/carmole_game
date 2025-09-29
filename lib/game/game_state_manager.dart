class GameStateManager {
  int score = 0;
  int level = 1;
  int carsCleared = 0;
  bool isGameOver = false;
  
  void addScore(int points) {
    score += points;
    
    // Level up every 100 points
    if (score >= level * 100) {
      level++;
    }
  }
  
  void carCleared() {
    carsCleared++;
    addScore(10); // 10 points per car
  }
  
  void matchCleared(int matchSize) {
    // Bonus points for larger matches
    int bonus = (matchSize - 4) * 5;
    addScore(50 + bonus);
  }
  
  void reset() {
    score = 0;
    level = 1;
    carsCleared = 0;
    isGameOver = false;
  }
}
