import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../models/navigation_models.dart';
import '../../../models/poi_category.dart';
import '../../../models/saved_places.dart';
import '../../../models/emission_zone.dart';
import '../../../models/zone_status.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/settings_provider.dart';

class SearchSheet extends ConsumerWidget {
  const SearchSheet({
    super.key,
    required this.originCtrl,
    required this.destCtrl,
    required this.originFocus,
    required this.destFocus,
    required this.nav,
    required this.expanded,
    required this.highlighted,
    this.premiumUnlocked = true,
    this.onUpgrade,
    required this.onToggleExpanded,
    required this.onOriginQuery,
    required this.onDestQuery,
    required this.onSelectSuggestion,
    required this.onUseMyLocation,
    required this.onSwap,
    required this.onPlan,
    required this.onGo,
    required this.onSelectAlternative,
    required this.onSavedPlaceTap,
    required this.onAddSuggested,
    required this.onManagePlaces,
    required this.onOpenItineraries,
    required this.onSelectPoi,
    required this.onSelectCategory,
    required this.onApplyItinerary,
  });

  final TextEditingController originCtrl;
  final TextEditingController destCtrl;
  final FocusNode originFocus;
  final FocusNode destFocus;
  final NavigationState nav;
  final bool expanded;
  final bool highlighted;
  final bool premiumUnlocked;
  final VoidCallback? onUpgrade;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onOriginQuery;
  final ValueChanged<String> onDestQuery;
  final ValueChanged<PlaceHit> onSelectSuggestion;
  final VoidCallback onUseMyLocation;
  final VoidCallback onSwap;
  final VoidCallback onPlan;
  final VoidCallback onGo;
  final ValueChanged<int> onSelectAlternative;
  final ValueChanged<SavedPlace> onSavedPlaceTap;
  final ValueChanged<String> onAddSuggested;
  final VoidCallback onManagePlaces;
  final VoidCallback onOpenItineraries;
  final ValueChanged<PlaceHit> onSelectPoi;
  final ValueChanged<PoiCategory> onSelectCategory;
  final ValueChanged<FavoriteItinerary> onApplyItinerary;

  bool _shouldShowGo(NavigationState nav, String destText) {
    if (nav.navigating) return false;
    return nav.destination != null ||
        nav.hasRoute ||
        destText.trim().length >= 3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    final fav = ref.watch(favoritesProvider);
    final travelMode = ref.watch(travelModeProvider);
    final ink = isDark ? Colors.white : MapsColors.ink;
    final muted = isDark ? Colors.white70 : MapsColors.inkMuted;

    if (!expanded) {
      return MapsGlass(
        radius: MapsColors.radiusSheet,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.circular(MapsColors.radiusSheet),
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.velocity.pixelsPerSecond.dy < -80) {
                  onToggleExpanded();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MapsColors.inkMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: muted,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destCtrl.text.trim().isEmpty
                              ? l10n.searchPlace
                              : destCtrl.text.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: destCtrl.text.trim().isEmpty ? muted : ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MapsGlass(
      radius: MapsColors.radiusSheet,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: onToggleExpanded,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MapsColors.inkMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: muted,
                        size: 20,
                      ),
                    ),
                    if (highlighted)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n.navNavigation,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: MapsColors.route,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SheetAddressField(
                fieldId: 'destination',
                controller: destCtrl,
                focusNode: destFocus,
                hint: l10n.searchPlaceOrAddress,
                icon: Icons.search_rounded,
                onChanged: onDestQuery,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SheetAddressField(
                      fieldId: 'origin',
                      controller: originCtrl,
                      focusNode: originFocus,
                      hint: l10n.fromMyLocation,
                      icon: Icons.my_location_rounded,
                      onChanged: onOriginQuery,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.useMyLocation,
                    onPressed: onUseMyLocation,
                    icon: Icon(
                      Icons.gps_fixed,
                      color: nav.originIsMyLocation
                          ? MapsColors.accent
                          : muted,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.swapOriginDestination,
                    onPressed: onSwap,
                    icon: Icon(Icons.swap_vert_rounded, color: muted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _TravelModeChips(
                selected: travelMode,
                enabled: !nav.routing,
                premiumUnlocked: premiumUnlocked,
                onUpgrade: onUpgrade,
                onSelect: (mode) async {
                  await ref.read(travelModeProvider.notifier).setMode(mode);
                  if (nav.destination != null) {
                    await ref
                        .read(navigationProvider.notifier)
                        .planRoute(startFollowing: false);
                  }
                },
              ),
              if (premiumUnlocked && nav.zonesOnRoute.isNotEmpty) ...[
                const SizedBox(height: 10),
                _LezOnRouteNotice(zones: nav.zonesOnRoute),
              ],
              if (premiumUnlocked &&
                  nav.dropOffMessage != null &&
                  !nav.navigating) ...[
                const SizedBox(height: 10),
                _DropOffNotice(message: nav.dropOffMessage!),
              ],
              if (_shouldShowGo(nav, destCtrl.text)) ...[
                const SizedBox(height: 12),
                _GoCta(
                  routing: nav.routing,
                  pulseKey: nav.destination?.label ?? destCtrl.text,
                  showHint: nav.destination != null && !nav.hasRoute,
                  lezOnRoute: nav.zonesOnRoute.isNotEmpty,
                  onGo: onGo,
                ),
              ],
              const SizedBox(height: 12),
              _HomeWorkRow(
                fav: fav,
                onPlaceTap: (place) {
                  if (!premiumUnlocked) {
                    onUpgrade?.call();
                    return;
                  }
                  onSavedPlaceTap(place);
                },
                onAddSuggested: (label) {
                  if (!premiumUnlocked) {
                    onUpgrade?.call();
                    return;
                  }
                  onAddSuggested(label);
                },
                onManagePlaces: () {
                  if (!premiumUnlocked) {
                    onUpgrade?.call();
                    return;
                  }
                  onManagePlaces();
                },
              ),
              const SizedBox(height: 12),
              _CategoryRow(
                selectedId: nav.nearbyCategory,
                searching: nav.nearbySearching,
                locked: !premiumUnlocked,
                onSelect: (cat) {
                  if (!premiumUnlocked) {
                    onUpgrade?.call();
                    return;
                  }
                  onSelectCategory(cat);
                },
              ),
              if (nav.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      nav.error!,
                      style: GoogleFonts.inter(
                        color: MapsColors.endRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              if (nav.suggestions.isNotEmpty)
                _SuggestionList(
                  nav: nav,
                  onSelect: onSelectSuggestion,
                ),
              if (premiumUnlocked && nav.nearbySearching)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(
                    minHeight: 2,
                    color: MapsColors.accent,
                  ),
                ),
              if (premiumUnlocked && nav.nearbyResults.isNotEmpty)
                _PoiResults(
                  results: nav.nearbyResults,
                  onSelect: onSelectPoi,
                )
              else if (premiumUnlocked &&
                  nav.nearbyCategory != null &&
                  !nav.nearbySearching &&
                  nav.nearbyResults.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    l10n.noResultsNearby,
                    style: GoogleFonts.inter(fontSize: 13, color: muted),
                  ),
                ),
              if (nav.nearbyResults.isEmpty && nav.suggestions.isEmpty)
                _Recents(
                  trips: fav.itineraries,
                  onApply: onApplyItinerary,
                  onOpenAll: onOpenItineraries,
                ),
              if (nav.hasRoute && !nav.navigating) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniChip(
                      icon: Icons.route_rounded,
                      label:
                          '${formatDistance(nav.routeDistanceMeters)} · ${formatDuration(nav.routeDurationSeconds)}',
                    ),
                    _MiniChip(
                      icon: Icons.shield_outlined,
                      label: nav.zonesOnRoute.isEmpty
                          ? l10n.noZones
                          : l10n.zonesOnRouteCount(nav.zonesOnRoute.length),
                      color: nav.zonesOnRoute.isEmpty
                          ? MapsColors.accent
                          : MapsColors.lezOnRouteBorder,
                    ),
                    if (nav.mode.isCar)
                      _MiniChip(
                        icon: Icons.videocam_outlined,
                        label: nav.cameras.isEmpty
                            ? l10n.noSpeedCameras
                            : l10n.speedCamerasCount(nav.cameras.length),
                        color: nav.cameras.isEmpty
                            ? MapsColors.accent
                            : const Color(0xFFFF9F0A),
                      ),
                  ],
                ),
                if (nav.alternatives.length > 1) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: nav.alternatives.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final plan = nav.alternatives[i];
                        final selected = i == nav.selectedRoute;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(
                            '${plan.chipLabelIt(i)} · ${formatDuration(plan.durationSeconds)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : ink,
                            ),
                          ),
                          selectedColor: MapsColors.route,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF2F2F7),
                          onSelected: (_) => onSelectAlternative(i),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelModeChips extends StatelessWidget {
  const _TravelModeChips({
    required this.selected,
    required this.onSelect,
    this.enabled = true,
    this.premiumUnlocked = true,
    this.onUpgrade,
  });

  final TravelMode selected;
  final ValueChanged<TravelMode> onSelect;
  final bool enabled;
  final bool premiumUnlocked;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    final ink = isDark ? Colors.white : MapsColors.ink;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final item in [
          (TravelMode.car, l10n.travelCar, Icons.directions_car_rounded),
          (TravelMode.foot, l10n.travelFoot, Icons.directions_walk_rounded),
          (TravelMode.transit, l10n.travelTransit, Icons.directions_transit_rounded),
        ])
          ChoiceChip(
              selected: selected == item.$1,
              label: Text(
                item.$2,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected == item.$1 ? Colors.white : ink,
                ),
              ),
              avatar: Icon(
                item.$3,
                size: 16,
                color: selected == item.$1 ? Colors.white : MapsColors.route,
              ),
              selectedColor: MapsColors.route,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF2F2F7),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              onSelected: !enabled
                  ? null
                  : (on) {
                      if (!on) return;
                      if (!premiumUnlocked && item.$1 != TravelMode.car) {
                        onUpgrade?.call();
                        return;
                      }
                      onSelect(item.$1);
                    },
            ),
      ],
    );
  }
}

class _LezOnRouteNotice extends StatelessWidget {
  const _LezOnRouteNotice({required this.zones});

  final List<EmissionZone> zones;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    final names = zones.map((z) => z.name).where((n) => n.trim().isNotEmpty);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: MapsColors.lezOnRouteBorder.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MapsColors.lezOnRouteBorder, width: 1.2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_rounded,
            color: MapsColors.lezOnRouteBorder,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lezOnRoute,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: MapsColors.lezOnRouteBorder,
                  ),
                ),
                Text(
                  names.isEmpty
                      ? l10n.lezOnChosenRoute
                      : names.take(3).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : MapsColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropOffNotice extends StatelessWidget {
  const _DropOffNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: MapsColors.endRed.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MapsColors.endRed, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.directions_walk_rounded,
            color: MapsColors.endRed,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dropoffRecommended,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: MapsColors.endRed,
                  ),
                ),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: isDark ? Colors.white : MapsColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoCta extends StatefulWidget {
  const _GoCta({
    required this.routing,
    required this.pulseKey,
    required this.showHint,
    required this.onGo,
    this.lezOnRoute = false,
  });

  final bool routing;
  final String pulseKey;
  final bool showHint;
  final VoidCallback onGo;
  final bool lezOnRoute;

  @override
  State<_GoCta> createState() => _GoCtaState();
}

class _GoCtaState extends State<_GoCta> with SingleTickerProviderStateMixin {
  static const _goGreen = Color(0xFF34C759);
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.pulseKey.isNotEmpty) {
      _pulse.repeat(reverse: true);
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _pulse.stop();
        _pulse.value = 0;
      });
    }
  }

  @override
  void didUpdateWidget(_GoCta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseKey != widget.pulseKey && widget.pulseKey.isNotEmpty) {
      _pulse.repeat(reverse: true);
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _pulse.stop();
        _pulse.value = 0;
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 1, end: 1.035).animate(
            CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: widget.routing ? null : widget.onGo,
              icon: Icon(
                widget.routing
                    ? Icons.hourglass_top_rounded
                    : Icons.navigation_rounded,
                size: 26,
              ),
              label: Text(widget.routing ? l10nOf(context).calculating : l10nOf(context).go),
              style: FilledButton.styleFrom(
                backgroundColor: _goGreen,
                disabledBackgroundColor: _goGreen.withValues(alpha: 0.55),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
        if (widget.showHint && !widget.routing)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.lezOnRoute
                  ? l10nOf(context).goHintLez
                  : l10nOf(context).goHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.lezOnRoute
                    ? MapsColors.lezOnRouteBorder
                    : _goGreen,
              ),
            ),
          ),
      ],
    );
  }
}

class _SheetAddressField extends StatelessWidget {
  const _SheetAddressField({
    required this.fieldId,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.onChanged,
  });

  final String fieldId;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      key: ValueKey('address-$fieldId'),
      controller: controller,
      focusNode: focusNode,
      obscureText: false,
      autocorrect: !kIsWeb,
      enableSuggestions: true,
      enableInteractiveSelection: true,
      maxLines: 1,
      keyboardType:
          kIsWeb ? TextInputType.multiline : TextInputType.streetAddress,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [
        AutofillHints.streetAddressLine1,
        AutofillHints.addressCity,
        AutofillHints.location,
      ],
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      cursorColor: MapsColors.accent,
      cursorWidth: 2,
      style: GoogleFonts.inter(
        color: isDark ? const Color(0xFFF4FBFF) : MapsColors.ink,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: isDark ? const Color(0x99D6EEF7) : MapsColors.inkMuted,
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: MapsColors.accent, size: 22),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MapsColors.accent, width: 1.4),
        ),
      ),
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

class _HomeWorkRow extends StatelessWidget {
  const _HomeWorkRow({
    required this.fav,
    required this.onPlaceTap,
    required this.onAddSuggested,
    required this.onManagePlaces,
  });

  final FavoritesState fav;
  final ValueChanged<SavedPlace> onPlaceTap;
  final ValueChanged<String> onAddSuggested;
  final VoidCallback onManagePlaces;

  @override
  Widget build(BuildContext context) {
    final l10n = l10nOf(context);
    return Row(
      children: [
        for (final label in kSuggestedPlaceLabels)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: _RoundShortcut(
              label: suggestedPlaceLabel(label, l10n),
              icon: label.toLowerCase() == 'casa'
                  ? Icons.home_rounded
                  : Icons.work_rounded,
              saved: fav.placeByLabel(label) != null,
              plusIfUnsaved: true,
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
        _RoundShortcut(
          label: l10n.places,
          icon: Icons.add_rounded,
          saved: false,
          plusIfUnsaved: false,
          onTap: onManagePlaces,
        ),
      ],
    );
  }
}

class _RoundShortcut extends StatelessWidget {
  const _RoundShortcut({
    required this.label,
    required this.icon,
    required this.saved,
    required this.onTap,
    this.plusIfUnsaved = true,
  });

  final String label;
  final IconData icon;
  final bool saved;
  final bool plusIfUnsaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: saved
                  ? MapsColors.route.withValues(alpha: isDark ? 0.22 : 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF2F2F7)),
            ),
            child: Icon(
              icon,
              color: saved ? MapsColors.route : MapsColors.inkMuted,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            saved ? label : (plusIfUnsaved ? '$label +' : label),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : MapsColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.selectedId,
    required this.searching,
    required this.onSelect,
    this.locked = false,
  });

  final String? selectedId;
  final bool searching;
  final ValueChanged<PoiCategory> onSelect;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kPoiCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = kPoiCategories[i];
          final selected = selectedId == cat.id;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: SizedBox(
              width: 78,
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? MapsColors.accent
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF2F2F7)),
                    ),
                    child: searching && selected
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            locked ? Icons.lock_outline : cat.icon,
                            color: selected
                                ? Colors.white
                                : MapsColors.route,
                            size: 24,
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizedPoiLabel(l10nOf(context), cat),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: isDark ? Colors.white : MapsColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({required this.nav, required this.onSelect});

  final NavigationState nav;
  final ValueChanged<PlaceHit> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8),
        children: [
          for (final hit in nav.suggestions)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                nav.activeField == SearchField.origin
                    ? Icons.trip_origin
                    : Icons.place_outlined,
                color: MapsColors.route,
              ),
              title: Text(
                hit.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark ? Colors.white : MapsColors.ink,
                ),
              ),
              onTap: () => onSelect(hit),
            ),
        ],
      ),
    );
  }
}

class _PoiResults extends StatelessWidget {
  const _PoiResults({required this.results, required this.onSelect});

  final List<PlaceHit> results;
  final ValueChanged<PlaceHit> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 8),
        itemCount: results.length,
        itemBuilder: (context, i) {
          final hit = results[i];
          final cat = poiCategoryById(hit.category);
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: hit.inLez
                  ? MapsColors.lezOnRouteBorder.withValues(alpha: 0.2)
                  : MapsColors.route.withValues(alpha: 0.12),
              child: Icon(
                cat?.icon ?? Icons.place_rounded,
                size: 18,
                color: hit.inLez
                    ? MapsColors.lezOnRouteBorder
                    : MapsColors.route,
              ),
            ),
            title: Text(
              hit.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : MapsColors.ink,
              ),
            ),
            subtitle: Text(
              [
                if (hit.distanceMeters != null)
                  formatDistance(hit.distanceMeters),
                if (hit.inLez) l10nOf(context).environmentalZoneShort,
                if (hit.zoneName != null && hit.zoneName!.isNotEmpty)
                  hit.zoneName!,
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: hit.inLez
                    ? MapsColors.lezOnRouteBorder
                    : (isDark ? Colors.white60 : MapsColors.inkMuted),
              ),
            ),
            trailing: const Icon(Icons.directions_rounded, color: MapsColors.route),
            onTap: () => onSelect(hit),
          );
        },
      ),
    );
  }
}

class _Recents extends StatelessWidget {
  const _Recents({
    required this.trips,
    required this.onApply,
    required this.onOpenAll,
  });

  final List<FavoriteItinerary> trips;
  final ValueChanged<FavoriteItinerary> onApply;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = l10nOf(context);
    final recent = trips.take(4).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.recents,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? Colors.white : MapsColors.ink,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenAll,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: MapsColors.route,
                ),
                child: Text(l10n.itineraries),
              ),
            ],
          ),
          for (final trip in recent)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                trip.pinned ? Icons.star_rounded : Icons.schedule_rounded,
                color: trip.pinned
                    ? const Color(0xFFFF9F0A)
                    : MapsColors.inkMuted,
              ),
              title: Text(
                trip.destLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : MapsColors.ink,
                ),
              ),
              subtitle: Text(
                l10n.fromOrigin(trip.originLabel),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : MapsColors.inkMuted,
                ),
              ),
              onTap: () => onApply(trip),
            ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    this.color = MapsColors.accent,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
