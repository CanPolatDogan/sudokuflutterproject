import 'dart:math';

// Sudoku işlemlerimiz burada, tahtayı kurallara uygun şekilde 20-50 arasında dolduruyoruz, temizliyoruz, sudoku kontrollerimiz yapıyoruz vs.
class SudokuGenerator {
  List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
  final Random random = Random();

  bool isSafe(int row, int col, int num) {
    for (int x = 0; x < 9; x++) {
      if (board[row][x] == num) return false;
    }
    for (int y = 0; y < 9; y++) {
      if (board[y][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  bool fillBoard() {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = List.generate(9, (index) => index + 1);
          numbers.shuffle(random);

          for (int num in numbers) {
            if (isSafe(row, col, num)) {
              board[row][col] = num;

              if (fillBoard()) {
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

  void clearBoard() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        board[i][j] = 0;
      }
    }
  }

  // Yeni puzzle oluşturuyoruz, 20-50 arası hücre dolu olacak şekilde.
  bool generatePuzzle({int minFilled = 20, int maxFilled = 50}) {
    clearBoard();
    bool success = fillBoard();
    if (!success) return false;

    int totalCells = 81;
    int filledCells = minFilled + random.nextInt(maxFilled - minFilled + 1);
    int cellsToClear = totalCells - filledCells;

    List<int> positions = List.generate(totalCells, (index) => index);
    positions.shuffle(random);

    for (int i = 0; i < cellsToClear; i++) {
      int pos = positions[i];
      int row = pos ~/ 9;
      int col = pos % 9;
      board[row][col] = 0;
    }

    return true;
  }
}

// Sudoku doğrulama işlemleri için ayrı sınıf oluşturuyoruz.
class SudokuValidator {
  
  // String tabanlı Sudoku doğrulamamız. Kullanıcın çözdüğü sudoku için.
  static bool isValidSudoku(List<List<String>> board) {
    List<Set<String>> rows = List.generate(9, (index) => <String>{});
    List<Set<String>> cols = List.generate(9, (index) => <String>{});
    List<Set<String>> blocks = List.generate(9, (index) => <String>{});

    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        String val = board[i][j];
        if (val.isEmpty || val == '0') continue;
        if (!RegExp(r'^[1-9]$').hasMatch(val)) return false;
        if (rows[i].contains(val) || cols[j].contains(val)) return false;

        int blockIndex = (i ~/ 3) * 3 + (j ~/ 3);
        if (blocks[blockIndex].contains(val)) return false;

        rows[i].add(val);
        cols[j].add(val);
        blocks[blockIndex].add(val);
      }
    }
    return true;
  }

  // Sayı tabanlı Sudoku doğrulamamız. AI'ın çözdüğü sudoku için.
  static bool isValidSudokuInt(List<List<int>> board) {
    if (board.length != 9 || board.any((row) => row.length != 9)) {
      return false;
    }

    // Tüm hücrelerin 1-9 arasında olduğunu kontrol ediyoruz.
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (board[i][j] < 1 || board[i][j] > 9) {
          return false;
        }
      }
    }

    // Satır kontrolümüz.
    for (int i = 0; i < 9; i++) {
      Set<int> rowSet = board[i].toSet();
      if (rowSet.length != 9) return false;
    }

    // Sütun kontrolümüz.
    for (int j = 0; j < 9; j++) {
      Set<int> colSet = {};
      for (int i = 0; i < 9; i++) {
        colSet.add(board[i][j]);
      }
      if (colSet.length != 9) return false;
    }

    // 3x3 kutu kontrolümüz.
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        Set<int> boxSet = {};
        for (int i = boxRow * 3; i < (boxRow + 1) * 3; i++) {
          for (int j = boxCol * 3; j < (boxCol + 1) * 3; j++) {
            boxSet.add(board[i][j]);
          }
        }
        if (boxSet.length != 9) return false;
      }
    }

    return true;
  }

  // Boş hücre kontrolümüz.
  static bool hasEmptyCells(List<List<String>> board) {
    for (var row in board) {
      for (var cell in row) {
        if (cell.isEmpty || cell.trim().isEmpty) {
          return true;
        }
      }
    }
    return false;
  }

  // Sayı tabanlı boş hücre kontrolümüz.
  static bool hasEmptyCellsInt(List<List<int>> board) {
    for (var row in board) {
      if (row.contains(0)) {
        return true;
      }
    }
    return false;
  }

  // Sudoku tamamlanmış mı kontrolümüz. Doluluk kontrolü yani.
  static bool isCompleteSudoku(List<List<String>> board) {
    return !hasEmptyCells(board) && isValidSudoku(board);
  }

  // Sayı tabanlı tamamlanma kontrolümüz.
  static bool isCompleteSudokuInt(List<List<int>> board) {
    return !hasEmptyCellsInt(board) && isValidSudokuInt(board);
  }

  // String board'u int board'a çevirme işlemimiz.
  static List<List<int>>? stringToIntBoard(List<List<String>> stringBoard) {
    try {
      return List.generate(9, (i) {
        return List.generate(9, (j) {
          String text = stringBoard[i][j].trim();
          return text.isEmpty ? 0 : int.tryParse(text) ?? 0;
        });
      });
    } catch (e) {
      return null;
    }
  }

  // Int board'u string board'a çevirme işlemimiz.
  static List<List<String>> intToStringBoard(List<List<int>> intBoard) {
    return intBoard.map((row) => 
      row.map((cell) => cell == 0 ? '' : cell.toString()).toList()
    ).toList();
  }
}

// Saf Backtracking çözümü, Kullanıcının çözdüğü sudoku için AI destekle kontrol bölümümüz.
class SimpleSudokuSolver { 
  static bool solveSudoku(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValidMove(board, row, col, num)) {
              board[row][col] = num;
              if (solveSudoku(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool isValidMove(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num) return false;
    }

    for (int i = 0; i < 9; i++) {
      if (board[i][col] == num) return false;
    }

    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // Sudoku'nun çözülebilir olup olmadığını kontrol ediyoruz.
  static bool isSolvable(List<List<int>> board) {
    List<List<int>> boardCopy = board.map((row) => List<int>.from(row)).toList();
    return solveSudoku(boardCopy);
  }
}