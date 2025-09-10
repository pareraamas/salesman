import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  
  const ErrorState({
    Key? key,
    required this.message,
    this.buttonText = 'Coba Lagi',
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(buttonText!), // Non-null assertion is safe here because we check onRetry
              ),
            ],
          ],
        ),
      ),
    );
  }
}
