import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Sudoku gridimiz 9x9 olacak şekilde ayrıca 3x3 belirgin şekilde burada.
class SudokuGrid extends StatelessWidget {
  final List<List<TextEditingController>> controllers;

  const SudokuGrid({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Column(
          children: List.generate(9, (i) {
            return Expanded(
              child: Row(
                children: List.generate(9, (j) {
                  final isThickRight = j == 2 || j == 5;
                  final isThickBottom = i == 2 || i == 5;

                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            width: isThickRight ? 2 : 0.5,
                            color: Colors.black,
                          ),
                          bottom: BorderSide(
                            width: isThickBottom ? 2 : 0.5,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      margin: const EdgeInsets.all(0.5),
                      child: TextField(
                        controller: controllers[i][j],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[1-9]')),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: Colors.indigo,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }
}