import 'package:flutter/material.dart';
import '../ga_solver.dart';
import '../sudoku_operations.dart';
import '../hybrid_backtracking_solver.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/action_buttons.dart';
import '../widgets/solver_buttons.dart';
import '../widgets/solve_by_user_button.dart';
import '../widgets/feedback_link.dart';

class AISudokuScreen extends StatelessWidget {
  AISudokuScreen({super.key});

  final List<List<TextEditingController>> controllers = List.generate(
    9,
    (_) => List.generate(9, (_) => TextEditingController()),
  );

  List<List<int>> _getCurrentPuzzle() {
    return List.generate(9, (i) {
      return List.generate(9, (j) {
        final text = controllers[i][j].text;
        return int.tryParse(text) ?? 0;
      });
    });
  }

  // Generik Algoritma ile sudokuyu çözüyoruz.
  void solveSudoku(BuildContext context) {
    try {
      final puzzle = _getCurrentPuzzle();
      final solver = GeneticAlgorithmSolver(puzzle: puzzle);
      final solution = solver.solve();

      // Çözüm kontrolü yapıyoruz. sudoku_operations.dart'tan yardım alıyoruz.
      if (!SudokuValidator.isValidSudokuInt(solution)) {
        _showSnackBar(context, "Çözüm bulunamadı (Genetik Algoritma)", isError: true);
        return;
      }

      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          controllers[i][j].text = solution[i][j].toString();
        }
      }

      _showSnackBar(context, "Çözüm bulundu (Genetik Algoritma ile)", isError: false);
    } catch (e) {
      _showSnackBar(context, "Hata oluştu: ${e.toString()}", isError: true);
    }
  }
  
  // Hibrit bir şekilde sudokuyu çözüyoruz.
  void solveHybrid(BuildContext context) {
    try {
      final puzzle = _getCurrentPuzzle();
      final solver = HybridSudokuSolver(puzzle: puzzle);
      final solution = solver.solve();

      // Çözüm kontrolü yapıyoruz. sudoku_operations.dart'tan yardım alıyoruz.
      if (!SudokuValidator.isValidSudokuInt(solution)) {
        _showSnackBar(context, "Çözüm bulunamadı (Hibrit yöntem)", isError: true);
        return;
      }

      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          controllers[i][j].text = solution[i][j].toString();
        }
      }

      _showSnackBar(
        context,
        "Çözüm bulundu (Hibrit: Genetik Algoritma + Saf Backtracking)",
        isError: false,
      );
    } catch (e) {
      _showSnackBar(context, "Hata oluştu: ${e.toString()}", isError: true);
    }
  }

  // Saf Backtracking ile sudokuyu çözüyoruz.
  void solveBacktracking(BuildContext context) {
    try {
      final puzzle = _getCurrentPuzzle();
      final solver = PureBacktrackingSolver(puzzle: puzzle);
      final solution = solver.solve();

      // Çözüm kontrolü yapıyoruz. sudoku_operations.dart'tan yardım alıyoruz.
      if (!SudokuValidator.isValidSudokuInt(solution)) {
        _showSnackBar(context, "Çözüm bulunamadı (Saf Backtracking)", isError: true);
        return;
      }

      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          controllers[i][j].text = solution[i][j].toString();
        }
      }

      _showSnackBar(context, "Çözüm bulundu (Saf Backtracking)", isError: false);
    } catch (e) {
      _showSnackBar(context, "Hata oluştu: ${e.toString()}", isError: true);
    }
  }

  // Sudoku işlemlerimiz burada. sudoku_operations.dart'tan yardım alıyoruz.
  void fillRandomSudoku(BuildContext context) {
    try {
      final generator = SudokuGenerator();
      bool success = generator.generatePuzzle(minFilled: 20, maxFilled: 50);

      if (success) {
        final board = generator.board;
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            controllers[i][j].text = board[i][j] == 0 ? '' : board[i][j].toString();
          }
        }
        _showSnackBar(context, "Rastgele Sudoku oluşturuldu", isError: false);
      } else {
        _showSnackBar(context, "Sudoku oluşturulamadı", isError: true);
      }
    } catch (e) {
      _showSnackBar(context, "Sudoku oluşturulurken hata: ${e.toString()}", isError: true);
    }
  }
  
  void clearAllCells(BuildContext context) {
    for (var row in controllers) {
      for (var controller in row) {
        controller.clear();
      }
    }
    _showSnackBar(context, "Tüm hücreler temizlendi", isError: false);
  }

  // Geri bildirim modalımız burada.
  void _showFeedbackModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        int selectedRating = 0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Uygulamayı Değerlendir',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedRating == 0
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _showSnackBar(
                              context,
                              'Değerlendirmeniz için teşekkürler. Puanınız: $selectedRating',
                              isError: false,
                            );
                          },
                    child: const Text('Gönder'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'İptal',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Snack bar düzenlemelerimiz. UX için.
void _showSnackBar(BuildContext context, String message, {required bool isError}) {
  if (!context.mounted) return;
  try {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: isError ? SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ) : null,
      ),
    );
  } catch (e) {
    debugPrint('SnackBar gösterilirken hata: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku GA Çözücü'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SudokuGrid(controllers: controllers),
            const SizedBox(height: 10),
            ActionButtons(
              onFillRandom: () => fillRandomSudoku(context),
              onClear: () => clearAllCells(context),
            ),
            const SizedBox(height: 10),
            SolverButtons(
              onSolveGenetic: () => solveSudoku(context),
              onSolveHybrid: () => solveHybrid(context),
              onSolveBacktracking: () => solveBacktracking(context),
            ),
            const SizedBox(height: 10),
            SolveByUserButton(
              onReturn: () => clearAllCells(context),
            ),
            const SizedBox(height: 10),
            FeedbackLink(onTap: () => _showFeedbackModal(context)),
          ],
        ),
      ),
    );
  }
}