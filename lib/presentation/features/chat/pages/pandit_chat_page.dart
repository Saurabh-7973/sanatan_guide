// lib/presentation/features/chat/pages/pandit_chat_page.dart
//
// Ask the Pandit — general-mode AI chat (S6). No verse anchor: the user poses
// any question about the texts and gets a Gemini-backed answer, gated by the
// shared daily rate limit. Source: New Design/screen-14-missing-flows.html
// § "AI CHAT — GENERAL MODE". The verse-anchored chat is a separate screen.

import 'package:flutter/material.dart';

import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_rich_prose.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/offline_banner.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

const _kSuggestions = <String>[
  '"What does the Gītā say about anger?"',
  '"How should I think about death?"',
  '"What is the difference between dharma and karma?"',
  '"Which Upaniṣad should I read first?"',
];

const _kSystemPrompt =
    'You are a knowledgeable, reverent guide to the Hindu scriptures of '
    'Sanatan Dharma. Answer questions about the texts — philosophy, dharma, '
    'specific concepts, or passages the user half-remembers. When you draw on '
    'a teaching, name the scripture and verse using one of these exact forms '
    'so the app can link it: (Bhagavad Gītā 2.47), (BG 2.47), '
    '(Kaṭha Upaniṣad 1.2.18), (Ṛgveda 1.1.1). Always wrap the citation in '
    'parentheses. When you introduce a key Sanskrit term or concept '
    '(dharma, karma, mokṣa, ātman, etc.) mark it with double asterisks, like '
    '**dharma**, so the app can highlight it. '
    'Acknowledge uncertainty honestly. Never claim divine authority. Respect '
    'every tradition within Sanatan Dharma. Keep answers concise — under 200 '
    'words unless the user asks for more depth.';

/// General-mode "Ask the Pandit" chat, served at `/chat`.
class PanditChatPage extends StatefulWidget {
  const PanditChatPage({super.key});

  @override
  State<PanditChatPage> createState() => _PanditChatPageState();
}

class _PanditChatPageState extends State<PanditChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  final _messages = <ChatMessage>[];
  bool _loading = false;
  int _remaining = GeminiRateLimit.maxPerDay;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRemaining();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRemaining() async {
    final r = await GeminiRateLimit.remaining();
    if (mounted) setState(() => _remaining = r);
  }

  bool get _canSend =>
      !_loading &&
      _remaining > 0 &&
      GeminiService.isEnabled &&
      _controller.text.trim().isNotEmpty;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading || !GeminiService.isEnabled) return;

    if (_remaining <= 0) {
      setState(() => _error = 'Daily question limit reached.');
      return;
    }
    final allowed = await GeminiRateLimit.consume();
    if (!allowed) {
      setState(() {
        _error = 'Daily question limit reached.';
        _remaining = 0;
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _loading = true;
      _error = null;
      _remaining -= 1;
    });
    _scrollToBottom();

    try {
      final reply = await GeminiService.ask(
        systemContext: _kSystemPrompt,
        history: _messages.sublist(0, _messages.length - 1),
        userMessage: text,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false));
        _loading = false;
      });
      _scrollToBottom();
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error =
              "Couldn't reach the Pandit. Check your connection and try again.";
          _loading = false;
        });
      }
    }
  }

  void _sendSuggestion(String question) {
    _controller.text = question;
    _send();
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
      _error = null;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showEmpty = _messages.isEmpty && !_loading;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  isDark: isDark,
                  showClear: _messages.isNotEmpty,
                  onClear: _clearConversation,
                ),
                const OfflineBanner(),
                Expanded(
                  child: showEmpty
                      ? _EmptyState(
                          isDark: isDark,
                          aiEnabled: GeminiService.isEnabled,
                          onSuggestion: _sendSuggestion,
                        )
                      : _Conversation(
                          isDark: isDark,
                          messages: _messages,
                          loading: _loading,
                          error: _error,
                          scrollController: _scrollController,
                        ),
                ),
                _InputArea(
                  isDark: isDark,
                  controller: _controller,
                  focusNode: _focusNode,
                  aiEnabled: GeminiService.isEnabled,
                  remaining: _remaining,
                  canSend: _canSend,
                  onChanged: () => setState(() {}),
                  onSend: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isDark,
    required this.showClear,
    required this.onClear,
  });

  final bool isDark;
  final bool showClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final saffron = isDark ? DColors.saffron : LColors.saffron;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Row(
        children: [
          _HitButton(
            onTap: () => Navigator.of(context).maybePop(),
            child: const MockupBackChevron(),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ॐ',
                  style: TextStyle(
                    fontFamily: Fonts.deva,
                    fontFamilyFallback: AppFontFallback.deva,
                    fontSize: 18,
                    height: 1,
                    color: saffron,
                  ),
                ),
                const SizedBox(height: 3),
                Text('ASK THE PANDIT',
                    style: AppText.sectionLabel(color: text1)),
              ],
            ),
          ),
          _HitButton(
            onTap: showClear ? onClear : null,
            child: showClear
                ? Icon(Icons.add_rounded, size: 20, color: text3)
                : const SizedBox(width: 20, height: 20),
          ),
        ],
      ),
    );
  }
}

class _HitButton extends StatelessWidget {
  const _HitButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(child: child),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isDark,
    required this.aiEnabled,
    required this.onSuggestion,
  });

  final bool isDark;
  final bool aiEnabled;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 24, 36, 80),
        child: Column(
          children: [
            Text(
              'ॐ',
              style: TextStyle(
                fontFamily: Fonts.deva,
                fontFamilyFallback: AppFontFallback.deva,
                fontSize: 60,
                height: 1,
                color: saffron,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'What would you like to ask?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                height: 1.3,
                letterSpacing: -0.22,
                color: text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              aiEnabled
                  ? 'Pose a question about the texts — life, dharma, a '
                      'specific concept, or a passage you remember. Every '
                      'answer cites real verses.'
                  : 'Ask-the-Pandit guidance needs an AI key and is not '
                      'available in this build.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.serif,
                fontFamilyFallback: AppFontFallback.latin,
                fontStyle: FontStyle.italic,
                fontSize: 13.5,
                height: 1.55,
                color: text2,
              ),
            ),
            if (aiEnabled) ...[
              const SizedBox(height: 28),
              Text('TRY ASKING', style: AppText.sectionLabel(color: text3)),
              const SizedBox(height: 14),
              for (final q in _kSuggestions) ...[
                _SuggestionChip(
                  isDark: isDark,
                  text: q,
                  onTap: () => onSuggestion(q),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.isDark,
    required this.text,
    required this.onTap,
  });

  final bool isDark;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: divider),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: Fonts.serif,
            fontFamilyFallback: AppFontFallback.latin,
            fontStyle: FontStyle.italic,
            fontSize: 13.5,
            height: 1.3,
            color: text1,
          ),
        ),
      ),
    );
  }
}

// ── Conversation ───────────────────────────────────────────────────────────

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.isDark,
    required this.messages,
    required this.loading,
    required this.error,
    required this.scrollController,
  });

  final bool isDark;
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: messages.length + (loading ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AIThinkingDots(isDark: isDark),
                  ),
                );
              }
              final msg = messages[index];
              return msg.isUser
                  ? _UserBubble(isDark: isDark, text: msg.text)
                  : AiRichProse(isDark: isDark, text: msg.text);
            },
          ),
        ),
        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 12,
                height: 1.4,
                color: iron,
              ),
            ),
          ),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.isDark, required this.text});

  final bool isDark;
  final String text;

  @override
  Widget build(BuildContext context) {
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    final divider = isDark ? DColors.divider : LColors.divider;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: glow,
            border: Border.all(color: divider),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 13.5,
              height: 1.45,
              color: text1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input area ─────────────────────────────────────────────────────────────

class _InputArea extends StatelessWidget {
  const _InputArea({
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.aiEnabled,
    required this.remaining,
    required this.canSend,
    required this.onChanged,
    required this.onSend,
  });

  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool aiEnabled;
  final int remaining;
  final bool canSend;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (!aiEnabled) {
      return _RestingStrip(
        isDark: isDark,
        text: 'Ask-the-Pandit guidance is not available in this build.',
      );
    }
    if (remaining <= 0) {
      return _RestingStrip(
        isDark: isDark,
        text: 'The Pandit is resting — daily question limit reached. '
            'Resets at midnight.',
      );
    }

    final surface = isDark ? DColors.surface : LColors.surface;
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: dividerSoft),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onChanged: (_) => onChanged(),
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(
                    fontFamily: Fonts.sans,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 13.5,
                    height: 1.4,
                    color: text1,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    // Field sits in a custom pill — strip the global
                    // inputDecorationTheme (filled:true + bordered) or it
                    // paints its own box inside the pill.
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: 'Ask anything about the texts…',
                    hintStyle: TextStyle(
                      fontFamily: Fonts.sans,
                      fontFamilyFallback: AppFontFallback.latin,
                      fontSize: 13.5,
                      color: text3,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            isDark: isDark,
            enabled: canSend,
            onTap: canSend ? onSend : null,
            surface2: surface2,
            saffron: saffron,
            text3: text3,
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.isDark,
    required this.enabled,
    required this.onTap,
    required this.surface2,
    required this.saffron,
    required this.text3,
  });

  final bool isDark;
  final bool enabled;
  final VoidCallback? onTap;
  final Color surface2;
  final Color saffron;
  final Color text3;

  @override
  Widget build(BuildContext context) {
    final glyphColor =
        enabled ? (isDark ? const Color(0xFF1A1208) : Colors.white) : text3;
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? saffron : surface2,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CustomPaint(painter: _PaperPlanePainter(color: glyphColor)),
          ),
        ),
      ),
    );
  }
}

/// Mockup `.chat-input-send`: paper plane `M3 9l13-6-4 13-3-6-6-1z`, sw 1.6.
class _PaperPlanePainter extends CustomPainter {
  const _PaperPlanePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 18.0;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(3 * u, 9 * u)
      ..lineTo(16 * u, 3 * u)
      ..lineTo(12 * u, 16 * u)
      ..lineTo(9 * u, 10 * u)
      ..lineTo(3 * u, 9 * u)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_PaperPlanePainter old) => old.color != color;
}

class _RestingStrip extends StatelessWidget {
  const _RestingStrip({required this.isDark, required this.text});

  final bool isDark;
  final String text;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dividerSoft)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: Fonts.sans,
          fontFamilyFallback: AppFontFallback.latin,
          fontSize: 12,
          height: 1.4,
          color: text3,
        ),
      ),
    );
  }
}
