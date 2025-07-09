import 'package:flutter/material.dart';

// Algoritma seçim butonlarımızın widgeti burada.
class SolverButtons extends StatelessWidget {
  final VoidCallback onSolveGenetic;
  final VoidCallback onSolveHybrid;
  final VoidCallback onSolveBacktracking;

  const SolverButtons({
    super.key,
    required this.onSolveGenetic,
    required this.onSolveHybrid,
    required this.onSolveBacktracking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withValues(alpha: 0.1),
                Colors.purple.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.indigo.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.indigo,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Çözüm Algoritmaları',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSolverButton(
                      'Genetik\nAlgoritma',
                      Icons.person,
                      Colors.blue,
                      onSolveGenetic,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSolverButton(
                      'Hibrit\nÇözüm',
                      Icons.merge_type,
                      Colors.purple,
                      onSolveHybrid,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSolverButton(
                      'Saf Backtracking',
                      Icons.arrow_back,
                      Colors.green,
                      onSolveBacktracking,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSolverButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 15,
            ),
            const SizedBox(height: 2),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}