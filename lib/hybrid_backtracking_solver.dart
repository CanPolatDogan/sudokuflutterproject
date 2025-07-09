import 'package:flutter/foundation.dart';
import 'ga_solver.dart';

// Saf Backtracking Çözümleyici
class PureBacktrackingSolver {
  final List<List<int>> puzzle;
  late List<List<int>> board;
  int _attempts = 0;
  int _maxAttempts = 1000000;

  PureBacktrackingSolver({required this.puzzle}) {
    board = List.generate(9, (i) => List.from(puzzle[i]));
  }

  List<List<int>> solve() {
    _attempts = 0;
    debugPrint("Saf Backtracking çözümü başlatılıyor");

    if (_solveRecursive()) {
      debugPrint("Backtracking ile çözüm bulundu. Deneme sayısı: $_attempts");
      return board;
    } else {
      debugPrint("Backtracking $_attempts denemede çözüm bulamadı");
      return board; // Kısmi çözümü döndürdük.
    }
  }

  bool _solveRecursive() {
    _attempts++;

    if (_attempts > _maxAttempts) {
      return false;
    }

    // İlk boş hücreyi buluyoruz.
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          // 1'den 9'a kadar deniyoruz.
          for (int num = 1; num <= 9; num++) {
            if (_isValidMove(row, col, num)) {
              board[row][col] = num;

              if (_solveRecursive()) {
                return true;
              }

              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }

    return true;
  }

  bool _isValidMove(int row, int col, int num) {
    // Satır kontrolümüz.
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }

    // Sütun kontrolümüz.
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }

    // 3x3 blok kontrolümüz.
    int blockRow = (row ~/ 3) * 3;
    int blockCol = (col ~/ 3) * 3;

    for (int r = blockRow; r < blockRow + 3; r++) {
      for (int c = blockCol; c < blockCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }

    return true;
  }

  List<List<int>>? quickSolve({int maxAttempts = 50000}) {
    _attempts = 0;
    _maxAttempts = maxAttempts;
    board = List.generate(9, (i) => List.from(puzzle[i]));

    if (_solveRecursive()) {
      return board;
    }
    return null;
  }
}

// Hibrit Çözümleyici (Genetik Algoritma + Saf Backtracking)
class HybridSudokuSolver {
  final List<List<int>> puzzle;
  final int geneticGenerations;
  final int geneticPopulationSize;

  HybridSudokuSolver({
    required this.puzzle,
    this.geneticGenerations =
        500, // Normal genetik algoritmaya göre daha küçük nesil ve popülasyon büyüklüğü ayarlıyoruz.
    this.geneticPopulationSize = 25,
  });

  List<List<int>> solve() {
    debugPrint("1. Aşama: Genetik Algoritma ile ön işleme");

    // 1. Aşama: Genetik algoritma ile iyi bir başlangıç noktası buluyoruz.
    final geneticSolver = GeneticAlgorithmSolver(
      puzzle: puzzle,
      populationSize: geneticPopulationSize,
      maxGenerations: geneticGenerations,
      mutationRate: 0.15,
    );

    List<List<int>> geneticResult = geneticSolver.solve();
    int geneticFitness = _calculateFitness(geneticResult);

    debugPrint(
      "Genetik algoritma tamamlandı. En iyi fitness: $geneticFitness/243",
    );

    // Genetik algoritma tam çözümü buldu mu kontrol ediyoruz.
    if (geneticFitness == 243 && _isValidSolution(geneticResult)) {
      debugPrint("Genetik algoritma tam çözümü buldu.");
      return geneticResult;
    }

    // 2. Aşama: Genetik sonucunu saf backtracking için başlangıç olarak kullanıyoruz.
    debugPrint("2. Aşama: Saf Backtracking ile tamamlama");

    List<List<int>>? finalResult = _completeWithBacktracking(geneticResult);

    if (finalResult != null && _isValidSolution(finalResult)) {
      debugPrint("Hibrit çözüm başarılı, Tam çözüm bulundu.");
      return finalResult;
    }

    // 3. Aşama: Eğer hibrit başarısız olduysa son çare olarak, saf backtracking deniyoruz.
    debugPrint("3. Aşama: Saf backtracking denemesi");
    final backtrackingSolver = PureBacktrackingSolver(puzzle: puzzle);
    List<List<int>>? backtrackingResult = backtrackingSolver.quickSolve(
      maxAttempts: 150000,
    );

    if (backtrackingResult != null && _isValidSolution(backtrackingResult)) {
      debugPrint("Saf backtracking başarılı.");
      return backtrackingResult;
    }

    debugPrint("Tüm yöntemler başarısız, en iyi genetik sonucu döndürülüyor.");
    return geneticResult;
  }

  List<List<int>>? _completeWithBacktracking(List<List<int>> partialSolution) {
    // Genetik çözümü backtracking için hazırlıyoruz.
    List<List<int>> workingBoard = List.generate(
      9,
      (i) => List.from(partialSolution[i]),
    );

    // En problemli hücreleri belirliyoruz ve sıfırlıyoruz.
    int resetCount = _resetProblematicCells(workingBoard);
    debugPrint("$resetCount hücre sıfırlandı ve backtracking'e bırakıldı");

    // Eğer çok az hücre kaldıysa, backtracking ile tamamlıyoruz.
    if (resetCount <= 30) {
      final backtrackingSolver = PureBacktrackingSolver(puzzle: workingBoard);
      return backtrackingSolver.quickSolve(maxAttempts: 200000);
    }

    return null;
  }

  int _resetProblematicCells(List<List<int>> board) {
    int resetCount = 0;
    const maxResets = 25;

    // Sütun çakışmalarını düzeltiyoruz.
    for (int col = 0; col < 9 && resetCount < maxResets; col++) {
      Map<int, List<int>> occurrences = {};

      for (int row = 0; row < 9; row++) {
        if (puzzle[row][col] == 0) {
          int value = board[row][col];
          if (value > 0) {
            occurrences[value] ??= [];
            occurrences[value]!.add(row);
          }
        }
      }

      occurrences.forEach((value, rows) {
        if (rows.length > 1) {
          for (int i = 1; i < rows.length && resetCount < maxResets; i++) {
            board[rows[i]][col] = 0;
            resetCount++;
          }
        }
      });
    }

    // 3x3 blok çakışmalarını düzeltiyoruz.
    for (int blockRow = 0; blockRow < 3 && resetCount < maxResets; blockRow++) {
      for (
        int blockCol = 0;
        blockCol < 3 && resetCount < maxResets;
        blockCol++
      ) {
        Map<int, List<List<int>>> occurrences = {};

        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            int actualRow = blockRow * 3 + row;
            int actualCol = blockCol * 3 + col;

            if (puzzle[actualRow][actualCol] == 0) {
              int value = board[actualRow][actualCol];
              if (value > 0) {
                occurrences[value] ??= [];
                occurrences[value]!.add([actualRow, actualCol]);
              }
            }
          }
        }

        occurrences.forEach((value, positions) {
          if (positions.length > 1) {
            for (
              int i = 1;
              i < positions.length && resetCount < maxResets;
              i++
            ) {
              board[positions[i][0]][positions[i][1]] = 0;
              resetCount++;
            }
          }
        });
      }
    }

    return resetCount;
  }

  int _calculateFitness(List<List<int>> board) {
    int score = 0;

    // Satırlar için puanımız.
    score += 81;

    // Sütunlar için puanımız.
    for (int col = 0; col < 9; col++) {
      Set<int> uniqueNumbers = {};
      for (int row = 0; row < 9; row++) {
        uniqueNumbers.add(board[row][col]);
      }
      score += uniqueNumbers.length;
    }

    // 3x3 bloklar için puanımız.
    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        Set<int> uniqueNumbers = {};
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            uniqueNumbers.add(board[blockRow * 3 + row][blockCol * 3 + col]);
          }
        }
        score += uniqueNumbers.length;
      }
    }

    return score;
  }

  bool _isValidSolution(List<List<int>> board) {
    // Satır kontrolümüz.
    for (int row = 0; row < 9; row++) {
      Set<int> seen = {};
      for (int col = 0; col < 9; col++) {
        int value = board[row][col];
        if (value < 1 || value > 9 || seen.contains(value)) {
          return false;
        }
        seen.add(value);
      }
    }

    // Sütun kontrolümüz.
    for (int col = 0; col < 9; col++) {
      Set<int> seen = {};
      for (int row = 0; row < 9; row++) {
        int value = board[row][col];
        if (seen.contains(value)) {
          return false;
        }
        seen.add(value);
      }
    }

    // 3x3 blok kontrolümüz.
    for (int blockRow = 0; blockRow < 3; blockRow++) {
      for (int blockCol = 0; blockCol < 3; blockCol++) {
        Set<int> seen = {};
        for (int row = 0; row < 3; row++) {
          for (int col = 0; col < 3; col++) {
            int value = board[blockRow * 3 + row][blockCol * 3 + col];
            if (seen.contains(value)) {
              return false;
            }
            seen.add(value);
          }
        }
      }
    }

    return true;
  }
}
