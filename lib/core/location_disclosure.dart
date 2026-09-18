import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';

/// Play-required prominent disclosure before the system location prompt.
/// Returns true if the user chose to continue, false if they denied.
Future<bool> showLocationDisclosure(BuildContext context) async {
  final l10n = l10nOf(context);
  final accepted = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.locationDisclosureTitle),
        content: SingleChildScrollView(
          child: Text(l10n.locationDisclosureBody),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.locationDisclosureDeny),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.locationDisclosureContinue),
          ),
        ],
      );
    },
  );
  return accepted == true;
}
