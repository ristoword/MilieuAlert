import 'dart:async';

import 'package:flutter/material.dart';

/// One-shot map alert: show at most one banner, then hide it.
class TransientAlert {
  const TransientAlert({
    required this.id,
    required this.priority,
    required this.child,
  });

  final String id;
  final int priority;
  final Widget child;
}

/// Flashes the highest-priority new alert for [duration], then clears the
/// map. Does not stack. The same [TransientAlert.id] will not reappear until
/// it leaves the candidate list (e.g. leaving a zone, passing a camera).
class TransientAlertSlot extends StatefulWidget {
  const TransientAlertSlot({
    super.key,
    required this.candidates,
    this.duration = const Duration(seconds: 2),
  });

  final List<TransientAlert> candidates;
  final Duration duration;

  @override
  State<TransientAlertSlot> createState() => _TransientAlertSlotState();
}

class _TransientAlertSlotState extends State<TransientAlertSlot> {
  final Set<String> _consumed = {};
  String? _showingId;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _armBest();
  }

  @override
  void didUpdateWidget(TransientAlertSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    _prune();
    if (_showingId != null &&
        !widget.candidates.any((c) => c.id == _showingId)) {
      _timer?.cancel();
      _showingId = null;
    }
    _armBest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prune() {
    final live = {for (final c in widget.candidates) c.id};
    _consumed.removeWhere((id) => !live.contains(id));
  }

  TransientAlert? _bestUnconsumed() {
    TransientAlert? best;
    for (final c in widget.candidates) {
      if (_consumed.contains(c.id)) continue;
      if (best == null || c.priority > best.priority) best = c;
    }
    return best;
  }

  TransientAlert? _current() {
    final id = _showingId;
    if (id == null) return null;
    for (final c in widget.candidates) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _armBest() {
    final best = _bestUnconsumed();
    if (best == null) return;
    if (best.id == _showingId) return;

    final current = _current();
    if (current != null && best.priority <= current.priority) return;

    if (current != null) {
      _consumed.add(current.id);
    }
    _timer?.cancel();
    _showingId = best.id;
    _timer = Timer(widget.duration, _expireWave);
  }

  /// Hide the banner and skip every alert that was already on screen so they
  /// never stack as a queue of chips.
  void _expireWave() {
    if (!mounted) return;
    for (final c in widget.candidates) {
      _consumed.add(c.id);
    }
    if (_showingId != null) _consumed.add(_showingId!);
    setState(() => _showingId = null);
  }

  @override
  Widget build(BuildContext context) {
    final showing = _current();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: showing == null
          ? const SizedBox.shrink(key: ValueKey('transient-empty'))
          : KeyedSubtree(
              key: ValueKey(showing.id),
              child: showing.child,
            ),
    );
  }
}
