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
    return Material(
      color: NeonColors.cyan.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: NeonColors.deepSpace, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.exo2(
                  color: NeonColors.deepSpace,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpen,
              style: TextButton.styleFrom(
                foregroundColor: NeonColors.deepSpace,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('AI'),
            ),
            IconButton(
              tooltip: 'Nascondi suggerimento',
              onPressed: onDismiss,
              icon: const Icon(Icons.close, color: NeonColors.deepSpace, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
