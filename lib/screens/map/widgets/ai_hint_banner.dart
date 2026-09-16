import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../services/ai_fallback.dart';

class AiHintBanner extends StatelessWidget {
  const AiHintBanner({
    super.key,
    required this.hint,
    required this.onDismiss,
    required this.onOpen,
  });

  final AiHint hint;
  final VoidCallback onDismiss;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MapsGlass(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 2, 8),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: MapsColors.accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : MapsColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                foregroundColor: MapsColors.accent,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('AI'),
            ),
            IconButton(
              tooltip: 'Nascondi suggerimento',
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: isDark ? Colors.white54 : MapsColors.inkMuted,
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
