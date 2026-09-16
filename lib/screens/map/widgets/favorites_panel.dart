import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../models/navigation_models.dart';
import '../../../models/saved_places.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../services/navigation_service.dart';

class SavedPlacesQuickBar extends ConsumerWidget {
  const SavedPlacesQuickBar({
    super.key,
    required this.onPlaceTap,
    required this.onAddSuggested,
    required this.onManagePlaces,
    required this.onOpenItineraries,
  });

  final ValueChanged<SavedPlace> onPlaceTap;
  final ValueChanged<String> onAddSuggested;
  final VoidCallback onManagePlaces;
  final VoidCallback onOpenItineraries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider);
    final custom = fav.places
        .where(
          (p) => !kSuggestedPlaceLabels.any(
            (s) => s.toLowerCase() == p.label.trim().toLowerCase(),
          ),
        )
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final label in kSuggestedPlaceLabels)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PlaceChip(
                      label: label,
                      icon: label.toLowerCase() == 'casa'
                          ? Icons.home_rounded
                          : Icons.work_rounded,
                      saved: fav.placeByLabel(label),
                      onTap: () {
                        final place = fav.placeByLabel(label);
                        if (place == null) {
                          onAddSuggested(label);
                        } else {
                          onPlaceTap(place);
                        }
                      },
                    ),
                  ),
                for (final place in custom)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _PlaceChip(
                      label: place.label,
                      icon: Icons.place_rounded,
                      saved: place,
                      onTap: () => onPlaceTap(place),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    onPressed: onManagePlaces,
                    backgroundColor: NeonColors.darkSurface,
                    side: BorderSide(
                      color: NeonColors.cyan.withValues(alpha: 0.45),
                    ),
                    avatar: const Icon(
                      Icons.add_location_alt_outlined,
                      size: 16,
                      color: NeonColors.cyan,
                    ),
                    label: Text(
                      'Luoghi',
                      style: GoogleFonts.exo2(
                        color: NeonColors.cyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onOpenItineraries,
              icon: const Icon(Icons.star_rounded, color: NeonColors.pink),
              label: Text(
                'Itinerari preferiti',
                style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceChip extends StatelessWidget {
  const _PlaceChip({
    required this.label,
    required this.icon,
    required this.saved,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final SavedPlace? saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final filled = saved != null;
    return ActionChip(
      onPressed: onTap,
      backgroundColor: filled
          ? NeonColors.cyan.withValues(alpha: 0.16)
          : NeonColors.darkSurface,
      side: BorderSide(
        color: filled
            ? NeonColors.cyan.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.2),
      ),
      avatar: Icon(
        filled ? icon : Icons.add,
        size: 16,
        color: filled ? NeonColors.cyan : Colors.white70,
      ),
      label: Text(
        filled ? label : '$label +',
        style: GoogleFonts.exo2(
          color: filled ? NeonColors.cyan : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<SearchField?> pickAddressField(BuildContext context) {
  return showModalBottomSheet<SearchField>(
    context: context,
    backgroundColor: NeonColors.darkCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Inserisci in',
                style: GoogleFonts.exo2(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.trip_origin, color: NeonColors.neonGreen),
                title: Text(
                  'Partenza (A)',
                  style: GoogleFonts.exo2(color: Colors.white),
                ),
                onTap: () => Navigator.pop(ctx, SearchField.origin),
              ),
              ListTile(
                leading: const Icon(Icons.flag, color: NeonColors.pink),
                title: Text(
                  'Destinazione (B)',
                  style: GoogleFonts.exo2(color: Colors.white),
                ),
                onTap: () => Navigator.pop(ctx, SearchField.destination),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showFavoritesHub({
  required BuildContext context,
  required int initialTab,
  PlaceHit? currentOrigin,
  PlaceHit? currentDestination,
  String? prefillLabel,
  required ValueChanged<SavedPlace> onApplyPlace,
  required ValueChanged<FavoriteItinerary> onApplyItinerary,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: NeonColors.darkCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FavoritesHubSheet(
      initialTab: initialTab,
      currentOrigin: currentOrigin,
      currentDestination: currentDestination,
      prefillLabel: prefillLabel,
      onApplyPlace: onApplyPlace,
      onApplyItinerary: onApplyItinerary,
    ),
  );
}

class FavoritesHubSheet extends ConsumerStatefulWidget {
  const FavoritesHubSheet({
    super.key,
    required this.initialTab,
    this.currentOrigin,
    this.currentDestination,
    this.prefillLabel,
    required this.onApplyPlace,
    required this.onApplyItinerary,
  });

  final int initialTab;
  final PlaceHit? currentOrigin;
  final PlaceHit? currentDestination;
  final String? prefillLabel;
  final ValueChanged<SavedPlace> onApplyPlace;
  final ValueChanged<FavoriteItinerary> onApplyItinerary;

  @override
  ConsumerState<FavoritesHubSheet> createState() => _FavoritesHubSheetState();
}

class _FavoritesHubSheetState extends ConsumerState<FavoritesHubSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _showEditor = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _showEditor = widget.prefillLabel != null && widget.initialTab == 0;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fav = ref.watch(favoritesProvider);
    final media = MediaQuery.of(context);
    final height = media.size.height * 0.72;
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Luoghi e itinerari',
                    style: GoogleFonts.exo2(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabs,
            indicatorColor: NeonColors.cyan,
            labelColor: NeonColors.cyan,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.exo2(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Luoghi salvati'),
              Tab(text: 'Itinerari preferiti'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _PlacesTab(
                  places: fav.places,
                  showEditor: _showEditor,
                  prefillLabel: widget.prefillLabel,
                  currentOrigin: widget.currentOrigin,
                  currentDestination: widget.currentDestination,
                  onToggleEditor: (v) => setState(() => _showEditor = v),
                  onApply: (place) {
                    Navigator.pop(context);
                    widget.onApplyPlace(place);
                  },
                ),
                _ItinerariesTab(
                  trips: fav.itineraries,
                  onApply: (trip) {
                    Navigator.pop(context);
                    widget.onApplyItinerary(trip);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PlacesTab extends StatelessWidget {
  const _PlacesTab({
    required this.places,
    required this.showEditor,
    required this.prefillLabel,
    required this.currentOrigin,
    required this.currentDestination,
    required this.onToggleEditor,
    required this.onApply,
  });

  final List<SavedPlace> places;
  final bool showEditor;
  final String? prefillLabel;
  final PlaceHit? currentOrigin;
  final PlaceHit? currentDestination;
  final ValueChanged<bool> onToggleEditor;
  final ValueChanged<SavedPlace> onApply;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (showEditor)
          _PlaceEditor(
            initial: null,
            prefillLabel: prefillLabel,
            currentOrigin: currentOrigin,
            currentDestination: currentDestination,
            onDone: () => onToggleEditor(false),
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => onToggleEditor(true),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi luogo'),
              style: FilledButton.styleFrom(
                backgroundColor: NeonColors.cyan,
                foregroundColor: NeonColors.deepSpace,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (places.isEmpty && !showEditor)
          Text(
            'Salva Casa, Lavoro o altri indirizzi per inserirli subito in partenza o destinazione.',
            style: GoogleFonts.exo2(color: Colors.white70, height: 1.4),
          ),
        for (final place in places)
          _PlaceTile(place: place, onApply: onApply),
      ],
    );
  }
}

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({required this.place, required this.onApply});

  final SavedPlace place;
  final ValueChanged<SavedPlace> onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: NeonColors.darkSurface,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => onApply(place),
        leading: Icon(
          place.label.toLowerCase() == 'casa'
              ? Icons.home_rounded
              : place.label.toLowerCase() == 'lavoro'
                  ? Icons.work_rounded
                  : Icons.place_rounded,
          color: NeonColors.cyan,
        ),
        title: Text(
          place.label,
          style: GoogleFonts.exo2(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          place.address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Modifica',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: NeonColors.darkCard,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _PlaceEditor(
                          initial: place,
                          currentOrigin: null,
                          currentDestination: null,
                          onDone: () => Navigator.pop(ctx),
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            ),
            IconButton(
              tooltip: 'Elimina',
              onPressed: () =>
                  ref.read(favoritesProvider.notifier).deletePlace(place.id),
              icon: const Icon(Icons.delete_outline, color: NeonColors.pink),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceEditor extends ConsumerStatefulWidget {
  const _PlaceEditor({
    required this.initial,
    this.prefillLabel,
    required this.currentOrigin,
    required this.currentDestination,
    required this.onDone,
  });

  final SavedPlace? initial;
  final String? prefillLabel;
  final PlaceHit? currentOrigin;
  final PlaceHit? currentDestination;
  final VoidCallback onDone;

  @override
  ConsumerState<_PlaceEditor> createState() => _PlaceEditorState();
}

class _PlaceEditorState extends ConsumerState<_PlaceEditor> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _addressCtrl;
  final _nav = NavigationService();
  Timer? _debounce;
  List<PlaceHit> _hits = const [];
  PlaceHit? _picked;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(
      text: widget.initial?.label ?? widget.prefillLabel ?? '',
    );
    _addressCtrl = TextEditingController(text: widget.initial?.address ?? '');
    if (widget.initial != null) {
      _picked = PlaceHit(
        label: widget.initial!.address,
        lat: widget.initial!.lat,
        lon: widget.initial!.lon,
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _onAddressChanged(String value) {
    _picked = null;
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _hits = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final hits = await _nav.searchAddress(value.trim());
        if (!mounted) return;
        setState(() => _hits = hits);
      } catch (_) {
        if (!mounted) return;
        setState(() => _hits = const []);
      }
    });
  }

  void _useHit(PlaceHit hit) {
    _addressCtrl.text = hit.label;
    setState(() {
      _picked = hit;
      _hits = const [];
      _error = null;
    });
  }

  Future<void> _save() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Inserisci un nome (es. Casa, Lavoro)');
      return;
    }
    var picked = _picked;
    if (picked == null && widget.initial != null) {
      picked = PlaceHit(
        label: _addressCtrl.text.trim().isEmpty
            ? widget.initial!.address
            : _addressCtrl.text.trim(),
        lat: widget.initial!.lat,
        lon: widget.initial!.lon,
      );
    }
    if (picked == null) {
      setState(() =>
          _error = 'Cerca e scegli un indirizzo dall\'elenco, oppure usa A/B');
      return;
    }
    setState(() => _saving = true);
    await ref.read(favoritesProvider.notifier).upsertPlace(
          id: widget.initial?.id,
          label: label,
          address: _addressCtrl.text.trim().isEmpty ? picked.label : _addressCtrl.text.trim(),
          lat: picked.lat,
          lon: picked.lon,
        );
    if (!mounted) return;
    widget.onDone();
  }

  InputDecoration _dec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x99D6EEF7)),
      filled: true,
      fillColor: const Color(0xFF0B0B1C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: NeonColors.cyan, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.initial == null ? 'Nuovo luogo' : 'Modifica luogo',
          style: GoogleFonts.exo2(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (final label in kSuggestedPlaceLabels)
              ChoiceChip(
                selected: _labelCtrl.text.trim().toLowerCase() ==
                    label.toLowerCase(),
                label: Text(label),
                selectedColor: NeonColors.cyan,
                labelStyle: TextStyle(
                  color: _labelCtrl.text.trim().toLowerCase() ==
                          label.toLowerCase()
                      ? NeonColors.deepSpace
                      : Colors.white,
                ),
                backgroundColor: NeonColors.darkSurface,
                onSelected: (_) {
                  setState(() => _labelCtrl.text = label);
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _labelCtrl,
          obscureText: false,
          maxLines: 1,
          keyboardType: kIsWeb ? TextInputType.multiline : TextInputType.text,
          style: const TextStyle(color: Color(0xFFF4FBFF)),
          cursorColor: NeonColors.cyan,
          decoration: _dec('Nome (Casa, Lavoro, palestra…)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressCtrl,
          obscureText: false,
          maxLines: 1,
          keyboardType:
              kIsWeb ? TextInputType.multiline : TextInputType.streetAddress,
          style: const TextStyle(color: Color(0xFFF4FBFF), fontSize: 16),
          cursorColor: NeonColors.cyan,
          decoration: _dec('Indirizzo'),
          onChanged: _onAddressChanged,
        ),
        if (_hits.isNotEmpty)
          ..._hits.take(5).map(
                (hit) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.place, color: NeonColors.cyan, size: 18),
                  title: Text(
                    hit.label,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  onTap: () => _useHit(hit),
                ),
              ),
        if (widget.currentOrigin != null || widget.currentDestination != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 8,
              children: [
                if (widget.currentOrigin != null)
                  TextButton(
                    onPressed: () => _useHit(widget.currentOrigin!),
                    child: const Text('Usa partenza (A)'),
                  ),
                if (widget.currentDestination != null)
                  TextButton(
                    onPressed: () => _useHit(widget.currentDestination!),
                    child: const Text('Usa destinazione (B)'),
                  ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _error!,
              style: const TextStyle(color: NeonColors.pink, fontSize: 12),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton(
              onPressed: widget.onDone,
              child: const Text('Annulla'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: NeonColors.cyan,
                foregroundColor: NeonColors.deepSpace,
              ),
              child: Text(_saving ? 'Salvo…' : 'Salva'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItinerariesTab extends ConsumerWidget {
  const _ItinerariesTab({required this.trips, required this.onApply});

  final List<FavoriteItinerary> trips;
  final ValueChanged<FavoriteItinerary> onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (trips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Gli itinerari A→B che calcoli vengono ricordati qui. Puoi fissarli con la stella o eliminarli.',
          style: GoogleFonts.exo2(color: Colors.white70, height: 1.4),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: trips.length,
      itemBuilder: (context, i) {
        final trip = trips[i];
        return Card(
          color: NeonColors.darkSurface,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => onApply(trip),
            leading: Icon(
              trip.pinned ? Icons.star_rounded : Icons.route,
              color: trip.pinned ? NeonColors.pink : NeonColors.cyan,
            ),
            title: Text(
              trip.originLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.exo2(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              '→  ${trip.destLabel}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: trip.pinned ? 'Togli dai fissati' : 'Fissa in cima',
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).togglePin(trip.id),
                  icon: Icon(
                    trip.pinned ? Icons.star_rounded : Icons.star_border_rounded,
                    color: trip.pinned ? NeonColors.pink : Colors.white54,
                  ),
                ),
                IconButton(
                  tooltip: 'Elimina',
                  onPressed: () => ref
                      .read(favoritesProvider.notifier)
                      .deleteItinerary(trip.id),
                  icon: const Icon(Icons.delete_outline, color: NeonColors.pink),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
