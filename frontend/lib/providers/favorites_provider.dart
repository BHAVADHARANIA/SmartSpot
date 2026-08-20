import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/favorite_location.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  List<FavoriteLocation> _favorites = [];
  bool get loading => _loading;
  bool _loading = false;

  List<FavoriteLocation> get favorites => _favorites;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    final rows = await _db.getFavorites();
    _favorites = rows.map((r) => FavoriteLocation.fromLocalMap(r)).toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> addFavorite({
    required String label,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final now = DateTime.now();
    final fav = FavoriteLocation(
      id: _uuid.v4(),
      label: label,
      latitude: latitude,
      longitude: longitude,
      address: address,
      createdAt: now,
      updatedAt: now,
    );
    await _db.upsertFavorite(fav.toLocalMap());
    await load();
    SyncService.instance.syncAll();
  }

  Future<void> removeFavorite(String id) async {
    await _db.deleteFavorite(id);
    await load();
  }
}
