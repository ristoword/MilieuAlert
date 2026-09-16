import 'package:flutter/material.dart';

import '../models/hazard_report.dart';

class HazardStrings {
  HazardStrings(this.lang);

  final String lang;

  factory HazardStrings.of(BuildContext context) {
    return HazardStrings(Localizations.localeOf(context).languageCode);
  }

  bool get _it => lang == 'it';
  bool get _nl => lang == 'nl';
  bool get _de => lang == 'de';
  bool get _fr => lang == 'fr';

  String get report =>
      _it ? 'Segnala' : _nl ? 'Meld' : _de ? 'Melden' : _fr ? 'Signaler' : 'Report';

  String get reportTitle => _it
      ? 'Segnala sulla strada'
      : _nl
          ? 'Melding op de weg'
          : _de
              ? 'Auf der Straße melden'
              : _fr
                  ? 'Signaler sur la route'
                  : 'Report on the road';

  String get noteHint => _it
      ? 'Nota breve (facoltativa)'
      : _nl
          ? 'Korte toelichting (optioneel)'
          : 'Short note (optional)';

  String get send =>
      _it ? 'Invia' : _nl ? 'Verstuur' : _de ? 'Senden' : _fr ? 'Envoyer' : 'Send';

  String get stillThere => _it
      ? 'È ancora lì'
      : _nl
          ? 'Staat er nog'
          : _de
              ? 'Ist noch da'
              : _fr
                  ? 'Toujours là'
                  : 'Still there';

  String get gone => _it
      ? 'Non c\'è più'
      : _nl
          ? 'Is weg'
          : _de
              ? 'Ist weg'
              : _fr
                  ? 'Plus là'
                  : 'Gone';

  String get nearbyFeed => _it
      ? 'Segnalazioni vicine'
      : _nl
          ? 'Meldingen in de buurt'
          : _de
              ? 'Meldungen in der Nähe'
              : _fr
                  ? 'Signalements à proximité'
                  : 'Nearby reports';

  String get commentHint => _it
      ? 'Un rigo per gli altri conducenti'
      : _nl
          ? 'Eén regel voor andere bestuurders'
          : 'One line for other drivers';

  String get commentSend =>
      _it ? 'Invia' : _nl ? 'Stuur' : _de ? 'Senden' : _fr ? 'Envoyer' : 'Send';

  String get aDriver => _it
      ? 'Un conducente'
      : _nl
          ? 'Een bestuurder'
          : _de
              ? 'Ein Fahrer'
              : _fr
                  ? 'Un conducteur'
                  : 'A driver';

  String get noReports => _it
      ? 'Nessuna segnalazione vicina'
      : _nl
          ? 'Geen meldingen in de buurt'
          : 'No nearby reports';

  String get reported => _it
      ? 'Segnalazione inviata'
      : _nl
          ? 'Melding verstuurd'
          : 'Report sent';

  String get needLocation => _it
      ? 'Serve la posizione per segnalare'
      : _nl
          ? 'Locatie nodig om te melden'
          : 'Location needed to report';

  String get toggle3d => '3D';
  String get toggle2d => '2D';

  String label(HazardType type) {
    switch (type) {
      case HazardType.cameraFixed:
        return _it
            ? 'Autovelox fisso'
            : _nl
                ? 'Vaste flitser'
                : _de
                    ? 'Blitzer fest'
                    : _fr
                        ? 'Radar fixe'
                        : 'Fixed speed camera';
      case HazardType.cameraMobile:
        return _it
            ? 'Autovelox mobile / non in mappa'
            : _nl
                ? 'Mobiele flitser / niet op de kaart'
                : _de
                    ? 'Mobiler Blitzer / nicht auf der Karte'
                    : _fr
                        ? 'Radar mobile / hors carte'
                        : 'Mobile camera / not on official map';
      case HazardType.accident:
        return _it
            ? 'Incidente'
            : _nl
                ? 'Ongeval'
                : _de
                    ? 'Unfall'
                    : _fr
                        ? 'Accident'
                        : 'Accident';
      case HazardType.jam:
        return _it
            ? 'Coda'
            : _nl
                ? 'File'
                : _de
                    ? 'Stau'
                    : _fr
                        ? 'Bouchon'
                        : 'Traffic jam';
      case HazardType.police:
        return _it
            ? 'Polizia'
            : _nl
                ? 'Politie'
                : _de
                    ? 'Polizei'
                    : _fr
                        ? 'Police'
                        : 'Police';
      case HazardType.roadClosed:
        return _it
            ? 'Strada chiusa'
            : _nl
                ? 'Weg afgesloten'
                : _de
                    ? 'Straße gesperrt'
                    : _fr
                        ? 'Route fermée'
                        : 'Road closed';
      case HazardType.lezExtra:
        return _it
            ? 'Zona ambientale extra'
            : _nl
                ? 'Extra milieuzone'
                : _de
                    ? 'Extra Umweltzone'
                    : _fr
                        ? 'Zone environnementale extra'
                        : 'Extra environmental zone';
    }
  }

  String bannerTitle(HazardType type, String distance) {
    switch (type) {
      case HazardType.cameraFixed:
      case HazardType.cameraMobile:
        return _it
            ? 'Autovelox tra $distance'
            : _nl
                ? 'Flitser over $distance'
                : _de
                    ? 'Blitzer in $distance'
                    : _fr
                        ? 'Radar dans $distance'
                        : 'Speed camera in $distance';
      case HazardType.accident:
        return _it
            ? 'Incidente tra $distance'
            : _nl
                ? 'Ongeval over $distance'
                : 'Accident in $distance';
      case HazardType.jam:
        return _it
            ? 'Coda tra $distance'
            : _nl
                ? 'File over $distance'
                : 'Jam in $distance';
      case HazardType.police:
        return _it
            ? 'Polizia tra $distance'
            : _nl
                ? 'Politie over $distance'
                : 'Police in $distance';
      case HazardType.roadClosed:
        return _it
            ? 'Strada chiusa tra $distance'
            : _nl
                ? 'Weg afgesloten over $distance'
                : 'Road closed in $distance';
      case HazardType.lezExtra:
        return _it
            ? 'Zona ambientale extra tra $distance'
            : _nl
                ? 'Extra milieuzone over $distance'
                : 'Extra LEZ in $distance';
    }
  }

  String timeAgo(DateTime at) {
    final sec = DateTime.now().difference(at).inSeconds;
    if (sec < 60) {
      return _it ? 'adesso' : _nl ? 'nu' : 'just now';
    }
    final min = (sec / 60).floor();
    if (min < 60) {
      return _it
          ? '$min min fa'
          : _nl
              ? '$min min geleden'
              : '$min min ago';
    }
    final h = (min / 60).floor();
    return _it ? '$h h fa' : _nl ? '$h u geleden' : '$h h ago';
  }

  String unofficialHint(HazardType type) {
    if (type == HazardType.cameraMobile) {
      return _it
          ? 'Segnalato da conducenti, non in mappa ufficiale'
          : _nl
              ? 'Gemeld door bestuurders, niet op de officiële kaart'
              : 'Reported by drivers, not on the official map';
    }
    if (type == HazardType.cameraFixed) {
      return _it
          ? 'Autovelox confermato dalla community'
          : 'Community-confirmed speed camera';
    }
    return '';
  }
}
