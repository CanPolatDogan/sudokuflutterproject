import 'package:flutter/material.dart';

// Geri bildirim animasyonumuzun widgeti burada.
class FeedbackMessage extends StatelessWidget {
  final bool showSuccess;
  final bool showFailure;
  final AnimationController animationController;
  final Animation<Offset> slideAnimation;

  const FeedbackMessage({
    super.key,
    required this.showSuccess,
    required this.showFailure,
    required this.animationController,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (!showSuccess && !showFailure) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) => SlideTransition(
        position: slideAnimation,
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: showSuccess ? Colors.green[400] : Colors.red[400],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: showSuccess ? Colors.green : Colors.red,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          showSuccess ? "Doğru Çözüldü!" : "Yanlış Çözüldü!",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}