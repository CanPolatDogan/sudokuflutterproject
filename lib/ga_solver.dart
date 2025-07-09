import 'dart:math';
import 'package:flutter/foundation.dart';

// Genetik Algoritma Çözümleyici
class GeneticAlgorithmSolver {
  final List<List<int>> puzzle;
  final int populationSize;
  final int maxGenerations;
  final double mutationRate;
  final Random _random = Random();

  GeneticAlgorithmSolver({
    required this.puzzle,
    this.populationSize = 100, // Popülasyon boyutumuz.
    this.maxGenerations = 2000, // Maksimum nesil boyutumuz.
    this.mutationRate =
        0.15, // Mutasyon değeri, bu değerler bizim algoritmamızın sonucunu ve sonuca ulaşma hızımızı etkiler.
  });

  List<List<int>> solve() {
    List<List<List<int>>> population = _initializePopulation();
    int bestFitness = 0; // en iyi fitness değerimiz.
    int stagnantGenerations = 0;

    for (int generation = 0; generation < maxGenerations; generation++) {
      population.sort((a, b) => _fitness(b).compareTo(_fitness(a)));

      int currentBest = _fitness(population.first);

      if (currentBest > bestFitness) {
        bestFitness = currentBest;
        stagnantGenerations = 0;
        debugPrint("Nesil $generation: En iyi puan = $bestFitness");

        // İlerleme kontrolü yapıyoruz.
        if (bestFitness >= 200) {
          debugPrint("Fitness 200 üstü Puan: $bestFitness/243");
        }
      } else {
        stagnantGenerations++;
      }

      // Çözüm bulundu mu kontrol ediyoruz.
      if (bestFitness == 243) {
        debugPrint("Çözüm bulundu Nesil: $generation");
        break;
      }

      // Durgunluk varsa popülasyonu yeniliyloruz.
      if (stagnantGenerations > 100) {
        debugPrint("Durgunluk tespit edildi, popülasyon yenileniyor");
        var bestIndividuals = <List<List<int>>>[];

        // En iyi 5'i koruyoruz.
        for (int i = 0; i < min(5, population.length); i++) {
          bestIndividuals.add(
            List.generate(9, (row) => List<int>.from(population[i][row])),
          );
        }

        population = _initializePopulation();

        // En iyileri yeni popülasyona ekliyoruz ve genetik algoritma döngüsünü yeniden başlatıyoruz.
        for (int i = 0; i < bestIndividuals.length; i++) {
          population[i] = bestIndividuals[i];
        }

        stagnantGenerations = 0;
      }

      List<List<List<int>>> newPopulation = [];

      // Elitizm eklendi: En iyi %15 korundu.
      int eliteCount = (populationSize * 0.15).round();
      for (int i = 0; i < eliteCount; i++) {
        newPopulation.add(
          List.generate(9, (row) => List<int>.from(population[i][row])),
        );
      }

      // Yeni bireyler üretiyoruz ve mutasyon uyguluyoruz.
      while (newPopulation.length < populationSize) {
        var parent1 = _tournamentSelect(population);
        var parent2 = _tournamentSelect(population);
        var child = _improvedCrossover(parent1, parent2);
        _improvedMutate(child);
        newPopulation.add(child);
      }

      population = newPopulation;
    }

    return population.first;
  }

  List<List<List<int>>> _initializePopulation() {
    List<List<List<int>>> population = [];

    for (int p = 0; p < populationSize; p++) {
      List<List<int>> individual = _createValidIndividual();
      population.add(individual);
    }

    return population;
  }

  List<List<int>> _createValidIndividual() {
    List<List<int>> board = List.generate(9, (i) => List.from(puzzle[i]));

    // Her satır için eksik sayıları doldurmaya başladık.
    for (int row = 0; row < 9; row++) {
      List<int> available = [];
      for (int num = 1; num <= 9; num++) {
        if (!board[row].contains(num)) {
          available.add(num);
        }
      }

      available.shuffle(_random);
      int availableIndex = 0;

      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          board[row][col] = available[availableIndex++];
        }
      }
    }

    // Yerel optimizasyon uyguluyoruz.
    _localOptimization(board);

    return board;
  }

  void _localOptimization(List<List<int>> board) {
    for (int attempt = 0; attempt < 20; attempt++) {
      bool improved = false;

      for (int row = 0; row < 9; row++) {
        List<int> mutablePositions = [];
        for (int col = 0; col < 9; col++) {
          if (puzzle[row][col] == 0) {
            mutablePositions.add(col);
          }
        }

        if (mutablePositions.length >= 2) {
          for (int i = 0; i < mutablePositions.length - 1; i++) {
            for (int j = i + 1; j < mutablePositions.length; j++) {
              int pos1 = mutablePositions[i];
              int pos2 = mutablePositions[j];

              int currentFitness = _fitness(board);

              // Değiştirme işlemimiz.
              int temp = board[row][pos1];
              board[row][pos1] = board[row][pos2];
              board[row][pos2] = temp;

              // İyileştirme var mı kontrol ediyoruz.
              if (_fitness(board) > currentFitness) {
                improved = true;
                break;
              } else {
                // Geri alıyoruz.
                board[row][pos2] = board[row][pos1];
                board[row][pos1] = temp;
              }
            }
            if (improved) break;
          }
        }
        if (improved) break;
      }

      if (!improved) break;
    }
  }

  int _fitness(List<List<int>> board) {
    int score = 0;
    score += 81; // 9 satır × 9 benzersiz sayı sudoku kuralımız geçerli.

    // Sütunlar için puanlarımız.
    for (int col = 0; col < 9; col++) {
      Set<int> uniqueNumbers = {};
      for (int row = 0; row < 9; row++) {
        uniqueNumbers.add(board[row][col]);
      }
      score += uniqueNumbers.length;
    }

    // 3x3 bloklar için ayrı puanlarımız.
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

  List<List<int>> _tournamentSelect(List<List<List<int>>> population) {
    int tournamentSize =
        5; // Turnuva boyutumuz ve bu turnuvadan en iyi bireyi seçme fonksiyonumuz.
    List<List<int>> best = population[_random.nextInt(population.length)];
    int bestFitness = _fitness(best);

    for (int i = 1; i < tournamentSize; i++) {
      var candidate = population[_random.nextInt(population.length)];
      int candidateFitness = _fitness(candidate);
      if (candidateFitness > bestFitness) {
        best = candidate;
        bestFitness = candidateFitness;
      }
    }

    return best;
  }

  // Çaprazlama fonksiyonumuz.
  List<List<int>> _improvedCrossover(
    List<List<int>> parent1,
    List<List<int>> parent2,
  ) {
    List<List<int>> child = List.generate(9, (i) => List.filled(9, 0));

    // Sabit hücreleri kopyalıyoruz.
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] != 0) {
          child[row][col] = puzzle[row][col];
        }
      }
    }

    // Her satır için çaprazlama yapıyoruz.
    for (int row = 0; row < 9; row++) {
      // Bu satırda hangi sayılar eksik onu kontrol ediyoruz.
      List<int> availableNumbers = [];
      for (int num = 1; num <= 9; num++) {
        bool isFixed = false;
        for (int col = 0; col < 9; col++) {
          if (puzzle[row][col] == num) {
            isFixed = true;
            break;
          }
        }
        if (!isFixed) {
          availableNumbers.add(num);
        }
      }

      // Boş pozisyonları buluyoruz.
      List<int> emptyPositions = [];
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0) {
          emptyPositions.add(col);
        }
      }

      // Ebeveynlerden sayıları seçiyoruz.
      availableNumbers.shuffle(_random);

      // Rastgele bir ebeveynden başlıyoruz ve diğeriyle karıştırıyoruz.
      List<int> numbersToAssign = List.from(availableNumbers);

      // %50 şansla parent1'den, %50 şansla parent2'den sayıları alıyoruz.
      for (int i = 0; i < emptyPositions.length; i++) {
        int col = emptyPositions[i];

        if (_random.nextBool()) {
          // Parent1'den değeri almayı dene.
          int value = parent1[row][col];
          if (numbersToAssign.contains(value)) {
            child[row][col] = value;
            numbersToAssign.remove(value);
          }
        } else {
          // Parent2'den değeri almayı dene.
          int value = parent2[row][col];
          if (numbersToAssign.contains(value)) {
            child[row][col] = value;
            numbersToAssign.remove(value);
          }
        }
      }

      // Kalan sayıları rastgele boş pozisyonlara atıyoruz.
      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0 && child[row][col] == 0) {
          if (numbersToAssign.isNotEmpty) {
            child[row][col] = numbersToAssign.removeAt(0);
          }
        }
      }
    }

    return child;
  }

  void _improvedMutate(List<List<int>> board) {
    // Sütun bazlı Mutasyon işlemlerimizi burada yapıyoruz.
    if (_random.nextDouble() < mutationRate) {
      int row = _random.nextInt(9);
      List<int> mutableCols = [];

      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0) {
          mutableCols.add(col);
        }
      }

      if (mutableCols.length >= 2) {
        mutableCols.shuffle(_random);
        int col1 = mutableCols[0];
        int col2 = mutableCols[1];

        // Değişim yapıyoruz.
        int temp = board[row][col1];
        board[row][col1] = board[row][col2];
        board[row][col2] = temp;
      }
    }

    // Blok bazlı Mutasyon işlemlerimizi burada yapıyoruz.
    if (_random.nextDouble() < mutationRate * 0.5) {
      // Daha az sıklıkta
      int blockRow = _random.nextInt(3);
      int blockCol = _random.nextInt(3);

      List<Point<int>> mutableCells = [];
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          int actualRow = blockRow * 3 + row;
          int actualCol = blockCol * 3 + col;
          if (puzzle[actualRow][actualCol] == 0) {
            mutableCells.add(Point(actualRow, actualCol));
          }
        }
      }

      if (mutableCells.length >= 2) {
        mutableCells.shuffle(_random);
        var cell1 = mutableCells[0];
        var cell2 = mutableCells[1];

        // Değişim yapıyoruz.
        int temp = board[cell1.x][cell1.y];
        board[cell1.x][cell1.y] = board[cell2.x][cell2.y];
        board[cell2.x][cell2.y] = temp;
      }
    }

    // Adaptif mutasyon işlemlerimiz burada, düşük fitness için daha agresif olacak şekilde.
    int currentFitness = _fitness(board);
    if (currentFitness < 200 && _random.nextDouble() < 0.1) {
      // Rastgele bir satırda daha fazla karıştırma yapıyoruz.
      int row = _random.nextInt(9);
      List<int> mutableCols = [];

      for (int col = 0; col < 9; col++) {
        if (puzzle[row][col] == 0) {
          mutableCols.add(col);
        }
      }

      // Tüm mutasyonlanabilir pozisyonları karıştırıyoruz.
      mutableCols.shuffle(_random);
      List<int> values = [];
      for (int col in mutableCols) {
        values.add(board[row][col]);
      }
      values.shuffle(_random);

      for (int i = 0; i < mutableCols.length; i++) {
        board[row][mutableCols[i]] = values[i];
      }
    }
  }

  bool isValidSolution(List<List<int>> board) {
    return _fitness(board) == 243;
  }

  // Çözümü yazdırma yardımcı fonksiyonumuz.
  void printBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      if (row % 3 == 0 && row != 0) {
        debugPrint("------+-------+------");
      }
      String line = "";
      for (int col = 0; col < 9; col++) {
        if (col % 3 == 0 && col != 0) {
          line += "| ";
        }
        line += "${board[row][col]} ";
      }
      debugPrint(line);
    }
  }
}

class Point<T> {
  final T x, y;
  Point(this.x, this.y);
}
