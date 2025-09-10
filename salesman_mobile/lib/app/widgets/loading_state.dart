import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  final String message;
  
  const LoadingState({
    Key? key,
    this.message = 'Memuat data...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
