import 'package:flutter/material.dart';
import 'package:storryca/src/core/constants/text_styyle.dart';
import 'package:storryca/src/core/widgets/gradient_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.height,
    this.label = 'Retry',
  });

  final String message;
  final VoidCallback onRetry;
  final double? height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: whiteF14TS,
              ),
              SizedBox(
                width: 140,
                child: GradientButton(
                  label: label,
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  onPressed: onRetry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
