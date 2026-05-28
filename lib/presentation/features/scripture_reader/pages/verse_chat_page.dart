import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/home/providers/verse_of_day_provider.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/ai_rich_prose.dart';
import 'package:sanatan_guide/presentation/shared/widgets/heritage_states.dart';
import 'package:sanatan_guide/presentation/shared/widgets/mockup_icons.dart';
import 'package:sanatan_guide/presentation/shared/widgets/offline_banner.dart';
import 'package:sanatan_guide/presentation/shared/widgets/warm_backdrop.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';
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
      setState(() => _error =
          'Daily limit reached (${GeminiRateLimit.maxPerDay} questions/day). Try again tomorrow.');
      return;
    }

    final allowed = await GeminiRateLimit.consume();
    if (!allowed) {
      setState(() {
        _error = 'Daily limit reached. Try again tomorrow.';
        _remaining = 0;
      });
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _loading = true;
      _error = null;
      _remaining--;
    });
    _scrollToBottom();

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
              "Couldn't reach the Pandit. Check your connection and try again.";
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
    final text1 = isDark ? DColors.text1 : LColors.text1;
    final text3 = isDark ? DColors.text3 : LColors.text3;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const MockupBackChevron(),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
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
              '$_remaining question${_remaining == 1 ? '' : 's'} remaining today',
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
        centerTitle: false,
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const WarmBackdrop(),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.paddingOf(context).top,
              ),
              child: Column(
                children: [
                  const OfflineBanner(),
                  Expanded(
                    child: state.when(
                      loading: () => const VerseDetailShimmer(),
                      error: (_, __) => HeritageError(
                        message: 'Could not load this verse — pull down or retry.',
                        onRetry: () =>
                            ref.invalidate(verseDetailProvider(widget.verseId)),
                      ),
                      data: (either) => either.fold(
                        (failure) => HeritageError(message: failure.message),
                        (verse) => _ChatMessages(
                          verse: verse,
                          messages: _messages,
                          loading: _loading,
                          error: _error,
                          scrollController: _scrollController,
                          onRegenerate: () => _regenerate(verse),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: state
          .whenData((either) => either.fold(
                (_) => null,
                (verse) => _InputBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  remaining: _remaining,
                  loading: _loading,
                  onSend: () => _send(verse),
                ),
              ))
          .value,
    );
  }
}

// ── Chat messages (body only — input bar is in Scaffold.bottomNavigationBar) ──

class _ChatMessages extends StatelessWidget {
  const _ChatMessages({
    required this.verse,
    required this.messages,
    required this.loading,
    required this.error,
    required this.scrollController,
    required this.onRegenerate,
  });

  final Verse verse;
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final ScrollController scrollController;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Verse context pill ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.sm,
          ),
          color: isDark ? AppColors.surfaceDark : AppColors.warmGrey10,
          child: Text(
            verse.sanskrit.split('\n').first.trim(),
            style: context.ts.sanskritSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // ── Messages ────────────────────────────────────────────────────
        Expanded(
          child: messages.isEmpty && !loading
              ? _WelcomePrompt(verse: verse)
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                  ),
                  itemCount: messages.length + (loading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const _TypingBubble();
                    }
                    final m = messages[index];
                    // Regenerate is only meaningful on the most recent AI
                    // reply (re-running an older reply would invalidate the
                    // conversation history). Pass the callback only for that
                    // bubble; bubble hides the icon when the callback is null.
                    final isLastAi =
                        !m.isUser && !loading && index == messages.length - 1;
                    return _MessageBubble(
                      message: m,
                      verseId: verse.id,
                      onRegenerate: isLastAi ? onRegenerate : null,
                    );
                  },
                ),
        ),

        // ── Error banner ────────────────────────────────────────────────
        if (error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.error.withValues(alpha: 0.08),
            child: Text(
              error!,
              style: context.ts.caption.copyWith(color: AppColors.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

// ── Welcome state ─────────────────────────────────────────────────────────

class _WelcomePrompt extends StatelessWidget {
  const _WelcomePrompt({required this.verse});
  final Verse verse;

  static const _starters = [
    'What does this verse mean?',
    'What is the context of this verse?',
    'How can I apply this teaching today?',
    'What are the key Sanskrit terms here?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask anything about this verse',
            style: context.ts.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Context, meaning, application, Sanskrit terms — the guide will help.',
            style: context.ts.caption,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('SUGGESTED QUESTIONS', style: context.ts.sectionLabel),
          const SizedBox(height: AppSpacing.md),
          ..._starters.map(
            (q) => _StarterChip(label: q),
          ),
        ],
      ),
    );
  }
}

class _StarterChip extends StatelessWidget {
  const _StarterChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Find ancestor VerseChatPage state via nearest ConsumerStatefulWidget
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          // Bubble up via nearest _VerseChatPageState
          final state = context.findAncestorStateOfType<_VerseChatPageState>();
          state?._controller.text = label;
          state?._focusNode.requestFocus();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Text(label, style: context.ts.bodyMedium),
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.verseId,
    this.onRegenerate,
  });
  final ChatMessage message;
  final String verseId;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.saffronFaint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'ॐ',
                style: TextStyle(
                  fontFamily: 'TiroDevanagari',
                  fontSize: 14,
                  color: AppColors.saffron,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.saffron
                    : isDark
                        ? AppColors.surfaceDark
                        : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppSpacing.radiusCard),
                  topRight: const Radius.circular(AppSpacing.radiusCard),
                  bottomLeft: Radius.circular(
                      isUser ? AppSpacing.radiusCard : AppSpacing.radiusRow),
                  bottomRight: Radius.circular(
                      isUser ? AppSpacing.radiusRow : AppSpacing.radiusCard),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: context.ts.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AiRichProse(
                          isDark: isDark,
                          text: message.text,
                          // Verse-anchored chat uses non-italic prose per
                          // screen-09 (commentary tone) vs general-chat
                          // italic.
                          italic: false,
                          fontSize: 14,
                          height: 1.5,
                          horizontalPadding: 0,
                        ),
                        const SizedBox(height: 6),
                        _AiActionRow(
                          text: message.text,
                          isDark: isDark,
                          verseId: verseId,
                          onRegenerate: onRegenerate,
                        ),
                      ],
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 28 + AppSpacing.sm),
        ],
      ),
    );
  }
}

/// Three small icon buttons under each AI reply — copy, share, regenerate
/// — per screen-10 design. Regenerate is wired as a no-op stub for now;
/// the cleanest implementation needs the parent to re-call _send with the
/// matching user prompt, which lives a state lift away from here.
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
    final text3 =
        isDark ? AppColors.textSecondaryOnDark : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.copy_outlined,
          tooltip: 'Copy',
          color: text3,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: text));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
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
      final merged = mergeAiReplyIntoNote(prior: prior, reply: text, stamp: stamp);
      await repo.updateVerseNote(verseId, merged);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved to verse notes'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save note'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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

// ── Typing indicator ──────────────────────────────────────────────────────

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.saffronFaint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'ॐ',
              style: TextStyle(
                fontFamily: 'TiroDevanagari',
                fontSize: 14,
                color: AppColors.saffron,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusCard),
                topRight: Radius.circular(AppSpacing.radiusCard),
                bottomLeft: Radius.circular(AppSpacing.radiusRow),
                bottomRight: Radius.circular(AppSpacing.radiusCard),
              ),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: SizedBox(
              width: 40,
              height: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (i) => _Dot(delayMs: i * 160),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot({required this.delayMs});
  final int delayMs;

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.warmGrey50,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.remaining,
    required this.loading,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int remaining;
  final bool loading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSend = remaining > 0 && !loading;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        bottom: bottomInset == 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: context.ts.bodyMedium,
                  textInputAction: TextInputAction.send,
                  maxLines: 3,
                  minLines: 1,
                  enabled: canSend,
                  decoration: InputDecoration(
                    hintText: remaining > 0
                        ? 'Ask about this verse…'
                        : 'Daily limit reached',
                    hintStyle: context.ts.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                    // Field sits in a custom pill — strip the global
                    // inputDecorationTheme (filled:true + bordered).
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: canSend ? onSend : null,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.saffron,
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: canSend
                            ? AppColors.saffron
                            : AppColors.textSecondary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
