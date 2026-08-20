import 'database_service.dart';
import 'api_service.dart';

/// Offline-first sync: pushes locally-changed ("dirty") rows to the backend,
/// then pulls the latest server state back into the local SQLite database.
/// Call this on app start, on pull-to-refresh, and after login.
class SyncService {
  SyncService._internal();
  static final SyncService instance = SyncService._internal();

  final _db = DatabaseService.instance;
  final _api = ApiService.instance;

  bool _syncing = false;

  Future<void> syncAll() async {
    if (_syncing) return;
    if (!await _api.isLoggedIn) return; // not logged in -> local-only mode
    _syncing = true;
    try {
      await _pushReminders();
      await _pushFavorites();
      await _pullReminders();
      await _pullFavorites();
    } catch (e) {
      // Sync failures shouldn't crash the app - local data is still usable offline.
      // Consider surfacing a subtle "sync failed, will retry" indicator in the UI.
      // ignore: avoid_print
      print('Sync error: $e');
    } finally {
      _syncing = false;
    }
  }

  Future<void> _pushReminders() async {
    final dirty = await _db.getDirtyReminders();
    for (final row in dirty) {
      try {
        if (row['status'] == '__deleted__') {
          await _api.deleteReminderRemote(row['id'] as String);
          await _db.deleteReminder(row['id'] as String);
        } else {
          await _api.updateReminder(row['id'] as String, {
            'title': row['title'],
            'notes': row['notes'],
            'latitude': row['latitude'],
            'longitude': row['longitude'],
            'radiusMeters': row['radius_meters'],
            'category': row['category'],
            'conditionType': row['condition_type'],
            'scheduledAt': row['scheduled_at'],
            'status': row['status'],
            'isFavorite': row['is_favorite'] == 1,
          }).catchError((_) => _api.createReminder({
                'title': row['title'],
                'notes': row['notes'],
                'latitude': row['latitude'],
                'longitude': row['longitude'],
                'radiusMeters': row['radius_meters'],
                'category': row['category'],
                'conditionType': row['condition_type'],
                'scheduledAt': row['scheduled_at'],
              }));
          await _db.markReminderSynced(row['id'] as String);
        }
      } catch (_) {
        // leave this row dirty, retry on next sync pass
      }
    }
  }

  Future<void> _pushFavorites() async {
    final dirty = await _db.getDirtyFavorites();
    for (final row in dirty) {
      try {
        await _api.createFavorite({
          'label': row['label'],
          'latitude': row['latitude'],
          'longitude': row['longitude'],
          'address': row['address'],
        });
        await _db.markFavoriteSynced(row['id'] as String);
      } catch (_) {
        // retry next pass
      }
    }
  }

  Future<void> _pullReminders() async {
    final remote = await _api.fetchReminders();
    for (final r in remote) {
      await _db.upsertReminder({
        'id': r['id'],
        'title': r['title'],
        'notes': r['notes'],
        'latitude': r['latitude'],
        'longitude': r['longitude'],
        'radius_meters': r['radius_meters'],
        'category': r['category'],
        'condition_type': r['condition_type'],
        'scheduled_at': r['scheduled_at'],
        'status': r['status'],
        'is_favorite': (r['is_favorite'] == 1 || r['is_favorite'] == true) ? 1 : 0,
        'created_at': r['created_at'],
        'updated_at': r['updated_at'],
        'dirty': 0,
      });
    }
  }

  Future<void> _pullFavorites() async {
    final remote = await _api.fetchFavorites();
    for (final f in remote) {
      await _db.upsertFavorite({
        'id': f['id'],
        'label': f['label'],
        'latitude': f['latitude'],
        'longitude': f['longitude'],
        'address': f['address'],
        'created_at': f['created_at'],
        'updated_at': f['updated_at'],
        'dirty': 0,
      });
    }
  }
}
