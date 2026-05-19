import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around the Gemini REST API.
///
/// API key is injected at build time:
///   flutter run --dart-define=GEMINI_API_KEY=AIza...
class GeminiService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _model = 'gemini-2.5-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_model:generateContent';

  static bool get isEnabled => _apiKey.isNotEmpty;

  /// Send a single-turn or multi-turn request to Gemini.
  ///
  /// [systemContext] is prepended as the first user turn (with a canned model
  /// acknowledgement) so the model has scripture context throughout the
  /// conversation.
  static Future<String> ask({
    required String systemContext,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    if (!isEnabled) {
      throw const GeminiException('Gemini API key not configured.');
    }

    final contents = <Map<String, dynamic>>[
      {
        'role': 'user',
        'parts': [
          {'text': systemContext},
        ],
      },
      {
        'role': 'model',
        'parts': [
          {
            'text':
                'Understood. I am ready to help you explore this scripture.',
          },
        ],
      },
      for (final msg in history)
        {
          'role': msg.isUser ? 'user' : 'model',
          'parts': [
            {'text': msg.text},
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      },
    ];

    final response = await http.post(
      Uri.parse('$_endpoint?key=$_apiKey'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': contents}),
    );

    if (response.statusCode != 200) {
      final friendlyMessage = switch (response.statusCode) {
        429 => 'Daily quota exceeded. Please try again tomorrow!',
        401 || 403 => 'API key is invalid or unauthorized.',
        500 ||
        503 =>
          'AI service is temporarily unavailable. Try again in a moment.',
        _ => 'Request failed (${response.statusCode}). Please try again.',
      };
      throw GeminiException(friendlyMessage);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final candidate = candidates?.firstOrNull as Map<String, dynamic>?;
    final content = candidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text =
        (parts?.firstOrNull as Map<String, dynamic>?)?['text'] as String?;
    if (text == null || text.isEmpty) {
      throw const GeminiException('Empty response from Gemini.');
    }
    return text;
  }
}

// ── Rate limiter ──────────────────────────────────────────────────────────

class GeminiRateLimit {
  static const int maxPerDay = 10;
  static const String _prefix = 'gemini_daily_';

  /// Per-feature daily budgets. Chat keeps the original 10/day. Word-gloss
  /// and section-theme lookups get their own pools so first-use bursts can't
  /// starve "Ask the Pandit". Results are cached forever, so each unique
  /// item costs one lifetime call — the caps are first-touch ceilings.
  static const int chatCap = maxPerDay;
  static const int glossCap = 50;
  static const int themeCap = 40;

  static String _todayKey(String bucket) {
    final now = DateTime.now();
    final b = bucket == 'chat' ? '' : '${bucket}_';
    return '$_prefix$b${now.year}_${now.month}_${now.day}';
  }

  static Future<int> remaining({
    String bucket = 'chat',
    int cap = maxPerDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_todayKey(bucket)) ?? 0;
    return (cap - used).clamp(0, cap);
  }

  static Future<bool> consume({
    String bucket = 'chat',
    int cap = maxPerDay,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey(bucket);
    final used = prefs.getInt(key) ?? 0;
    if (used >= cap) return false;
    await prefs.setInt(key, used + 1);
    return true;
  }
}

// ── Data model ────────────────────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class GeminiException implements Exception {
  const GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}
