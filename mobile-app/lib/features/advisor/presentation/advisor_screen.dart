import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/formatters.dart';
import '../../crops/data/crop_repository.dart';
import '../data/advisor_repository.dart';

@immutable
class ChatMessage {
  const ChatMessage({required this.text, required this.fromUser, this.failed = false});

  final String text;
  final bool fromUser;
  final bool failed;
}

@immutable
class AdvisorState {
  const AdvisorState({this.messages = const [], this.thinking = false});

  final List<ChatMessage> messages;
  final bool thinking;
}

/// Not auto-disposed: the conversation survives switching tabs.
final advisorControllerProvider = NotifierProvider<AdvisorController, AdvisorState>(AdvisorController.new);

class AdvisorController extends Notifier<AdvisorState> {
  @override
  AdvisorState build() => const AdvisorState();

  Future<void> ask(String question) async {
    final q = question.trim();
    if (q.isEmpty || state.thinking) return;
    state = AdvisorState(messages: [...state.messages, ChatMessage(text: q, fromUser: true)], thinking: true);

    ChatMessage reply;
    try {
      // Context comes from the crop list the app already has, so the farmer
      // never types "I grow paddy in Polonnaruwa" before every question.
      final crops = await ref.read(cropsProvider.future).catchError((Object _) => const <Never>[]);
      final answer = await ref.read(advisorRepositoryProvider).ask(q, crops: crops);
      reply = ChatMessage(text: answer, fromUser: false);
    } on ApiException catch (e) {
      reply = ChatMessage(text: e.message, fromUser: false, failed: true);
    }
    state = AdvisorState(messages: [...state.messages, reply]);
  }
}

class AdvisorScreen extends ConsumerStatefulWidget {
  const AdvisorScreen({super.key});

  @override
  ConsumerState<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends ConsumerState<AdvisorScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final question = text ?? _input.text;
    if (question.trim().isEmpty) return;
    _input.clear();
    FocusScope.of(context).unfocus();
    await ref.read(advisorControllerProvider.notifier).ask(question);
    if (_scroll.hasClients) {
      await _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(advisorControllerProvider);
    final online = ref.watch(advisorOnlineProvider).valueOrNull;
    final suggestions = [l10n.suggestionFertilizer, l10n.suggestionPests, l10n.suggestionWater, l10n.suggestionProfit];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.advisorTitle),
        actions: [
          if (online != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                avatar: Icon(Icons.circle, size: 10, color: online ? Colors.green : Colors.grey),
                label: Text(online ? l10n.advisorOnline : l10n.advisorOffline),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Icon(Icons.support_agent, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(l10n.advisorIntro, textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final s in suggestions) ActionChip(label: Text(s), onPressed: () => _send(s)),
                        ],
                      ),
                    ],
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: state.messages.length + (state.thinking ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (state.thinking && i == 0) {
                        return _Bubble(ChatMessage(text: l10n.advisorThinking, fromUser: false), pending: true);
                      }
                      final index = state.messages.length - 1 - (state.thinking ? i - 1 : i);
                      return _Bubble(state.messages[index]);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 92),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(hintText: l10n.askHint, counterText: ''),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l10n.send,
                    onPressed: state.thinking ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.message, {this.pending = false});

  final ChatMessage message;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = message.fromUser;
    final background = mine
        ? scheme.primary
        : message.failed
            ? scheme.errorContainer
            : scheme.surfaceContainerHigh;
    final foreground = mine
        ? scheme.onPrimary
        : message.failed
            ? scheme.onErrorContainer
            : scheme.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: pending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: foreground)),
                  const SizedBox(width: 8),
                  Text(message.text, style: TextStyle(color: foreground)),
                ],
              )
            : SelectableText(message.text, style: TextStyle(color: foreground, height: 1.35)),
      ),
    );
  }
}
