import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sanatan_guide/core/utils/app_logger.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/widgets/share_card_widget.dart';

abstract final class ShareCardGenerator {
  /// Captures [ShareCardWidget] as a high-res PNG and opens the
  /// system share sheet. Falls back to plain text if image fails.
  ///
  /// [repaintKey] must be attached to a [RepaintBoundary] wrapping
  /// a [ShareCardWidget] that is currently in the widget tree.
  static Future<void> captureAndShare({
    required GlobalKey repaintKey,
    required Verse verse,
  }) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        AppLogger.instance.w(
          'ShareCardGenerator: boundary not found — falling back to text',
        );
        _shareAsText(verse);
        return;
      }

      // Capture at 3x for 1080px wide output (360 logical × 3)
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        AppLogger.instance.w('ShareCardGenerator: byteData null — fallback');
        _shareAsText(verse);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/sanatan_verse_${verse.id}.png';
      await File(filePath).writeAsBytes(pngBytes);

      AppLogger.instance.i(
        'ShareCardGenerator: image captured — ${pngBytes.length} bytes',
      );

      // Share the image
      await Share.shareXFiles(
        [XFile(filePath, mimeType: 'image/png')],
        subject:
            '${verse.scripture.displayName} · ${getVerseLabel(verse)}',
      );
    } catch (e, st) {
      AppLogger.instance.e('ShareCardGenerator.captureAndShare failed', e, st);
      _shareAsText(verse);
    }
  }

  static void _shareAsText(Verse verse) {
    final hasEnglish =
        verse.english != null && verse.english!.trim().isNotEmpty;
    final text = StringBuffer();
    if (verse.sanskrit.trim().isNotEmpty) {
      text.writeln(verse.sanskrit);
    } else if (!hasEnglish) {
      text.writeln('Text not available for this verse');
    }
    text.writeln();
    if (hasEnglish) {
      text.writeln(verse.english);
    }
    text
      ..writeln()
      ..write(
        '— ${verse.scripture.displayName} · ${getVerseLabel(verse)}',
      )
      ..writeln()
      ..write('via Sanatan Guide');
    Share.share(text.toString());
  }
}
