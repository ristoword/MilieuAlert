import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/repositories/zone_repository.dart';

class ZoneSyncService {
  final ZoneRepository _zoneRepository;
  final SharedPreferences _prefs;

  static const _lastSyncKey = 'lastZoneSync';

  ZoneSyncService({
    required this._zoneRepository,
    required this._prefs,
  });

  bool get needsSync {
    final lastSync = _prefs.getInt(_lastSyncKey);
    if (lastSync == null) return true;
    final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSync);
    return DateTime.now().difference(lastSyncTime) > AppConstants.syncInterval;
  }

  Future<bool> syncIfNeeded() async {
    if (!needsSync) return false;
    return syncNow();
  }

  Future<bool> syncNow() async {
    try {
      await _zoneRepository.syncZones();
      await _prefs.setInt(
          _lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      return true;
    } catch (e) {
      return false;
    }
  }
}
