import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';

/// TEMPORARY. Replaced by the real screen in its subsystem (S3 Feedback /
/// S6 AI-chat-general). Reachable only via the new overflow menu — no
/// regression of existing behaviour.
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          Center(
            child: Text(
              '$title\n(coming soon)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontStyle: FontStyle.italic,
                fontSize: 15,
                height: 1.5,
                color: text2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
