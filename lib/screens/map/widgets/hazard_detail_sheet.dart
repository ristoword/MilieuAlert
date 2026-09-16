import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/hazard_strings.dart';
import '../../../models/hazard_report.dart';
import '../../../models/zone_status.dart';
import '../../../providers/hazard_provider.dart';
import 'report_sheet.dart';

Future<void> showHazardFeedSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const HazardFeedSheet(),
  );
}

Future<void> showHazardDetailSheet(BuildContext context, HazardReport report) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => HazardDetailSheet(report: report),
  );
}

class HazardFeedSheet extends ConsumerWidget {
  const HazardFeedSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = HazardStrings.of(context);
    final reports = ref.watch(hazardProvider).reports;
    return MapsGlass(
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.nearbyFeed,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: reports.isEmpty
                    ? Center(child: Text(l10n.noReports))
                    : ListView.separated(
                        itemCount: reports.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final r = reports[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  hazardColor(r.type).withValues(alpha: 0.18),
                              child: Icon(
                                hazardIcon(r.type),
                                color: hazardColor(r.type),
                              ),
                            ),
                            title: Text(l10n.label(r.type)),
                            subtitle: Text(
                              '${l10n.aDriver} · ${l10n.timeAgo(r.createdAt)}'
                              '${r.distanceMeters == null ? '' : ' · ${formatDistance(r.distanceMeters)}'}',
                            ),
                            onTap: () => showHazardDetailSheet(context, r),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HazardDetailSheet extends ConsumerStatefulWidget {
  const HazardDetailSheet({super.key, required this.report});

  final HazardReport report;

  @override
  ConsumerState<HazardDetailSheet> createState() => _HazardDetailSheetState();
}

class _HazardDetailSheetState extends ConsumerState<HazardDetailSheet> {
  final _comment = TextEditingController();
  List<HazardComment> _comments = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list =
        await ref.read(hazardProvider.notifier).comments(widget.report.id);
    if (!mounted) return;
    setState(() {
      _comments = list;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = HazardStrings.of(context);
    final live = ref.watch(hazardProvider).reports.firstWhere(
          (r) => r.id == widget.report.id,
          orElse: () => widget.report,
        );
    final hint = l10n.unofficialHint(live.type);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: MapsGlass(
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(hazardIcon(live.type), color: hazardColor(live.type)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.label(live.type),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${l10n.aDriver} · ${l10n.timeAgo(live.createdAt)}',
                style: GoogleFonts.inter(color: MapsColors.inkMuted),
              ),
              if (hint.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(hint, style: GoogleFonts.inter(fontSize: 13)),
                ),
              if (live.note != null && live.note!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(live.note!),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(hazardProvider.notifier)
                          .vote(live.id, 'confirm'),
                      child: Text('${l10n.stillThere} (${live.confirmCount})'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: MapsColors.endRed,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await ref
                            .read(hazardProvider.notifier)
                            .vote(live.id, 'deny');
                        if (!context.mounted) return;
                        final stillThere = ref
                            .read(hazardProvider)
                            .reports
                            .any((r) => r.id == live.id);
                        if (!stillThere) Navigator.of(context).pop();
                      },
                      child: Text('${l10n.doesNotExist} (${live.denyCount})'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 160),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final c in _comments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '${c.author} · ${l10n.timeAgo(c.createdAt)}\n${c.text}',
                            style: GoogleFonts.inter(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _comment,
                      maxLength: 140,
                      decoration: InputDecoration(
                        hintText: l10n.commentHint,
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final text = _comment.text.trim();
                      if (text.length < 2) return;
                      final added = await ref
                          .read(hazardProvider.notifier)
                          .addComment(live.id, text);
                      if (added == null || !mounted) return;
                      _comment.clear();
                      setState(() => _comments = [added, ..._comments]);
                    },
                    icon: const Icon(Icons.send),
                    tooltip: l10n.commentSend,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
