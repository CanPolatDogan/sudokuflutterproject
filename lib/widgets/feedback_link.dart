import 'package:flutter/material.dart';

// Geri dönüş almamız için tasarlanan modal widget burada.
class FeedbackLink extends StatelessWidget {
  final VoidCallback onTap;

  const FeedbackLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            color: Colors.amber[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              'Uygulamayı Değerlendir',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueAccent[700],
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.star_border,
            color: Colors.amber[600],
            size: 20,
          ),
        ],
      ),
    );
  }
}