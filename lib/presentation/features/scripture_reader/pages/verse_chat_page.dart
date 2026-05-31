// lib/presentation/features/scripture_reader/pages/verse_chat_page.dart
//
// Verse-anchored "Explain this verse" chat (brief Screen 10). Differs from
// the general Ask-the-Pandit chat (pandit_chat_page) only in the topbar +
// verse anchor; the message/input/thinking chrome is the shared heritage
// vocabulary. Gemini-backed, daily-rate-limited, key-gated. All chat logic
// (seed, regenerate, save-to-notes) preserved from the pre-heritage version.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_rich_prose.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_states.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_widgets.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/offline_banner.dart';
import 'package:sanatan_guide/presentation/shared/widgets/system_chrome.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/design_tokens.dart';
import 'package:sanatan_guide/presentation/theme/design_typography.dart';

class VerseChatPage extends ConsumerStatefulWidget {
  const VerseChatPage({super.key, required this.verseId, this.seed});
  final String verseId;

  /// Optional pre-filled first question. When non-null the chat fires it
  /// automatically as soon as the verse loads — used by Commentary →
  /// "Ask further" chips so the user lands on a populated conversation.
  final String? seed;

  @override
  ConsumerState<VerseChatPage> createState() => _VerseChatPageState();
}

class _VerseChatPageState extends ConsumerState<VerseChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  final _messages = <ChatMessage>[];
  bool _loading = false;
  int _remaining = GeminiRateLimit.maxPerDay;
  String? _error;
  // Last user prompt that hit the network — powers the "Try again" pill on
  // transient failures. Null on rate-limit (retry can't help until midnight).
  String? _retryableText;
  bool _seedFired = false;

  static const String _systemPrompt =
      'You are a helpful and reverent guide to Hindu scriptures. '
      'Cite specific verses when relevant. '
      'Acknowledge when you are uncertain. '
      'Never claim divine authority. '
      'Be respectful of all traditions within Sanatan Dharma. '
      'Keep answers concise — under 200 words unless the user asks for more detail.';

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

  String _buildContext(Verse verse) {
    final label = compactVerseLocationLabel(verse);
    final buffer = StringBuffer()
      ..writeln('Context: $label from ${verse.scripture.displayName}.')
      ..writeln()
      ..writeln('Sanskrit:')
      ..writeln(verse.sanskrit)
      ..writeln()
      ..write(_systemPrompt);
    if (verse.english != null) {
      buffer
        ..writeln()
        ..writeln()
        ..writeln('English translation:')
        ..writeln(verse.english);
    }
    return buffer.toString();
  }

  /// Reruns the most-recent user prompt: removes the trailing AI reply (if
  /// any), pops the user message that produced it, and calls [_send] with
  /// the same text. Daily-quota counter is decremented again — a regenerate
  /// is a real new API call. No-op if the last message is from the user
  /// (we're already loading or the reply hasn't arrived).
  Future<void> _regenerate(Verse verse) async {
    if (_loading || _messages.isEmpty) return;
    if (_messages.last.isUser) return;
    final lastAi = _messages.removeLast();
    if (_messages.isNotEmpty && _messages.last.isUser) {
      final prompt = _messages.removeLast();
      setState(() {});
      await _send(verse, overrideText: prompt.text);
      return;
    }
    // Couldn't find the prompt that produced this reply — restore it.
    setState(() => _messages.add(lastAi));
  }

  Future<void> _send(Verse verse, {String? overrideText}) async {
    final text = (overrideText ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;

    if (_remaining <= 0) {
      setState(() {
        _error =
            'Daily limit reached (${GeminiRateLimit.maxPerDay} questions/day). Try again tomorrow.';
        _retryableText = null;
      });
      return;
    }

    final allowed = await GeminiRateLimit.consume();
    if (!allowed) {
      setState(() {
        _error = 'Daily limit reached. Try again tomorrow.';
        _retryableText = null;
        _remaining = 0;
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _loading = true;
      _error = null;
      _retryableText = text;
      _remaining--;
    });
    _scrollToBottom();
    await _dispatch(verse, text);
  }

  /// Retry path for the "Try again" pill — re-runs [_retryableText] without
  /// consuming the rate-limit budget again (the original send already did)
  /// and without re-pushing the user bubble (it's already in [_messages]).
  Future<void> _retry(Verse verse) async {
    final text = _retryableText;
    if (text == null || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _scrollToBottom();
    await _dispatch(verse, text);
  }

  Future<void> _dispatch(Verse verse, String text) async {
    try {
      final reply = await GeminiService.ask(
        systemContext: _buildContext(verse),
        history: _messages.sublist(0, _messages.length - 1),
        userMessage: text,
      );
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(text: reply, isUser: false));
          _loading = false;
        });
        _scrollToBottom();
      }
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'The connection couldn’t reach the texts. The verses are '
              'still here, but the Pandit needs internet to think.';
          _loading = false;
        });
      }
    }
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

  void _maybeFireSeed(Verse verse) {
    if (_seedFired) return;
    final seed = widget.seed?.trim();
    if (seed == null || seed.isEmpty) return;
    _seedFired = true;
    _controller.text = seed;
    WidgetsBinding.instance.addPostFrameCallback((_) => _send(verse));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verseDetailProvider(widget.verseId));
    state.whenData((either) => either.fold((_) {}, _maybeFireSeed));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(isDark: isDark, remaining: _remaining),
                const OfflineBanner(),
                Expanded(
                  child: state.when(
                    loading: () => const VerseDetailShimmer(),
                    error: (_, __) => HeritageError(
                      message:
                          'Could not load this verse — pull down or retry.',
                      onRetry: () =>
                          ref.invalidate(verseDetailProvider(widget.verseId)),
                    ),
                    data: (either) => either.fold(
                      (failure) => HeritageError(message: failure.message),
                      (verse) => _ChatBody(
                        verse: verse,
                        messages: _messages,
                        loading: _loading,
                        error: _error,
                        isDark: isDark,
                        scrollController: _scrollController,
                        onRegenerate: () => _regenerate(verse),
                        onRetry:
                            _retryableText == null ? null : () => _retry(verse),
                      ),
                    ),
                  ),
                ),
                state
                        .whenData((either) => either.fold(
                              (_) => const SizedBox.shrink(),
                              (verse) => _InputBar(
                                controller: _controller,
                                focusNode: _focusNode,
                                remaining: _remaining,
                                loading: _loading,
                                isDark: isDark,
                                onChanged: () => setState(() {}),
                                onSend: () => _send(verse),
                              ),
                            ))
                        .value ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isDark, required this.remaining});

  final bool isDark;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
      child: Row(
        children: [
          InkResponse(
            onTap: () => Navigator.of(context).maybePop(),
            radius: 22,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Center(child: MockupBackChevron()),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ask about this verse',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: text1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$remaining question${remaining == 1 ? '' : 's'} remaining today',
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 11.5,
                    color: text3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat body: verse anchor + messages + error ─────────────────────────────

class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.verse,
    required this.messages,
    required this.loading,
    required this.error,
    required this.isDark,
    required this.scrollController,
    required this.onRegenerate,
    required this.onRetry,
  });

  final Verse verse;
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final bool isDark;
  final ScrollController scrollController;
  final VoidCallback onRegenerate;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final iron = isDark ? DColors.ironRedBright : LColors.ironRedBright;

    return Column(
      children: [
        _VerseAnchor(verse: verse, isDark: isDark),
        Expanded(
          child: messages.isEmpty && !loading
              ? _WelcomePrompt(isDark: isDark)
              : ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
                    final m = messages[index];
                    if (m.isUser) {
                      return _UserBubble(isDark: isDark, text: m.text);
                    }
                    final isLastAi =
                        !loading && index == messages.length - 1;
                    return _AiReply(
                      text: m.text,
                      verseId: verse.id,
                      isDark: isDark,
                      onRegenerate: isLastAi ? onRegenerate : null,
                    );
                  },
                ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Fonts.serif,
                    fontFamilyFallback: AppFontFallback.latin,
                    fontStyle: FontStyle.italic,
                    fontSize: 13.5,
                    height: 1.45,
                    color: iron,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  _RetryPill(isDark: isDark, onTap: onRetry!),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Verse anchor at the top of the conversation — LeafThread + Devanāgarī
/// incipit + scripture coordinate. "Your place" for the chat.
class _VerseAnchor extends StatelessWidget {
  const _VerseAnchor({required this.verse, required this.isDark});

  final Verse verse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cream = isDark ? DColors.cream : LColors.text1;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;
    final incipit = verse.sanskrit.split('\n').first.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerSoft)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 2,
              bottom: 2,
              child: LeafThread(isDark: isDark),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${verse.scripture.displayName} · '
                    '${compactVerseLocationLabel(verse)}',
                    style: TextStyle(
                      fontFamily: Fonts.sans,
                      fontFamilyFallback: AppFontFallback.latin,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2 * 9.5,
                      color: saffron,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incipit.isEmpty ? '—' : incipit,
                    style: TextStyle(
                      fontFamily: Fonts.deva,
                      fontFamilyFallback: AppFontFallback.deva,
                      fontSize: 15,
                      height: 1.4,
                      color: cream,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Welcome state ──────────────────────────────────────────────────────────

class _WelcomePrompt extends StatelessWidget {
  const _WelcomePrompt({required this.isDark});

  final bool isDark;

  static const _starters = [
    'What does this verse mean?',
    'What is the context of this verse?',
    'How can I apply this teaching today?',
    'What are the key Sanskrit terms here?',
  ];

  @override
  Widget build(BuildContext context) {
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text2 = isDark ? DColors.text2 : LColors.text2;
    final text3 = isDark ? DColors.text3 : LColors.text3;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask anything about this verse',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: text1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Context, meaning, application, Sanskrit terms — the guide will '
            'help.',
            style: TextStyle(
              fontFamily: Fonts.serif,
              fontFamilyFallback: AppFontFallback.latin,
              fontStyle: FontStyle.italic,
              fontSize: 13.5,
              height: 1.55,
              color: text2,
            ),
          ),
          const SizedBox(height: 24),
          Text('SUGGESTED QUESTIONS', style: AppText.sectionLabel(color: text3)),
          const SizedBox(height: 14),
          for (final q in _starters) ...[
            _StarterChip(isDark: isDark, label: q),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({required this.isDark, required this.label});

  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? DColors.divider : LColors.divider;
    final text1 = isDark ? DColors.text1 : LColors.text1;

    return InkWell(
      onTap: () {
        final state = context.findAncestorStateOfType<_VerseChatPageState>();
        if (state == null) return;
        state._controller.text = label;
        state._focusNode.requestFocus();
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: divider),
        ),
        child: Text(
          label,
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

// ── AI reply (flowing prose, no bubble) + user bubble ──────────────────────

class _AiReply extends StatelessWidget {
  const _AiReply({
    required this.text,
    required this.verseId,
    required this.isDark,
    this.onRegenerate,
  });

  final String text;
  final String verseId;
  final bool isDark;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiRichProse(isDark: isDark, text: text, horizontalPadding: 0),
        const SizedBox(height: 6),
        _AiActionRow(
          text: text,
          isDark: isDark,
          verseId: verseId,
          onRegenerate: onRegenerate,
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

/// Copy · save-to-notes · share · regenerate, under each AI reply.
class _AiActionRow extends ConsumerWidget {
  const _AiActionRow({
    required this.text,
    required this.isDark,
    required this.verseId,
    this.onRegenerate,
  });
  final String text;
  final bool isDark;
  final String verseId;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.copy_outlined,
          tooltip: 'Copy',
          color: text3,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) showHeritageToast(context, 'Copied');
          },
        ),
        const SizedBox(width: 4),
        _IconAction(
          icon: Icons.bookmark_add_outlined,
          tooltip: 'Save to notes',
          color: text3,
          onTap: () => _saveToNotes(context, ref),
        ),
        const SizedBox(width: 4),
        _IconAction(
          icon: Icons.ios_share_outlined,
          tooltip: 'Share',
          color: text3,
          onTap: () => Share.share(text),
        ),
        if (onRegenerate != null) ...[
          const SizedBox(width: 4),
          _IconAction(
            icon: Icons.refresh_rounded,
            tooltip: 'Regenerate',
            color: text3,
            onTap: onRegenerate!,
          ),
        ],
      ],
    );
  }

  /// Appends this AI reply to the verse's personal notes (a timestamped
  /// snippet), so the user can revisit the explanation alongside the
  /// verse itself. Existing note text is preserved.
  Future<void> _saveToNotes(BuildContext context, WidgetRef ref) async {
    try {
      final repo = await ref.read(scriptureRepositoryProvider.future);
      final existing = await repo.getVerseById(verseId);
      final prior = existing.fold((_) => '', (v) => v.noteText ?? '');
      final stamp = DateTime.now().toIso8601String().substring(0, 10);
      final merged =
          mergeAiReplyIntoNote(prior: prior, reply: text, stamp: stamp);
      await repo.updateVerseNote(verseId, merged);
      if (context.mounted) showHeritageToast(context, 'Saved to verse notes');
    } catch (_) {
      if (context.mounted) showHeritageToast(context, 'Could not save note');
    }
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 16,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _RetryPill extends StatelessWidget {
  const _RetryPill({required this.isDark, required this.onTap});

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final glow = isDark ? DColors.saffronGlow : LColors.saffronGlow;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: glow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: saffron.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 14, color: saffron),
            const SizedBox(width: 6),
            Text(
              'RETRY',
              style: TextStyle(
                fontFamily: Fonts.sans,
                fontFamilyFallback: AppFontFallback.latin,
                fontSize: 12,
                height: 1.2,
                color: saffron,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.08 * 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Input bar ──────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.remaining,
    required this.loading,
    required this.isDark,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int remaining;
  final bool loading;
  final bool isDark;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final text3 = isDark ? DColors.text3 : LColors.text3;
    final dividerSoft = isDark ? DColors.dividerSoft : LColors.dividerSoft;

    if (remaining <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerSoft)),
        ),
        child: SafeArea(
          top: false,
          child: Text(
            'Daily question limit reached — resets at midnight.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: Fonts.sans,
              fontFamilyFallback: AppFontFallback.latin,
              fontSize: 12,
              height: 1.4,
              color: text3,
            ),
          ),
        ),
      );
    }

    final surface = isDark ? DColors.surface : LColors.surface;
    final surface2 = isDark ? DColors.surface2 : LColors.surface2;
    final saffron = isDark ? DColors.saffron : LColors.saffron;
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final canSend = !loading && controller.text.trim().isNotEmpty;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        bottom: bottomInset == 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      enabled: !loading,
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Ask about this verse…',
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
                loading: loading,
                onTap: canSend ? onSend : null,
                surface2: surface2,
                saffron: saffron,
                text3: text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.isDark,
    required this.enabled,
    required this.loading,
    required this.onTap,
    required this.surface2,
    required this.saffron,
    required this.text3,
  });

  final bool isDark;
  final bool enabled;
  final bool loading;
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
          child: loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark ? const Color(0xFF1A1208) : saffron,
                  ),
                )
              : SizedBox(
                  width: 18,
                  height: 18,
                  child: CustomPaint(
                    painter: _PaperPlanePainter(color: glyphColor),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Paper plane `M3 9l13-6-4 13-3-6-6-1z`, sw 1.6 — shared with general chat.
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

/// Appends [reply] to [prior] note text with a dated separator block.
/// Empty / whitespace-only [prior] yields the reply alone. Trailing
/// whitespace on the prior text is trimmed so successive saves don't
/// leak blank lines.
String mergeAiReplyIntoNote({
  required String prior,
  required String reply,
  required String stamp,
}) {
  final separator = prior.trim().isEmpty ? '' : '\n\n— $stamp —\n';
  return '${prior.trimRight()}$separator${reply.trim()}';
}
