import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanatan_guide/core/extensions/typography_extensions.dart';
import 'package:sanatan_guide/core/services/gemini_service.dart';
import 'package:sanatan_guide/core/utils/verse_label.dart';
import 'package:sanatan_guide/domain/entities/scripture.dart';
import 'package:sanatan_guide/domain/entities/verse.dart';
import 'package:sanatan_guide/presentation/features/scripture_reader/providers/verse_detail_provider.dart';
import 'package:sanatan_guide/presentation/shared/widgets/sacred_ornaments.dart';
import 'package:sanatan_guide/presentation/shared/widgets/shimmer_loading.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_spacing.dart';

class VerseChatPage extends ConsumerStatefulWidget {
  const VerseChatPage({super.key, required this.verseId});
  final String verseId;

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

  Future<void> _send(Verse verse) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    if (_remaining <= 0) {
      setState(() => _error = 'Daily limit reached (${GeminiRateLimit.maxPerDay} questions/day). Try again tomorrow.');
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
          _error = 'Something went wrong. Please try again.';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verseDetailProvider(widget.verseId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ask about this verse', style: context.ts.labelLarge),
            Text(
              '$_remaining question${_remaining == 1 ? '' : 's'} remaining today',
              style: context.ts.caption,
            ),
          ],
        ),
        centerTitle: false,
        flexibleSpace: const IgnorePointer(
          child: DhyanaAsanaBackdrop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: state.when(
        loading: () => const VerseDetailShimmer(),
        error: (_, __) => const Center(child: Text('Could not load verse.')),
        data: (either) => either.fold(
          (failure) => Center(child: Text(failure.message)),
          (verse) => _ChatMessages(
            verse: verse,
            messages: _messages,
            loading: _loading,
            error: _error,
            scrollController: _scrollController,
          ),
        ),
      ),
      bottomNavigationBar: state.whenData((either) => either.fold(
        (_) => null,
        (verse) => _InputBar(
          controller: _controller,
          focusNode: _focusNode,
          remaining: _remaining,
          loading: _loading,
          onSend: () => _send(verse),
        ),
      )).value,
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
  });

  final Verse verse;
  final List<ChatMessage> messages;
  final bool loading;
  final String? error;
  final ScrollController scrollController;

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
                    return _MessageBubble(message: messages[index]);
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
          final state = context
              .findAncestorStateOfType<_VerseChatPageState>();
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
  const _MessageBubble({required this.message});
  final ChatMessage message;

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
                        color:
                            isDark ? AppColors.borderDark : AppColors.border,
                      ),
              ),
              child: Text(
                message.text,
                style: context.ts.bodyMedium.copyWith(
                  color: isUser ? Colors.white : null,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 28 + AppSpacing.sm),
        ],
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
                  border: InputBorder.none,
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
