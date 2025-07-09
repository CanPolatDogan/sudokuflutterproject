import 'package:flutter/material.dart';
import '../data/sudoku_templates.dart';
import 'dart:math';
import '../widgets/sudoku_grid.dart';
import '../widgets/action_buttons.dart';
import '../widgets/user_solver_buttons.dart';
import '../widgets/template_buttons.dart';
import '../widgets/feedback_message.dart';
import '../sudoku_operations.dart';

class UserSudokuScreen extends StatefulWidget {
  const UserSudokuScreen({super.key});

  @override
  State<UserSudokuScreen> createState() => _UserSudokuScreenState();
}

class _UserSudokuScreenState extends State<UserSudokuScreen>
    with SingleTickerProviderStateMixin {
  List<List<TextEditingController>> controllers = List.generate(
    9,
    (index) => List.generate(9, (index) => TextEditingController()),
  );

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool showSuccess = false;
  bool showFailure = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }
  
  // Kullanıcının cevabını kontrol ettiğim fonksiyonumuz.
  void checkUserSolution() {
    try {
      List<List<String>> board = List.generate(9, (i) {
        return List.generate(9, (j) => controllers[i][j].text.trim());
      });

      if (SudokuValidator.hasEmptyCells(board)) {
        _showSnackBar('Lütfen tüm hücreleri doldurun!', isError: true);
        return;
      }

      bool valid = SudokuValidator.isValidSudoku(board);
      if (valid) {
        setState(() {
          showSuccess = true;
          showFailure = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar('Tebrikler. Sudoku geçerli.', isError: false);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showSuccess = false;
            });
          }
        });
      } else {
        setState(() {
          showFailure = true;
          showSuccess = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar("Geçersiz Sudoku: Kurallara uymuyor.", isError: true);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showFailure = false;
            });
          }
        });
      }
    } catch (e) {
      _showSnackBar("Kontrol sırasında hata oluştu: ${e.toString()}", isError: true);
    }
  }

  void clearAllCells() {
    try {
      setState(() {
        for (var row in controllers) {
          for (var controller in row) {
            controller.clear();
          }
        }
      });
      _showSnackBar("Tüm hücreler temizlendi", isError: false);
    } catch (e) {
      _showSnackBar("Temizleme sırasında hata oluştu: ${e.toString()}", isError: true);
    }
  }

  // Kullanıcının cevabını AI ile kontrol ettiğim fonksiyonumuz.
  void checkWithBasicAI() {
    try {
      List<List<String>> stringBoard = List.generate(9, (i) {
        return List.generate(9, (j) => controllers[i][j].text.trim());
      });

      // String board'u int board'a çeviriyoruz.
      List<List<int>>? userInput = SudokuValidator.stringToIntBoard(stringBoard);
      if (userInput == null) {
        _showSnackBar("Geçersiz giriş değerleri.", isError: true);
        return;
      }

      if (SudokuValidator.hasEmptyCellsInt(userInput)) {
        _showSnackBar("Lütfen tüm hücreleri doldurun.", isError: true);
        return;
      }

      if (!SudokuValidator.isValidSudokuInt(userInput)) {
        setState(() {
          showFailure = true;
          showSuccess = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar("Geçersiz Sudoku: Kurallara uymuyor.", isError: true);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showFailure = false;
            });
          }
        });
        return;
      }

      List<List<int>> aiSolution = userInput.map((row) => List<int>.from(row)).toList();
      bool solved = SimpleSudokuSolver.solveSudoku(aiSolution);

      if (!solved) {
        setState(() {
          showFailure = true;
          showSuccess = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar("Geçersiz Sudoku: AI çözemedi.", isError: true);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showFailure = false;
            });
          }
        });
        return;
      }

      // Çözüm kontrolü yapıyoruz. sudoku_operations.dart'tan yardım alıyoruz.
      bool same = true;
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (userInput[i][j] != aiSolution[i][j]) {
            same = false;
            break;
          }
        }
        if (!same) break;
      }

      if (same) {
        setState(() {
          showSuccess = true;
          showFailure = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar('Tebrikler. Sudoku geçerli.', isError: false);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showSuccess = false;
            });
          }
        });
      } else {
        setState(() {
          showFailure = true;
          showSuccess = false;
        });
        _animationController.forward(from: 0);
        _showSnackBar("Geçersiz Sudoku: AI farklı bir çözüm buldu.", isError: true);

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showFailure = false;
            });
          }
        });
      }
    } catch (e) {
      _showSnackBar("AI kontrolü sırasında hata oluştu: ${e.toString()}", isError: true);
    }
  }
  
  // Snack bar düzenlemelerimiz. UX için.
  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
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

  // Data tablomuzdan rastgele sudoku şablonu çekiyoruz.
  void loadRandomSudokuTemplate() {
    try {
      final random = Random();
      final maxIndex = sudokuTemplates.length - 1;
      final randomIndex = random.nextInt(maxIndex);

      final randomTemplate = sudokuTemplates[randomIndex];

      setState(() {
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            final value = randomTemplate.board[i][j];
            controllers[i][j].text = value == 0 ? '' : value.toString();
          }
        }
      });
      _showSnackBar("Rastgele Sudoku şablonu yüklendi", isError: false);
    } catch (e) {
      _showSnackBar("Şablon yüklenirken hata oluştu: ${e.toString()}", isError: true);
    }
  }
  
  // Data tablomuzdan tamamlanmış sudoku şablonu çekiyoruz.
  void loadFinishedSudokuTemplate() {
    try {
      final lastTemplate = sudokuTemplates[sudokuTemplates.length - 1];

      setState(() {
        for (int i = 0; i < 9; i++) {
          for (int j = 0; j < 9; j++) {
            final value = lastTemplate.board[i][j];
            controllers[i][j].text = value == 0 ? '' : value.toString();
          }
        }
      });
      _showSnackBar("Tamamlanmış Sudoku şablonu yüklendi", isError: false);
    } catch (e) {
      _showSnackBar("Şablon yüklenirken hata oluştu: ${e.toString()}", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Çöz ve Kontrol Et'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SudokuGrid(controllers: controllers),
            const SizedBox(height: 35),
            FeedbackMessage(
              showSuccess: showSuccess,
              showFailure: showFailure,
              animationController: _animationController,
              slideAnimation: _slideAnimation,
            ),
            ActionButtons(
              onFillRandom: loadRandomSudokuTemplate,
              onClear: clearAllCells,
            ),
            const SizedBox(height: 35),
            UserSolverButtons(
              onCheckSolution: checkUserSolution,
              onCheckWithAI: checkWithBasicAI,
            ),
            const SizedBox(height: 35),
            TemplateButtons(
              onLoadRandom: loadRandomSudokuTemplate,
              onLoadFinished: loadFinishedSudokuTemplate,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/sudoku_picture.jpg', // Bir adet sudoku resmi ekledim.
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grid_3x3,
                            size: 40,
                            color: Colors.indigo,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sudoku Bulmacası',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}