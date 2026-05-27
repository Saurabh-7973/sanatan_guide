import 'package:flutter/material.dart';

import 'package:sanatan_guide/presentation/shared/widgets/heritage_states.dart';

/// Standard error state widget. Heritage-toned (saffron-glow disc, italic
/// Lora body, saffron pill retry). Thin shim over [HeritageError] so every
/// AsyncValue.when error branch already calling this widget picks up the
/// new look without per-site edits. New code can use HeritageError directly.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    this.message = 'Something went wrong loading this content.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) =>
      HeritageError(message: message, onRetry: onRetry);
}
