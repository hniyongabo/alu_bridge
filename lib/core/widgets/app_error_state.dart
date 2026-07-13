import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A friendly, generic error message shown instead of raw exception text
/// (e.g. Firestore's technical error strings), so transient backend issues
/// never look like an app crash to the user.
class AppErrorState extends StatelessWidget {
  const AppErrorState({super.key, this.message = 'Something went wrong. Please try again.'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
