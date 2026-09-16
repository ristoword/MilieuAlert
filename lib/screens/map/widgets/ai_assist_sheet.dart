import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../providers/ai_assist_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../services/ai_fallback.dart';

Future<void> showAiAssistSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NeonColors.darkCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const AiAssistSheet(),
  );
}

class AiAssistSheet extends ConsumerStatefulWidget {
  const AiAssistSheet({super.key});

  @override
  ConsumerState<AiAssistSheet> createState() => _AiAssistSheetState();
}

class _AiAssistSheetState extends ConsumerState<AiAssistSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiAssistProvider.notifier).ensureWelcome();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await ref.read(aiAssistProvider.notifier).send(text);
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ai = ref.watch(aiAssistProvider);
    final nav = ref.watch(navigationProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final height = MediaQuery.of(context).size.height * 0.72;
    final chips = _chips(nav);

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: NeonColors.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Assistente AI',
                      style: GoogleFonts.exo2(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Chiudi',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  nav.hasRoute
                      ? 'Ti guido sul percorso: zone, autovelox, alternative.'
                      : 'Niente percorso ancora: chiedimi zone vicine o “portami a casa”.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final chip = chips[i];
                  return ActionChip(
                    onPressed: ai.loading ? null : () => _send(chip),
                    backgroundColor: NeonColors.darkSurface,
                    side: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.45)),
                    label: Text(
                      chip,
                      style: GoogleFonts.exo2(
                        color: NeonColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                itemCount: ai.messages.length + (ai.loading ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i >= ai.messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: NeonColors.cyan,
                          ),
                        ),
                      ),
                    );
                  }
                  final msg = ai.messages[i];
                  return _Bubble(message: msg);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      obscureText: false,
                      maxLines: 1,
                      enabled: !ai.loading,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: NeonColors.cyan,
                      decoration: InputDecoration(
                        hintText: 'Chiedi di zone, percorso, avvisi…',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0B0B1C),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: NeonColors.cyan.withValues(alpha: 0.35),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: NeonColors.cyan.withValues(alpha: 0.35),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: NeonColors.cyan),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: ai.loading ? null : () => _send(),
                    style: IconButton.styleFrom(
                      backgroundColor: NeonColors.cyan,
                      foregroundColor: NeonColors.deepSpace,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _chips(NavigationState nav) {
    return [
      if (nav.hasRoute) 'Riassumi il percorso',
      'Ci sono zone?',
      'Prossimo autovelox',
      'Il veicolo può entrare?',
      if (nav.alternatives.length > 1) 'Itinerario alternativo',
      'Portami a casa',
    ];
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});
  final AiChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.fromUser;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: mine
              ? NeonColors.cyan.withValues(alpha: 0.2)
              : NeonColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: mine
                ? NeonColors.cyan.withValues(alpha: 0.7)
                : Colors.white24,
          ),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.exo2(
            color: Colors.white,
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
