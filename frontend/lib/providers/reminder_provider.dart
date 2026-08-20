import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class ReminderProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<Reminder> _reminders = [];
  bool _loading = false;

  List<Reminder> get reminders => _reminders;
  List<Reminder> get active => _reminders.where((r) => r.status == 'active').toList();
  List<Reminder> get completed => _reminders.where((r) => r.status == 'completed').toList();
  List<Reminder> get archived => _reminders.where((r) => r.status == 'archived').toList();
  List<Reminder> get favorites => _reminders.where((r) => r.isFavorite).toList();
  bool get loading => _loading;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final rows = await _db.getReminders();
    _reminders = rows.map((r) => Reminder.fromLocalMap(r)).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshFromServer() async {
    await SyncService.instance.syncAll();
    await load();
  }

  Future<void> addReminder({
    required String title,
    String? notes,
    double? latitude,
    double? longitude,
    double radiusMeters = 100,
    String? category,
    String conditionType = 'arrive',
    DateTime? scheduledAt,
  }) async {
    final now = DateTime.now();
    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      notes: notes,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      category: category,
      conditionType: conditionType,
      scheduledAt: scheduledAt,
      createdAt: now,
      updatedAt: now,
      dirty: true,
    );
    await _db.upsertReminder(reminder.toLocalMap());
    await load();
    // fire-and-forget sync; UI already reflects the local write immediately
    SyncService.instance.syncAll();
  }

  Future<void> updateReminder(Reminder reminder) async {
    reminder.updatedAt = DateTime.now();
    reminder.dirty = true;
    await _db.upsertReminder(reminder.toLocalMap());
    await load();
    SyncService.instance.syncAll();
  }

  Future<void> setStatus(String id, String status) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.status = status;
    await updateReminder(reminder);
  }

  Future<void> toggleFavorite(String id) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.isFavorite = !reminder.isFavorite;
    await updateReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _db.deleteReminder(id);
    await load();
  }
}
