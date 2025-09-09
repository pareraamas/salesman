import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class LoadingPage extends StatelessWidget {
  final String? message;
  final Widget? child;

  const LoadingPage({
    super.key,
    this.message,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 16),
            child!,
          ],
        ],
      ),
    );
  }
}
