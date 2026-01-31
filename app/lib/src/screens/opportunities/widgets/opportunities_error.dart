import 'package:app/src/widgets/misc/retry_widget.dart';
import 'package:flutter/material.dart';

class OpportunitiesError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const OpportunitiesError({
    Key? key,
    this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load opportunities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            RetryWidget(
              message ?? 'Please try again',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
