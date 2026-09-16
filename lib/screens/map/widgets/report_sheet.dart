import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/hazard_strings.dart';
import '../../../models/hazard_report.dart';
import '../../../providers/hazard_provider.dart';
import '../../../providers/location_provider.dart';

Future<void> showHazardReportSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ReportSheet(),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet();

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  HazardType? _type;
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final type = _type;
    final loc = ref.read(locationProvider);
    final l10n = HazardStrings.of(context);
    if (type == null) return;
    if (loc.latitude == null || loc.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.needLocation)),
      );
      return;
    }
    setState(() => _busy = true);
    final report = await ref.read(hazardProvider.notifier).submit(
          type: type,
          lat: loc.latitude!,
          lon: loc.longitude!,
          heading: loc.heading,
          note: _note.text,
        );
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(report == null ? l10n.needLocation : l10n.reported),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = HazardStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final types = HazardType.values;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: MapsGlass(
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.reportTitle,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in types)
                    ChoiceChip(
                      selected: _type == t,
                      label: Text(l10n.label(t)),
                      avatar: Icon(hazardIcon(t), size: 16),
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLength: 140,
                decoration: InputDecoration(
                  hintText: l10n.noteHint,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _busy || _type == null ? null : _submit,
                child: Text(_busy ? '...' : l10n.send),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData hazardIcon(HazardType type) {
  switch (type) {
    case HazardType.cameraFixed:
      return Icons.videocam;
    case HazardType.cameraMobile:
      return Icons.videocam_outlined;
    case HazardType.accident:
      return Icons.car_crash;
    case HazardType.jam:
      return Icons.traffic;
    case HazardType.police:
      return Icons.local_police;
    case HazardType.roadClosed:
      return Icons.block;
    case HazardType.lezExtra:
      return Icons.shield;
  }
}

Color hazardColor(HazardType type) {
  switch (type) {
    case HazardType.cameraFixed:
      return const Color(0xFFFF9F0A);
    case HazardType.cameraMobile:
      return const Color(0xFFFF3B30);
    case HazardType.accident:
      return MapsColors.endRed;
    case HazardType.jam:
      return const Color(0xFFFF9F0A);
    case HazardType.police:
      return const Color(0xFF007AFF);
    case HazardType.roadClosed:
      return const Color(0xFF8E8E93);
    case HazardType.lezExtra:
      return MapsColors.accent;
  }
}
