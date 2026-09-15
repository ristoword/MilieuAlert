import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'pwa_install.dart';

class InstallAppButton extends StatefulWidget {
  const InstallAppButton({
    super.key,
    this.compact = false,
    this.neon = false,
  });

  final bool compact;
  final bool neon;

  @override
  State<InstallAppButton> createState() => _InstallAppButtonState();
}

class _InstallAppButtonState extends State<InstallAppButton> {
  bool _busy = false;
  bool _installed = false;

  @override
  void initState() {
    super.initState();
    _installed = pwaIsStandalone();
  }

  Future<void> _install() async {
    if (_busy || _installed) return;
    setState(() => _busy = true);
    final result = await promptPwaInstall();
    if (!mounted) return;
    setState(() => _busy = false);

    if (result == PwaInstallResult.accepted) {
      setState(() => _installed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MilieuAlert is being installed')),
      );
      return;
    }

    if (result == PwaInstallResult.dismissed) return;
    if (!mounted) return;
    await _showFallbackDialog();
  }

  Future<void> _showFallbackDialog() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NeonColors.darkCard,
        title: Text(
          'Install MilieuAlert on this PC',
          style: GoogleFonts.exo2(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'This browser cannot auto-install the app.\n\n'
            'Microsoft Edge: menu (⋯) → Apps → Install this site as an app.\n\n'
            'Google Chrome: menu (⋮) → Cast, save, and share → Install page as app, or use the install icon in the address bar.\n\n'
            'Any browser: download a desktop shortcut or a launcher HTML file, then double-click it to open MilieuAlert.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: downloadPwaShortcut,
            child: const Text('Download shortcut'),
          ),
          TextButton(
            onPressed: downloadPwaLauncher,
            child: const Text('Download launcher'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _installed) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return Material(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _busy ? null : _install,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download,
                  size: 16,
                  color: NeonColors.cyan,
                ),
                const SizedBox(width: 6),
                Text(
                  _busy ? '…' : 'Install',
                  style: GoogleFonts.exo2(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _install,
        icon: Icon(widget.neon ? Icons.install_desktop : Icons.download),
        label: Text(
          _busy ? 'Installing…' : 'Install / Download',
          style: GoogleFonts.exo2(fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: NeonColors.cyan,
          side: BorderSide(color: NeonColors.cyan.withValues(alpha: 0.8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
